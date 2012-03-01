function varargout = DataGui(varargin)
%DATAGUI M-file for DataGui.fig
%      DATAGUI, by itself, creates a new DATAGUI or raises the existing
%      singleton*.
%
%      H = DATAGUI returns the handle to a new DATAGUI or the handle to
%      the existing singleton*.
%
%      DATAGUI('Property','Value',...) creates a new DATAGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to DataGui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DATAGUI('CALLBACK') and DATAGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DATAGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataGui

% Last Modified by GUIDE v2.5 21-Oct-2011 17:31:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataGui_OpeningFcn, ...
                   'gui_OutputFcn',  @DataGui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before DataGui is made visible.
function DataGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for DataGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in transform_button.
function transform_button_Callback(hObject, eventdata, handles)
% hObject    handle to transform_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TransformData
msgbox('Complete data analysis has finished')
guidata(hObject,handles);


% --- Executes on button press in readData_button.
function readData_button_Callback(hObject, eventdata, handles)
% hObject    handle to readData_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
readInData
msgbox('Finished reading in data')
guidata(hObject,handles);

% --- Executes on button press in fftAverage_button.
function fftAverage_button_Callback(hObject, eventdata, handles)
% hObject    handle to fftAverage_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FFTAverage
msgbox('FFT averaging has finished')
guidata(hObject,handles);

% --- Executes on button press in lowFrequency_button.
function lowFrequency_button_Callback(hObject, eventdata, handles)
% hObject    handle to lowFrequency_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BoilingPowerSpec
msgbox('Low frequency analysis has finished')
guidata(hObject,handles);

% --- Executes on button press in highFrequency_button.
function highFrequency_button_Callback(hObject, eventdata, handles)
% hObject    handle to highFrequency_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CavPowerSpec
msgbox('Broadband analysis has finished')
guidata(hObject,handles);

% --- Executes on button press in plotTime_button.
function plotTime_button_Callback(hObject, eventdata, handles)
% hObject    handle to plotTime_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.plotTime_popup,'UserData'); index = num2str(index);
tempstr = '00000';
tempstr(end-length(index)+1:end) = index;
loadtrace = strcat('C2Trace',tempstr,'.trc');
tempstr = readlecroy(loadtrace);
x = tempstr.x;
readData = tempstr.y/200;
h = figure;
plot(x,readData,'r');
xlabel('Time (s)');
ylabel('Amplitude (v)');
xlim([x(1) x(end)])
title(strcat('Plot of Amplitude vs Time for Sonication ',num2str(index)));
guidata(hObject,handles);

% --- Executes on button press in plotFrequency_button.
function plotFrequency_button_Callback(hObject, eventdata, handles)
% hObject    handle to plotFrequency_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%list = get(handles.plotTime_popup,'String');
%index = get(handles.plotTime_popup,'UserData');
%load(strcat(list{index},'.mat'));
index = get(handles.plotTime_popup,'UserData'); index = num2str(index);
tempstr = '00000';
tempstr(end-length(index)+1:end) = index;
loadtrace = strcat('C2Trace',tempstr,'.trc');
tempstr = readlecroy(loadtrace);
tempx = tempstr.x;
x = tempstr.x;
list = get(handles.plotFreq_popup,'String');
index = get(handles.plotFreq_popup,'UserData'); 
load(strcat(list{index},'.mat'));
index = num2str(index-1);
tempstr = '00000';
tempstr(end-length(index)+1:end) = index;
loadtrace = strcat('C2Trace',tempstr,'.trc');
tempstr = readlecroy(loadtrace);
readData = tempstr.y;

    fftsize = ceil(fs/10000);
    fftsize = pow2(nextpow2(fftsize));
    numSegments = floor(length(readData)/fftsize);
    arrayBounds = 1;
    newN = fftsize;
    Y = zeros(newN,1);
    fulltraces = zeros(numSegments,newN);
       
    for count=1:numSegments
        tempSegment = readData(arrayBounds:arrayBounds+fftsize-1);
        tempfft = abs(fft(tempSegment,newN));
        tempfft = tempfft.^2;
        %tempfft = tempfft.*conj(tempfft);
        Y = Y+tempfft;
        fulltraces(count,:) = tempfft;
        arrayBounds = arrayBounds+fftsize;      
    end

    Y = Y/numSegments;
    Y = 10*log10(Y);
    Y = fftshift(Y);
    Y = Y(length(Y)/2+1:end);
    fulltraces = fftshift(fulltraces(:,:));
    fulltraces = fulltraces(:,newN/2+1:end);
    fulltraces = 10*log10(fulltraces);
    newk = -newN/2:newN/2-1;
    newk = newk(length(newk)/2+1:end);
    
