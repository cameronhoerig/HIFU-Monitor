function varargout = blochGui(varargin)
% BLOCHGUI MATLAB code for blochGui.fig
%      BLOCHGUI, by itself, creates a new BLOCHGUI or raises the existing
%      singleton*.
%
%      H = BLOCHGUI returns the handle to a new BLOCHGUI or the handle to
%      the existing singleton*.
%
%      BLOCHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BLOCHGUI.M with the given input arguments.
%
%      BLOCHGUI('Property','Value',...) creates a new BLOCHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before blochGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to blochGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help blochGui

% Last Modified by GUIDE v2.5 11-Mar-2012 20:36:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @blochGui_OpeningFcn, ...
                   'gui_OutputFcn',  @blochGui_OutputFcn, ...
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


% --- Executes just before blochGui is made visible.
function blochGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to blochGui (see VARARGIN)

% Choose default command line output for blochGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes blochGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% initialize bloch sphere
blochaxes = handles.blochAxes;
blochHandle = blochSpherePlot(blochaxes,0,0);

% --- Outputs from this function are returned to the command line.
function varargout = blochGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function thetaSlider_Callback(hObject, eventdata, handles)
% hObject    handle to thetaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
thetaSlide = get(handles.thetaSlider,'Value');
thetaNew = thetaSlide*pi();
set(handles.thetaLabel,'String',num2str(thetaNew));


% --- Executes during object creation, after setting all properties.
function thetaSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thetaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function phiSlider_Callback(hObject, eventdata, handles)
% hObject    handle to phiSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
phiSlide = get(handles.phiSlider,'Value');
phiNew = phiSlide*pi()*2;
set(handles.phiLabel,'String',num2str(phiNew));

% --- Executes during object creation, after setting all properties.
function phiSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phiSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in animateButton.
function animateButton_Callback(hObject, eventdata, handles)
% hObject    handle to animateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
thetaEnd = get(handles.thetaLabel,'String');
thetaEnd = str2num(thetaEnd);
phiEnd = get(handles.phiLabel,'String');
phiEnd = str2num(phiEnd);
blochaxes = handles.blochAxes;
AnimateBlochSphere(blochaxes,0,thetaEnd,0,phiEnd);


% --- Executes on slider movement.
function measurementSlider_Callback(hObject, eventdata, handles)
% hObject    handle to measurementSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
measureSlide = get(handles.measurementSlider,'Value');
measureNew = floor(measureSlide*100);
set(handles.measurementLabel,'String',num2str(measureNew));

% --- Executes during object creation, after setting all properties.
function measurementSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measurementSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in zenoButton.
function zenoButton_Callback(hObject, eventdata, handles)
% hObject    handle to zenoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
thetaEnd = get(handles.thetaLabel,'String');
thetaEnd = str2num(thetaEnd);
phiEnd = get(handles.phiLabel,'String');
phiEnd = str2num(phiEnd);
blochaxes = handles.blochAxes;
numMeasurements = get(handles.measurementLabel,'String');
numMeasurements = str2num(numMeasurements);
ZenoBlochSphere(blochaxes,0,thetaEnd,0,phiEnd,numMeasurements);
