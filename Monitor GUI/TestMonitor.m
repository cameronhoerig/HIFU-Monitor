function [] = TestMonitor()

funcAmp = 2; % start input at 170 mVpp
funcUnit = 'vpp'; % amplitude will be in peak-to-peak
funcFreq = 15000;%3.3e6; % 3.3 MHz frequency
funcForm = 'sin'; % function generator output is a waveform

dataPlotLength = 30;
dataToPlot = zeros(1,dataPlotLength);
dataIndex = 1;

inputFine = 0;
binThreshold = 0;

while(inputFine == 0)
    userThreshold = input('Input the upper threshold: ');
    if(userThreshold > 2^32-1)
        fprintf('That number is too big. Try again.\n');
    else
        binThreshold = dec2bin(userThreshold,32);
        inputFine = 1;
    end
end
disp(binThreshold);
highByteThreshold = binThreshold(1:8); highByteThreshold = bin2dec(highByteThreshold);
upmidByteThreshold = binThreshold(9:16); upmidByteThreshold = bin2dec(upmidByteThreshold);
lowmidByteThreshold = binThreshold(17:24); lowmidByteThreshold = bin2dec(lowmidByteThreshold);
lowByteThreshold = binThreshold(25:32); lowByteThreshold = bin2dec(lowByteThreshold);

highByteThreshold = uint8(highByteThreshold); highByteThreshold = native2unicode(highByteThreshold);
upmidByteThreshold = uint8(upmidByteThreshold); upmidByteThreshold = native2unicode(upmidByteThreshold);
lowmidByteThreshold = uint8(lowmidByteThreshold); lowmidByteThreshold = native2unicode(lowmidByteThreshold);
lowByteThreshold = uint8(lowByteThreshold); lowByteThreshold = native2unicode(lowByteThreshold);

graphHandle = figure;
title('Received RMS Values');
drawnow

agilentObj = 1; % dummy object for debugging without using agilent AWG

%%{
% Connect to function generator
if(~exist('agilentInterfaceObj','var'))
    agilentInterfaceObj = visa('AGILENT','USB0::2391::1031::MY44006969::0::INSTR');
    agilentObj = icdevice('agilent_33220a.mdd',agilentInterfaceObj);
    connect(agilentObj);
end

set(agilentObj,'Output','Off');
set(agilentObj,'Amplitude', funcAmp);
pause(.25);
set(agilentObj,'AmplitudeUnits', funcUnit);
pause(.25);
set(agilentObj,'Frequency', funcFreq);
pause(.25);
set(agilentObj,'Waveform', funcForm);
%}

picObject = serial('COM7','BaudRate',921875);
picObject.InputBufferSize = 10000;
picObject.Timeout = 1;
%picObject.BytesAvailableFcnMode = 'byte';
%picObject.BytesAvailableFcnCount = 1;
%picObject.BytesAvailableFcn = {@TestCallback,picObject,agilentObj,graphHandle};

callbackOn = 0;

fopen(picObject);
fwrite(picObject,'r','uint8'); % have the controller reset itself

callbackData = zeros(1,dataPlotLength+2);
callbackData(2:dataPlotLength+1) = dataToPlot;
callbackData(end) = dataIndex;
callbackData(1) = dataPlotLength;

set(graphHandle,'UserData',callbackData);

sampleFlag = 1; 

handshakeComplete = 0;

% Start the initial handshake. The computer first confirms the MCU is ready
% by sending 'c' and expects a 'c' in return. This is repeated until
% successful. Then, it sends the 32-bit threshold level to the MCU in byte
% long packets. After each packet is sent, it expects response of 'k' to
% confirm reception. If this fails during any of the four byte transfers,
% the whole handshake is restarted. 
while(handshakeComplete == 0)
    flushinput(picObject);
    fwrite(picObject,'c','uint8');
    picResponse = fread(picObject,1,'uint8');
    if(isempty(picResponse))
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    elseif(picResponse ~= 'c')
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    end
    
    fwrite(picObject,highByteThreshold,'uint8');
    picResponse = fread(picObject,1,'uint8');
    if(isempty(picResponse))
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    elseif(picResponse ~= 'k')
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    end
    
    fwrite(picObject,upmidByteThreshold,'uint8');
    picResponse = fread(picObject,1,'uint8');
    if(isempty(picResponse))
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    elseif(picResponse ~= 'k')
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    end
    
    fwrite(picObject,lowmidByteThreshold,'uint8');
    picResponse = fread(picObject,1,'uint8');
    if(isempty(picResponse))
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    elseif(picResponse ~= 'k')
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    end
    
    fwrite(picObject,lowByteThreshold,'uint8');
    picResponse = fread(picObject,1,'uint8');
    if(isempty(picResponse))
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    elseif(picResponse ~= 'k')
        fwrite(picObject,'r','uint8'); % have the controller reset itself
        pause(1);
        continue
    end
    
    handshakeComplete = 1;    
