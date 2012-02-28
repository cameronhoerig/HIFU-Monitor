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

% Last Modified by GUIDE v2.5 26-Feb-2012 20:09:19

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


% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in increaseButton.
function increaseButton_Callback(hObject, eventdata, handles)
% hObject    handle to increaseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in decreaseButton.
function decreaseButton_Callback(hObject, eventdata, handles)
% hObject    handle to decreaseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
