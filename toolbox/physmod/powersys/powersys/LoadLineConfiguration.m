function varargout=LoadLineConfiguration(varargin)










    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@LoadLineConfiguration_OpeningFcn,...
    'gui_OutputFcn',@LoadLineConfiguration_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin&isstr(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function LoadLineConfiguration_OpeningFcn(hObject,eventdata,handles,varargin)

        handles.output=hObject;
        handles.LoadButtonHandle=varargin{1};

        guidata(hObject,handles);



        function varargout=LoadLineConfiguration_OutputFcn(hObject,eventdata,handles)

            varargout{1}=handles.output;



            function pushbutton1_Callback(hObject,eventdata,handles)
                set(handles.LoadButtonHandle,'UserData',1);
                close(handles.figure1);


                function pushbutton3_Callback(hObject,eventdata,handles)
                    set(handles.LoadButtonHandle,'UserData',2);
                    close(handles.figure1);
