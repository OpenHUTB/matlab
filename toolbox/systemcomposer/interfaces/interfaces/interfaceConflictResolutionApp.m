function varargout=interfaceConflictResolutionApp(varargin)


























    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@interfaceConflictResolutionApp_OpeningFcn,...
    'gui_OutputFcn',@interfaceConflictResolutionApp_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function interfaceConflictResolutionApp_OpeningFcn(hObject,~,handles,varargin)







        handles.src=varargin{1};
        handles.dst=varargin{2};
        handles.collisions=varargin{3};

        handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;

        handles.ListBoxPanel.Title=message('SystemArchitecture:Interfaces:ICRD_ListBox_Title',handles.dst).getString;

        handles.ListBox.String=handles.collisions;

        handles.ButtonGroup.Title=message('SystemArchitecture:Interfaces:ICRD_ButtonGroup_Title').getString;

        handles.UseSource.String=message('SystemArchitecture:Interfaces:ICRD_ButtonGroup_UseSourceOrTarget',handles.src).getString;
        handles.UseSource.Tooltip=message('SystemArchitecture:Interfaces:ICRD_ButtonGroup_UseSource_Tooltip',handles.dst,handles.src).getString;

        handles.UseTarget.String=message('SystemArchitecture:Interfaces:ICRD_ButtonGroup_UseSourceOrTarget',handles.dst).getString;
        handles.UseTarget.Tooltip=message('SystemArchitecture:Interfaces:ICRD_ButtonGroup_UseTarget_Tooltip',handles.dst,handles.src).getString;

        handles.Cancel.String=message('SystemArchitecture:Interfaces:ICRD_ButtonGroup_Cancel').getString;

        handles.Continue.String=message('SystemArchitecture:Interfaces:ICRD_Continue').getString;

        if(nargin>6)
            handles.testMode=varargin{4};
        else
            handles.testMode='';
        end



        guidata(hObject,handles);

        if(~isempty(handles.testMode))
            if(handles.testMode=="UseTarget")
                feval(get(handles.UseTarget,'Callback'),handles.UseTarget,[]);
            elseif(handles.testMode=="UseSource")
                feval(get(handles.UseSource,'Callback'),handles.UseSource,[]);
            elseif(handles.testMode=="Cancel")
                feval(get(handles.Cancel,'Callback'),handles.Cancel,[]);
            end
            feval(get(handles.Continue,'Callback'),handles.Continue,[]);
        end



        function varargout=interfaceConflictResolutionApp_OutputFcn(hObject,eventdata,handles)





            if(isempty(handles.testMode))
                uiwait(handles.InterfaceConflictDialog);
            end


            if(isvalid(hObject))
                handles=guidata(hObject);
                varargout{1}=handles.collisionResolutionOption;
                if(~isempty(handles.testMode))
                    varargout{2}=handles.ListBoxPanel.Title;
                    varargout{3}=handles.ListBox.String;
                    varargout{4}=handles.UseSource.String;
                    varargout{5}=handles.UseSource.Tooltip;
                    varargout{6}=handles.UseTarget.String;
                    varargout{7}=handles.UseTarget.Tooltip;
                end
            else
                varargout{1}=systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;
            end


            delete(hObject);



            function Cancel_Callback(hObject,~,handles)





                handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;


                guidata(hObject,handles);


                function UseSource_Callback(hObject,~,handles)





                    handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.REPLACE_DST;


                    guidata(hObject,handles);


                    function UseTarget_Callback(hObject,~,handles)





                        handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.KEEP_DST;


                        guidata(hObject,handles);


                        function ListBox_CreateFcn(hObject,~,handles)






                            if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                set(hObject,'BackgroundColor','white');
                            end



                            function Continue_Callback(hObject,~,handles)





                                if(isempty(handles.testMode))
                                    uiresume();
                                end
