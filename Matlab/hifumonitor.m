function varargout = hifumonitor(varargin)
% HIFUMONITOR MATLAB code for hifumonitor.fig
%      HIFUMONITOR, by itself, creates a new HIFUMONITOR or raises the existing
%      singleton*.
%
%      H = HIFUMONITOR returns the handle to a new HIFUMONITOR or the handle to
%      the existing singleton*.
%
%      HIFUMONITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HIFUMONITOR.M with the given input arguments.
%
%      HIFUMONITOR('Property','Value',...) creates a new HIFUMONITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hifumonitor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hifumonitor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hifumonitor

% Last Modified by GUIDE v2.5 29-Feb-2012 18:23:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hifumonitor_OpeningFcn, ...
                   'gui_OutputFcn',  @hifumonitor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before hifumonitor is made visible.
function hifumonitor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hifumonitor (see VARARGIN)

% Choose default command line output for hifumonitor
handles.output = hObject;

% Set button and text box labels
set(handles.experimentStatus,'String','Not Started');
set(handles.transducerStatus,'String','Transducer Off');
set(handles.inputVoltage,'String','Not On');

% Some global variables that will be used in callbacks
funcAmp = .170; %start input at 170 mVpp
funcUnit = 'vpp'; %amplitude will be in peak-to-peak
funcFreq = 3.3e6; %3.3 MHz frequency from function generator
funcForm = 'sin'; %function generator output is a sine wave

dataPlotLength = 30; % number of values to be plotted at a time
dataToPlot = zeros(1,dataPlotLength); % array holding the values to be plotted
dataIndex = 1; % current index in dataToPlot

pauseOperation = 0;
set(handles.stopButton,'UserData',pause);

agilentObj = 1; % dummy object for debugging without using agilent AWG