end

callbackOn = 1;

% close picObject in order to set up the bytes received callback function
fclose(picObject);
picObject.BytesAvailableFcnMode = 'byte';
picObject.BytesAvailableFcnCount = 1;
picObject.BytesAvailableFcn = {@TestCallback,picObject,agilentObj,graphHandle, callbackOn};
fopen(picObject);

fwrite(picObject,'g','uint8'); % start the dsPIC sampling

while(1)
    if(sampleFlag == 1)
        fprintf('Device Started\n');
        sampleFlag = 0;
    end
end

    
function TestCallback(obj, event, picObject, agilentObject, graphHandle, callbackOn)

%dataMat = fread(picObject,2,'int8');
%receivedCommand = fread(picObject,1,'uint8');
%flushinput(picObject);

%plotData = dataMat(1)*dataMat(2);

%fprintf('Received Data: %d \n',plotData);

if(callbackOn == 0)
    return
end

callbackData = get(graphHandle,'UserData');
dataPlotLength = callbackData(1);
dataToPlot = callbackData(2:dataPlotLength+1);
dataIndex = callbackData(end);


serialID = fread(picObject,1,'int8');
if(serialID == -1) % if the next transmission is a command
    receivedCommand = fread(picObject,1,'uint8');
    %if the received command is to raise the amplitude, increase
    %it by 10 mVpp
    if(receivedCommand == 'r')
        currentAmp = get(agilentObject,'Amplitude');
        currentAmp = currentAmp + .01;
        set(agilentObject, 'Amplitude', currentAmp);
        fprintf('\nRaise Voltage\n\n');
    %if the received command is to lower the amplitude, decrease
    %it by 10 mVpp
    elseif(receivedCommand == 'l')
        currentAmp = get(agilentObject,'Amplitude');
        currentAmp = currentAmp - .01;
        set(agilentObject, 'Amplitude', currentAmp);
        fprintf('\nLower Voltage\n\n');
    %if the received command is notifying of an "emergency" that the
    %emissions have hit a threshold with a significant probability of 
    %causing vessel rupture, low the amplitude by 100 mVpp
    elseif(receivedCommand == 'e')
        currentAmp = get(agilentObject,'Amplitude');
        currentAmp = currentAmp - .1;
        set(agilentObject, 'Amplitude', currentAmp);
        fprintf('\nLower Voltage\n\n');
    elseif(receivedCommand == 's')
        %The command was to remain at the current voltage level. Do nothing
        fprintf('Staying...\n');
    %if an unknown command was received, give a notification 
    elseif(receivedCommand == 'a')
        set(agilentObject,'Output','Off');
        fprintf('Function Generator Off\n');
        fwrite(picObject,'q','uint8'); % send dummy character to controller
                           % so it knows AWG was turned off
    elseif(receivedCommand == 'n')
        set(agilentObject,'Output','On');
        fprintf('Function Generator On\n');
        fwrite(picObject,'p','uint8'); % send dummy character to controller
                           % so it knows AWG was turned on
    else
        fprintf('Received unknown command "%s".\n',receivedCommand);
    end
elseif(serialID == -5) % if the net transmission is data
    dataMat = fread(picObject,1,'int32');
    if(dataIndex <= dataPlotLength)
        dataToPlot(dataIndex) = dataMat;
    else
        dataToPlot = [dataToPlot(2:end), dataMat];
    end
    
    dataIndex = dataIndex + 1;

    figure(graphHandle)
    plot(dataToPlot)
    drawnow
    
    callbackData(2:dataPlotLength+1) = dataToPlot;
    callbackData(end) = dataIndex;
    callbackData(1) = dataPlotLength;
    set(graphHandle,'UserData',callbackData);
    
    fprintf('Received Data: %d \n',dataMat);
else
    fprintf('Unknown ID received: %d\n',serialID);
    fprintf(picObject,'r');
end

