function varargout=opcslconfigdlg(varargin)

    gui_Singleton=0;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@opcslconfigdlg_OpeningFcn,...
    'gui_OutputFcn',@opcslconfigdlg_OutputFcn,...
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




    function opcslconfigdlg_OpeningFcn(hObject,eventdata,handles,varargin)%#ok

        if~usejava('jvm')
            uiwait(errordlg(...
            {'This dialog requires Java to open. You can run Simulink';...
            'models containing OPC blocks without Java, but you';...
            'cannot configure OPC blocks without Java. To enable';...
            'Java in MATLAB, run MATLAB without the -nojvm flag.'},...
            'OPC: Dialog requires Java',...
            'modal'));
            handles.output=[];
            guidata(hObject,handles);
            return
        end


        handles.output=hObject;

        guidata(hObject,handles);
        fontName=get(0,'DefaultUIControlFontName');
        set(findall(hObject,'Type','uicontrol'),'FontName',fontName);


        if length(varargin)>=1&&~iscell(varargin{1})
            error('opcblks:configdlg:syntax','Incorrect syntax.');
        end

        if ischar(varargin{1}{1})
            hBlock=get_param(varargin{1}{1},'Object');
        else
            hBlock=get(varargin{1}{1},'Object');
        end

        if~strcmp(hBlock.MaskType,'OPC Configuration'),
            error('opc:simulink:configBlockInvalid',...
            'Block passed to OPCSLCONFIGDLG is not an OPC Configuration block.');
        end

        if strcmp(hBlock.beingUsed,'off')
            delete(handles.dlgOPCConfig);
            response=questdlg({...
            'This block is not being used and is disabled. You should';...
            'delete this block from your model.';...
            '';...
            'Do you want to go to the enabled OPC Configuration block?'},...
            'OPC Configuration: Disabled Block','Yes','No','Yes');
            switch response
            case 'Yes'

                opcslconfigitf(hBlock,'HighlightUsed');
                return;
            otherwise
                return;
            end
        end

        existDlg=opcslconfigitf(hBlock,'GetOpenBlockDlg');
        if~isempty(existDlg),

            handles.output=[];
            guidata(hObject,handles);
            figure(existDlg);
            return;
        end
        handles.blockHandle=hBlock;
        guidata(hObject,handles);



        errCtrlStrings={'Error';'Warn';'None'};
        set(handles.popItmNotAvailable,'Value',...
        find(strcmp(hBlock.errMissingItems,errCtrlStrings)));
        set(handles.popReadWriteError,'Value',...
        find(strcmp(hBlock.errReadWrite,errCtrlStrings)));
        set(handles.popServerShutdown,'Value',...
        find(strcmp(hBlock.errShutdown,errCtrlStrings)));
        set(handles.popRTViolated,'Value',...
        find(strcmp(hBlock.errRTViolation,errCtrlStrings)));

        if strcmp(hBlock.rtEnable,'on')
            set(handles.chkEnableRT,'Value',1);
            ch=get(handles.pnlRealtimeControl,'Children');
            set(ch,'Enable','on');
        end
        set(handles.edtSpeedup,'String',...
        hBlock.speedup);
        set(handles.chkShowLatency,'Value',...
        strcmp(hBlock.showLatency,'on'));

        switch get_param(strtok(hBlock.Path,'/'),'SimulationStatus')
        case{'initializing','running','paused'}

            opcslconfigcb(hBlock,'StartFcn');
        end

        if isblocklibrary(hBlock)&&strcmp(get_param(strtok(hBlock.Path,'/'),'Lock'),'on'),



            set([handles.popItmNotAvailable,...
            handles.popServerShutdown,...
            handles.popReadWriteError,...
            handles.popRTViolated,...
            handles.chkEnableRT,...
            handles.edtSpeedup,...
            handles.chkShowLatency,...
            handles.btnApply],'Enable','off');
        end


        checkenable(handles);



        function varargout=opcslconfigdlg_OutputFcn(hObject,eventdata,handles)%#ok

            if isempty(handles.output),
                delete(handles.dlgOPCConfig);
            end
            varargout{1}=handles.output;



            function btnConfigClnts_Callback(hObject,eventdata,handles)%#ok

                hBlock=handles.blockHandle;
                opcslclntmgr(hBlock);



                function popItmNotAvailable_Callback(hObject,eventdata,handles)%#ok
                    checkenable(hObject);

                    hBlock=handles.blockHandle;
                    origVal=hBlock.errMissingItems;
                    allVals=get(hObject,'String');
                    if~strcmp(origVal,allVals{get(hObject,'Value')}),
                        set(handles.btnApply,'Enable','on');
                    end



                    function popItmNotAvailable_CreateFcn(hObject,eventdata,handles)%#ok
                        if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                            set(hObject,'BackgroundColor','white');
                        end
                        checkenable(hObject);



                        function popReadWriteError_Callback(hObject,eventdata,handles)%#ok

                            hBlock=handles.blockHandle;
                            origVal=hBlock.errReadWrite;
                            allVals=get(hObject,'String');
                            if~strcmp(origVal,allVals{get(hObject,'Value')}),
                                set(handles.btnApply,'Enable','on');
                            end



                            function popReadWriteError_CreateFcn(hObject,eventdata,handles)%#ok
                                if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                    set(hObject,'BackgroundColor','white');
                                end
                                checkenable(hObject);



                                function popServerShutdown_Callback(hObject,eventdata,handles)%#ok

                                    hBlock=handles.blockHandle;
                                    origVal=hBlock.errShutdown;
                                    allVals=get(hObject,'String');
                                    if~strcmp(origVal,allVals{get(hObject,'Value')}),
                                        set(handles.btnApply,'Enable','on');
                                    end



                                    function popServerShutdown_CreateFcn(hObject,eventdata,handles)%#ok
                                        if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                            set(hObject,'BackgroundColor','white');
                                        end
                                        checkenable(hObject);



                                        function popRTViolated_Callback(hObject,eventdata,handles)%#ok

                                            hBlock=handles.blockHandle;
                                            origVal=hBlock.errRTViolation;
                                            allVals=get(hObject,'String');
                                            if~strcmp(origVal,allVals{get(hObject,'Value')}),
                                                set(handles.btnApply,'Enable','on');
                                            end



                                            function popRTViolated_CreateFcn(hObject,eventdata,handles)%#ok
                                                if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                                    set(hObject,'BackgroundColor','white');
                                                end
                                                checkenable(hObject);



                                                function chkEnableRT_Callback(hObject,eventdata,handles)%#ok


                                                    set(handles.btnApply,'Enable','on');

                                                    enRT=get(hObject,'Value');
                                                    if enRT,
                                                        enStr='on';
                                                    else
                                                        enStr='off';
                                                    end
                                                    ch=get(handles.pnlRealtimeControl,'Children');
                                                    set(ch,'Enable',enStr);
                                                    set(hObject,'Enable','on');
                                                    checkenable(ch);



                                                    function edtSpeedup_Callback(hObject,eventdata,handles)%#ok

                                                        hBlock=handles.blockHandle;
                                                        origVal=str2double(hBlock.speedup);
                                                        applyEnable=false;
                                                        try
                                                            speedupVal=str2double(get(hObject,'String'));
                                                            applyEnable=(speedupVal~=origVal);
                                                        catch ME %#ok<NASGU>
                                                            speedupVal=NaN;
                                                        end
                                                        if isnan(speedupVal)||(speedupVal<=0)

                                                            uiwait(errordlg('Speedup value must be a scalar greater than 0.',...
                                                            'OPC Configuration: Error','modal'));
                                                            applyEnable=false;
                                                            speedupVal=origVal;
                                                        end
                                                        set(hObject,'String',num2str(speedupVal));

                                                        if applyEnable,
                                                            set(handles.btnApply,'Enable','on');
                                                        end



                                                        function edtSpeedup_CreateFcn(hObject,eventdata,handles)%#ok
                                                            if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                                                set(hObject,'BackgroundColor','white');
                                                            end
                                                            checkenable(hObject);



                                                            function chkShowLatency_Callback(hObject,eventdata,handles)%#ok

                                                                set(handles.btnApply,'Enable','on');



                                                                function btnOK_Callback(hObject,eventdata,handles)%#ok

                                                                    btnApply_Callback(hObject,eventdata,handles);
                                                                    close(handles.dlgOPCConfig);



                                                                    function btnCancel_Callback(hObject,eventdata,handles)%#ok

                                                                        close(handles.dlgOPCConfig);



                                                                        function btnHelp_Callback(hObject,eventdata,handles)%#ok
                                                                            helpview("icomm","block_opc_configuration");



                                                                            function btnApply_Callback(hObject,eventdata,handles)%#ok

                                                                                hBlock=handles.blockHandle;
                                                                                if~isempty(hBlock),

                                                                                    if isblocklibrary(hBlock)&&strcmp(get_param(strtok(hBlock.Path,'/'),'Lock'),'on'),
                                                                                        return;
                                                                                    end

                                                                                    errCtrlStrings={'Error';'Warn';'None'};
                                                                                    errStr=errCtrlStrings{get(handles.popItmNotAvailable,'Value')};
                                                                                    hBlock.errMissingItems=errStr;
                                                                                    errStr=errCtrlStrings{get(handles.popReadWriteError,'Value')};
                                                                                    hBlock.errReadWrite=errStr;
                                                                                    errStr=errCtrlStrings{get(handles.popServerShutdown,'Value')};
                                                                                    hBlock.errShutdown=errStr;
                                                                                    errStr=errCtrlStrings{get(handles.popRTViolated,'Value')};
                                                                                    hBlock.errRTViolation=errStr;

                                                                                    offOnStr={'off','on'};
                                                                                    enableRT=get(handles.chkEnableRT,'Value');
                                                                                    hBlock.rtEnable=offOnStr{enableRT+1};
                                                                                    speedup=get(handles.edtSpeedup,'String');
                                                                                    hBlock.speedup=speedup;
                                                                                    showLat=get(handles.chkShowLatency,'Value');
                                                                                    hBlock.showLatency=offOnStr{showLat+1};
                                                                                end

                                                                                set(hObject,'Enable','off');



                                                                                function serverbuttonsenable(handles)%#ok

                                                                                    sI=get(handles.lstServers,'Value');
                                                                                    if isempty(sI),
                                                                                        en='off';
                                                                                    else

                                                                                        en='on';
                                                                                    end
                                                                                    set([handles.btnDelete,handles.btnEdit],'Enable',en);