%{
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

picObject = 1; % dummy used for debugging

%picObject = serial('COM7','BaudRate',921875);
%picObject.InputBufferSize = 10000;
%picObject.BytesAvailableFcnMode = 'byte';
%picObject.BytesAvailableFcnCount = 1;
%picObject.BytesAvailableFcn = {@TestCallback,picObject,agilentObj,graphHandle};

objectCell = cell(1,2);
objectCell{1} = picObject;
objectCell{2} = agilentObj;
set(handles.startButton,'UserData',objectCell);

callbackData = zeros(1,dataPlotLength+2);
callbackData(2:dataPlotLength+1) = dataToPlot;
callbackData(end) = dataIndex;
callbackData(1) = dataPlotLength;

set(handles.RmsPlot,'UserData',callbackData);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hifumonitor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hifumonitor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comObject = get(handles.startButton,'UserData');
picObject = comObject{1};
agilentObj = comObject{2};

pauseOperation = get(handles.stopButton,'UserData');
pauseOperation = 0;
set(handles.stopButton,'UserData',pauseOperation);

set(agilentObj,'Output','Off'); % turn off the function generator
fwrite(picObject,'r','uint8'); % reset the microcontroller
set(handles.experimentStatus,'String','Stopped')
set(handles.transducerStatus,'String','Transducer Off');
set(handles.outputVoltage,'String','Input Voltage: Not On');

% delete and recreate serial port object for circuit in order to 
% resetBytesAvailableFcn

fclose(picObject);
delete(picObject);

picObject = 1; % dummy used for debugging
%picObject = serial('COM7','BaudRate',921875);
%picObject.InputBufferSize = 10000;


% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comObject = get(handles.startButton,'UserData');
picObject = comObject{1};
agilentObj = comObject{2};

pauseOperation = get(handles.stopButton,'UserData');
pauseOperation = 1;
set(handles.stopButton,'UserData',pauseOperation);

set(agilentObj,'Output','Off'); % turn off the function generator
fwrite(picObject,'s','uint8'); % pause the microcontroller
set(handles.experimentStatus,'String','Paused')
set(handles.transducerStatus,'String','Transducer Off');
set(handles.outputVoltage,'String','Input Voltage: Not On');


% --- Executes on button press in increaseButton.
function increaseButton_Callback(hObject, eventdata, handles)
% hObject    handle to increaseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comObject = get(handles.startButton,'UserData');
picObject = comObject{1};
agilentObj = comObject{2};

% increase output voltage by 10 mVpp
%{
currentAmp = get(agilentObject,'Amplitude');
currentAmp = currentAmp + .01;
set(agilentObject, 'Amplitude', currentAmp);

tempString = 'Input Voltage: ';
updateString = strcat(tempString,num2str(currentAmp),' mVpp');
set(handles.outputVoltage,'String',updateString);

%}


% --- Executes on button press in decreaseButton.
function decreaseButton_Callback(hObject, eventdata, handles)
% hObject    handle to decreaseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comObject = get(handles.startButton,'UserData');
picObject = comObject{1};
agilentObj = comObject{2};

% decrease the output voltage by 10 mVpp
%{
currentAmp = get(agilentObject,'Amplitude');
currentAmp = currentAmp - .01;
set(agilentObject, 'Amplitude', currentAmp);

tempString = 'Input Voltage: ';
updateString = strcat(tempString,num2str(currentAmp),' mVpp');
set(handles.outputVoltage,'String',updateString);
%}

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pauseOperation = get(handles.stopButton,'UserData');

if(pauseOperation == 0)
    inputFine = 0;
    binThreshold = 0;

    while(inputFine == 0)
        userThreshold = inputdlg('Input the upper threshold: ');
        userThreshold = userThreshold{1};
        if(userThreshold > 2^32-1)
            errordlg('That number is too big. Must be from 0 to 5');
        else
            binThreshold = dec2bin(userThreshold,32);
            inputFine = 1;
        end
    end

    highByteThreshold = binThreshold(1:8); highByteThreshold = bin2dec(highByteThreshold);
    upmidByteThreshold = binThreshold(9:16); upmidByteThreshold = bin2dec(upmidByteThreshold);
    lowmidByteThreshold = binThreshold(17:24); lowmidByteThreshold = bin2dec(lowmidByteThreshold);
    lowByteThreshold = binThreshold(25:32); lowByteThreshold = bin2dec(lowByteThreshold);

    highByteThreshold = uint8(highByteThreshold); highByteThreshold = native2unicode(highByteThreshold);
    upmidByteThreshold = uint8(upmidByteThreshold); upmidByteThreshold = native2unicode(upmidByteThreshold);
    lowmidByteThreshold = uint8(lowmidByteThreshold); lowmidByteThreshold = native2unicode(lowmidByteThreshold);
    lowByteThreshold = uint8(lowByteThreshold); lowByteThreshold = native2unicode(lowByteThreshold);

    % Start the initial handshake. The computer first confirms the MCU is ready
    % by sending 'c' and expects a 'c' in return. This is repeated until
    % successful. Then, it sends the 32-bit threshold level to the MCU in byte
    % long packets. After each packet is sent, it expects response of 'k' to
    % confirm reception. If this fails during any of the four byte transfers,
    % the whole handshake is restarted. 

    comObject = get(handles.startButton,'UserData');
    picObject = comObject{1};
    agilentObj = comObject{2};

    fopen(picObject);

    handshakeComplete = 0;

    while(handshakeComplete == 0)
        fwrite(picObject,'c','uint8');
        picResponse = fread(picObject,1,'uint8');
        if(picResponse ~= 'c')
            continue
        end

        fwrite(picObject,highByteThreshold,'uint8');
        picResponse = fread(picObject,1,'uint8');
        if(picResponse ~= 'k')
            continue
        end

        fwrite(picObject,upmidByteThreshold,'uint8');
        picResponse = fread(picObject,1,'uint8');
        if(picResponse ~= 'k')
            continue
        end

        fwrite(picObject,lowmidByteThreshold,'uint8');
        picResponse = fread(picObject,1,'uint8');
        if(picResponse ~= 'k')
            continue
        end

        fwrite(picObject,lowByteThreshold,'uint8');
        picResponse = fread(picObject,1,'uint8');
        if(picResponse ~= 'k')
            continue
        end

        handshakeComplete = 1;    
    end

    fclose(picObject);
    picObject.BytesAvailableFcnMode = 'byte';
    picObject.BytesAvailableFcnCount = 1;
    picObject.BytesAvailableFcn = {@SerialCallback};
    fopen(picObject);
end
pauseOperation = 1;
set(handles.stopButton,'UserData',pauseOperation);
fprintf(picObject,'g'); % start the dsPIC sampling

function SerialCallback(obj, event)

%dataMat = fread(picObject,2,'int8');
%receivedCommand = fread(picObject,1,'uint8');
%flushinput(picObject);

%plotData = dataMat(1)*dataMat(2);

%fprintf('Received Data: %d \n',plotData);

graphHandle = handles.RmsPlot;

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
        %currentAmp = get(agilentObject,'Amplitude');
        %currentAmp = currentAmp + .01;
        %set(agilentObject, 'Amplitude', currentAmp);
    %if the received command is to lower the amplitude, decrease
    %it by 10 mVpp
    elseif(receivedCommand == 'l')
        %currentAmp = get(agilentObject,'Amplitude');
        %currentAmp = currentAmp - .01;
        %set(agilentObject, 'Amplitude', currentAmp);
    %if the received command is notifying of an "emergency" that the
    %emissions have hit a threshold with a significant probability of 
    %causing vessel rupture, low the amplitude by 100 mVpp
    elseif(receivedCommand == 'e')
        %currentAmp = get(agilentObject,'Amplitude');
        %currentAmp = currentAmp - .1;
        %set(agilentObject, 'Amplitude', currentAmp);
    elseif(receivedCommand == 's')
        %The command was to remain at the current voltage level. Do nothing
        %fprintf('Staying...\n');
    %if an unknown command was received, give a notification 
    elseif(receivedCommand == 'a')
        %set(agilentObject,'Output','Off');
        set(handles.transducerStatus,'String','Transducer Off');
        fwrite(picObject,'q','uint8'); % send dummy character to controller
                           % so it knows AWG was turned off
    elseif(receivedCommand == 'n')
        %set(agilentObject,'Output','On');
        set(handles.transducerStatus,'String','Transducer On');
        fprintf('Function Generator On\n');
        fwrite(picObject,'p','uint8'); % send dummy character to controller
                           % so it knows AWG was turned on
    else
        fprintf('Received unknown command "%s".\n',receivedCommand);
    end
elseif(serialID == -5) % if the net transmission is data
    dataMat = fread(picObject,1,'int32');   
    if(dataIndex < dataPlotLength)
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