[row,col] = size(fulltraces);
col = linspace(0,fs/2,col);
row = linspace(0,x(end),row);
%fulltraces = 10*log10(fulltraces);
figure
imagesc(col,row,fulltraces,[0 max(max(fulltraces,[],2))])
shading interp
xlabel('Frequency (Hz)')
ylabel('Time (s)')
colorbar
index = str2num(index);
title(strcat('Spectrogram for Sonication ',num2str(index+1)));
colorbar
Y = 10*log10(Y);
h = figure;
plot(newk*fs/newN,Y,'k');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title(strcat('Plot of Average Power vs Frequency for Sonication ',num2str(index+1)));
guidata(hObject,handles);

% --- Executes on button press in choosePath_button.
function choosePath_button_Callback(hObject, eventdata, handles)
% hObject    handle to choosePath_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
returnDir = cd;

saveFile = uigetdir;
cd('D:\Users\Cameron\Documents\MATLAB\Work\Trace Files\GUI');
copyfile('TransformData.m',saveFile)
copyfile('BoilingPowerSpec.m',saveFile)
copyfile('CavPowerSpec.m',saveFile)
copyfile('FFTAverage.m',saveFile)
%copyfile('TraceDataTransform.m',saveFile)
copyfile('readlecroy.m',saveFile)
copyfile('isHere.m',saveFile)
copyfile('MidPowerSpec.m',saveFile)
copyfile('FlowAndTraceSync.m',saveFile)
copyfile('FlowDataInterp.m',saveFile)
copyfile('GetTime.m',saveFile)
copyfile('RetrieveFlowData.m',saveFile)
copyfile('Data2Text.m',saveFile)
%copyfile('FFTSectionPowers.m',saveFile)
cd(saveFile);
set(handles.selectedPath_textbox,'String',saveFile);
numFiles = countData;
setfreq = cell(1,numFiles);
settime = cell(1,numFiles);
setsections = cell(1,numFiles);
for count=1:numFiles
    setfreq{count} = strcat('aveTrace',num2str(count));
    settime{count} = strcat('Trace ',num2str(count));
    setsections{count} = strcat('Trace ',num2str(count));
end
set(handles.plotTime_popup,'String',settime);
set(handles.plotFreq_popup,'String',setfreq);
set(handles.fftsections_menu,'String',setsections);
clear setfreq
clear settime

function [w]=countData()
% Count the number of trace files in a given directory
curDir = dir;
numTraces = 0;
for count=1:length(curDir);
    if length(curDir(count).name) >= 16
        if strcmp(curDir(count).name(14:16),'trc')
            numTraces = numTraces+1;
        end
    end
end
w = numTraces;
clear numTraces


function readInData()
% Reads in .trc files and converts to vectors
try
        fprintf('Reading in Data...\n');
        count = 0;
       
        while count < 10000
            if count < 10
                fid = strcat('C2Trace0000',num2str(count),'.trc');
            elseif count < 100
                fid = strcat('C2Trace000',num2str(count),'.trc');
            elseif count < 1000
                fid = strcat('C2Trace00',num2str(count),'.trc');
            elseif count < 10000
                fid = strcat('C2Trace0',num2str(count),'.trc');
            else
                fid = strcat('C2Trace',num2str(count),'.trc');
            end
            
            fileFound = isHere(fid);
            
            if fileFound
                w = readlecroy(fid);
                readData = w.y;
                x = w.x;
                
               fs = w.info.SampleRate;
               loc = find(fs=='M');
               fs = str2num(fs(1:loc(1)-1));
               fs = fs*1000000;
                    
               %N = pow2(nextpow2(length(readData)));
               %k = -N/2:N/2-1;
               %k = k(length(k)/2+1:end);
               %save('traceParams.mat','N','k','fs');
               
               saveFile = strcat('dataread',num2str(count+1));
               disp(saveFile);
               save(saveFile,'readData','fs','x');
            else
                
                fileFound = isHere('C2Trace00015.trc');
                
                if fileFound && count < 15
                    % Continue in loop
                else
                   if count < 10
                        fid = strcat('C2Trace0000',num2str(count+1),'.trc');
                   elseif count < 100
                        fid = strcat('C2Trace000',num2str(count+1),'.trc');
                   elseif count < 1000
                        fid = strcat('C2Trace00',num2str(count+1),'.trc');
                   else 
                        fid = strcat('C2Trace0',num2str(count+1),'.trc');
                   end
                   
                   fileFound = isHere(fid);
                   
                   if fileFound
                       %continue
                   else
                        fprintf('Reached end of captures\n');
                        break
                   end
                end
             end
             count = count+1;
          end
       
