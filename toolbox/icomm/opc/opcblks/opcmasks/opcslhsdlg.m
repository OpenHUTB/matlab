function varargout=opcslhsdlg(varargin)












    gui_Singleton=0;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@opcslhsdlg_OpeningFcn,...
    'gui_OutputFcn',@opcslhsdlg_OutputFcn,...
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




    function opcslhsdlg_OpeningFcn(hObject,eventdata,handles,varargin)

        handles.output=hObject;

        guidata(hObject,handles);

        if length(varargin)>0,


            set([handles.edtHost,handles.edtServer,handles.edtTimeout],...
            {'String'},varargin{1});

            if length(varargin{1}{1})>0,
                set(handles.btnSelect,'Enable','on');
            end
        end



        function varargout=opcslhsdlg_OutputFcn(hObject,eventdata,handles)

            varargout{1}=handles.output;



            function edtHost_Callback(hObject,eventdata,handles)

                curHost=get(hObject,'String');
                if isempty(curHost),
                    set(handles.btnSelect,'Enable','off');
                else
                    set(handles.btnSelect,'Enable','on');
                end



                function edtHost_CreateFcn(hObject,eventdata,handles)
                    if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                        set(hObject,'BackgroundColor','white');
                    end



                    function edtServer_Callback(hObject,eventdata,handles)




                        function edtServer_CreateFcn(hObject,eventdata,handles)
                            if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                set(hObject,'BackgroundColor','white');
                            end



                            function edtTimeout_Callback(hObject,eventdata,handles)




                                function edtTimeout_CreateFcn(hObject,eventdata,handles)
                                    if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                        set(hObject,'BackgroundColor','white');
                                    end



                                    function btnSelect_Callback(hObject,eventdata,handles)

                                        hostName=get(handles.edtHost,'String');
                                        try

                                            set([handles.btnOK,handles.btnCancel,handles.btnSelect],'Enable','off');
                                            oldPtr=getptr(handles.dlgOPCHostServer);
                                            setptr(handles.dlgOPCHostServer,'watch');
                                            drawnow;
                                            si=opcserverinfo(hostName);
                                            set(handles.dlgOPCHostServer,oldPtr{:});
                                        catch ME
                                            set(handles.dlgOPCHostServer,oldPtr{:});
                                            set([handles.btnOK,handles.btnCancel,handles.btnSelect],'Enable','on');
                                            drawnow;
                                            errMsg=sprintf('Cannot get server list. Operation returned:\n''%s''',ME.message);
                                            uiwait(errordlg(errMsg,'OPC Configuration: Error','modal'));
                                            return;
                                        end
                                        if isempty(si.ServerID),
                                            warnMsg=sprintf('Host ''%s'' reports no OPC servers.',hostName);
                                            uiwait(warndlg(warnMsg,'OPC Configuration: Servers not found.','modal'));
                                            set([handles.btnOK,handles.btnCancel,handles.btnSelect],'Enable','on');
                                            drawnow;
                                            return;
                                        end
                                        [ind,ok]=listdlg('ListString',si.ServerID,...
                                        'SelectionMode','single',...
                                        'ListSize',[300,100],...
                                        'Name','OPC Configuration: Select Server',...
                                        'PromptString','Select the required server from the list:');
                                        if ok,
                                            set(handles.edtServer,'String',si.ServerID{ind});
                                        end
                                        set([handles.btnOK,handles.btnCancel,handles.btnSelect],'Enable','on');



                                        function btnOK_Callback(hObject,eventdata,handles)

                                            newData=strtrim(get([handles.edtHost,handles.edtServer,handles.edtTimeout],'String'));

                                            if length(newData{1})<1,
                                                uiwait(errordlg('Host value can not be empty.'));
                                                return;
                                            end

                                            if length(newData{2})<1,
                                                uiwait(errordlg('Server value can not be empty.'));
                                                return;
                                            end

                                            timeoutVal=str2double(newData{3});
                                            if timeoutVal<0||isnan(timeoutVal),
                                                uiwait(errordlg('Timeout value must be greater than 0.'));
                                                return;
                                            end

                                            setappdata(handles.dlgOPCHostServer,'serverData',newData);
                                            uiresume(handles.dlgOPCHostServer);



                                            function btnCancel_Callback(hObject,eventdata,handles)

                                                delete(handles.dlgOPCHostServer);



                                                function dlgOPCHostServer_CloseRequestFcn(hObject,eventdata,handles)

                                                    btnCancel_Callback(hObject,eventdata,handles);