catch
        fprintf('Error reading in data.\n');
end

% --- Executes on selection change in plotTime_popup.
function plotTime_popup_Callback(hObject, eventdata, handles)
% hObject    handle to plotTime_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotTime_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotTime_popup
index = get(hObject,'Value');
set(hObject,'UserData',index);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function plotTime_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotTime_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotFreq_popup.
function plotFreq_popup_Callback(hObject, eventdata, handles)
% hObject    handle to plotFreq_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotFreq_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotFreq_popup
index = get(hObject,'Value');
set(hObject,'UserData',index);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function plotFreq_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotFreq_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotBand_button.
function plotBand_button_Callback(hObject, eventdata, handles)
% hObject    handle to plotBand_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file1Found = isHere('boilpowerSpec.mat');
file2Found = isHere('cavpowerSpec.mat');
if file1Found && file2Found
    load boilpowerSpec
    load cavpowerSpec
    load midpowerSpec
    figure
    plot(inputValues,boilSaveSpec,'r')
    hold on
    plot(inputValues,cavSaveSpec,'k');
    plot(inputValues,midSaveSpec,'g');
    hold off
    legend('Low Frequency (10KHz-30KHz)','Broadband (300KHz-1.1MHz)','Midband (30KHz-100KHz)');
    xlabel('Sonication Number or Time (s)');
    ylabel('Power (dB)');
    title('Power in Low Frequency and Broadband Emissions Over Time');
  
else
    msgbox('Low Frequency and Broadband Emissions must be analyzed first!');
end
%{
try
    FlowAndTraceSync
catch
    msgbox('An error occurred while trying to run the script FlowAndTraceSync')
end
%}
guidata(hObject,handles);


% --- Executes on button press in fftsections_button.
function fftsections_button_Callback(hObject, eventdata, handles)
% hObject    handle to fftsections_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.fftsections_menu,'UserData'); index = num2str(index);
tempstr = '00000';
tempstr(end-length(index)+1:end) = index;
fid = strcat('C2Trace',tempstr,'.trc');
w = readlecroy(fid);
readData = w.y;
x = w.x;
fs = w.info.SampleRate;
loc = find(fs=='M');
fs = str2num(fs(1:loc(1)-1));
fs = fs*1000000;

    fftsize = ceil(fs/10000);
    fftsize = pow2(nextpow2(fftsize));
    numSegments = floor(length(readData)/fftsize);
    count = 1;
    arrayBounds = 1;
    newN = fftsize;
    Y = zeros(newN,1);
    lowfreqpowers = zeros(1,numSegments);
    broadbandpowers = zeros(1,numSegments);
    midbandpowers = zeros(1,numSegments);
    while count <= numSegments
        Y = readData(arrayBounds:arrayBounds+fftsize);
        Y = abs(fft(Y,newN));
        Y = Y.^2;
        Y = fftshift(Y);
        Y = Y(length(Y)/2+1:end);
        
        scaleFactor = newN/fs;
        
        %Integrate for low frequency emission
        lowerLimit = floor(10000*scaleFactor);
        upperLimit = ceil(30000*scaleFactor);        
        new = Y(lowerLimit:upperLimit);
        powerSum = trapz(new);
        %powerSum = 10*log10(powerSum);
        lowfreqpowers(count) = powerSum;
        
        %Integrate for broadband emissions
        lowerLimit = floor(300000*scaleFactor);
        upperLimit = ceil(1100000*scaleFactor);
        new = Y(lowerLimit:upperLimit);
        powerSum = trapz(new);
        %powerSum = 10*log10(powerSum);
        broadbandpowers(count) = powerSum;
        
        %Integrate for midband emissions
        lowerLimit = floor(30000*scaleFactor);
        upperLimit = ceil(100000*scaleFactor);
        new = Y(lowerLimit:upperLimit);
        powerSum = trapz(new);
        %powerSum = 10*log10(powerSum);
        midbandpowers(count) = powerSum;
        
        count = count+1;
        arrayBounds = arrayBounds+fftsize;      
    end
%%{
lowfreqpowers = 10*log10(lowfreqpowers);
midbandpowers = 10*log10(midbandpowers);
broadbandpowers = 10*log10(broadbandpowers);
%}
time = linspace(x(1),x(end),length(lowfreqpowers));
if ~exist('ins','var')
    ins = 1:length(lowfreqpowers);
end
%{
figure;
plot(time,lowfreqpowers,'r');
xlim([time(1) time(end)])
xlabel('Section Number');
%ylabel('Power (dB)');
title(strcat('Plot of Low Frequency Emissions vs Time for SectionPowers',num2str(index)));
figure;
plot(time,broadbandpowers,'k');
xlim([time(1) time(end)])
xlabel('Section Number');
%ylabel('Power (dB)');
title(strcat('Plot of Broadband Emissions vs Time for SectionPowers',num2str(index)));
figure;
plot(time,midbandpowers,'b');
xlim([time(1) time(end)])
xlabel('Section Number');
%ylabel('Power (dB)');
title(strcat('Plot of Midband Emissions vs Time for SectionPowers',num2str(index)));
%}
max1 = max(lowfreqpowers);min1 = min(lowfreqpowers);
max2 = max(broadbandpowers);min2 = min(broadbandpowers);
max3 = max(midbandpowers);min3 = min(midbandpowers);
maxy = max([max1 max2 max3]);
miny = min([min1 min2 min3]);

clear max1 max2 max3 min1 min2 min3

figure
scatter(time,lowfreqpowers,'o','r');
hold on
scatter(time,broadbandpowers,'*','k');
scatter(time,midbandpowers,'x','g');
xlim([time(1) time(end)]);
ylim([miny maxy])
xlabel('Time (s)')
ylabel('Amplitude')
title('Frequency Band Amplitude VS Time for a Single Sonication');
guidata(hObject,handles);

% --- Executes on selection change in fftsections_menu.
function fftsections_menu_Callback(hObject, eventdata, handles)
% hObject    handle to fftsections_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fftsections_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fftsections_menu
index = get(hObject,'Value');
set(hObject,'UserData',index);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function fftsections_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fftsections_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_Spectrogram.
function plot_Spectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to plot_Spectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load aveTrace1
load boilpowerSpec
holdall = zeros(length(inputValues),length(Y));
for count=1:length(inputValues)
    mat = strcat('aveTrace',num2str(count),'.mat');
    load(mat)
    holdall(count,:) = Y;
end

x = linspace(0,fs/2,length(Y));
y = linspace(1,length(inputValues),length(inputValues));
holdall = 10*log10(holdall);
figure
imagesc(x,y,holdall,[0 max(max(holdall,[],2))]);
colorbar
title('Spectrogram of Average Acoustic Emissions for Series of Sonications');
xlabel('Frequency (Hz)')
ylabel('Sonication Number or Time (s)')
guidata(hObject,handles);


% --- Executes on button press in band_and_flow_plot.
function band_and_flow_plot_Callback(hObject, eventdata, handles)
% hObject    handle to band_and_flow_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flowAvailable = FlowAndTraceSync();
if ~flowAvailable
    msgbox('No flow data found!');
end
guidata(hObject,handles);


% --- Executes on button press in data_2_text.
function data_2_text_Callback(hObject, eventdata, handles)
% hObject    handle to data_2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data2Text;
guidata(hObject,handles);
