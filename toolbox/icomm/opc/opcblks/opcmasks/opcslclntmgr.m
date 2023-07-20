function varargout=opcslclntmgr(varargin)








    gui_Singleton=0;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@opcslclntmgr_OpeningFcn,...
    'gui_OutputFcn',@opcslclntmgr_OutputFcn,...
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




    function opcslclntmgr_OpeningFcn(hObject,eventdata,handles,varargin)%#ok<*INUSL,*DEFNU>

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
        fontName=get(0,'DefaultUIControlFontName');
        set(findall(hObject,'Type','uicontrol'),'FontName',fontName);

        guidata(hObject,handles);

        if isempty(varargin),
            error('opc:simulink:callingSyntax','Incorrect calling syntax.');
        else
            if ischar(varargin{1})
                hBlock=get_param(varargin{1},'Object');
            else
                hBlock=get(varargin{1},'Object');
            end

            existDlg=opcslclntmgritf(hBlock,'GetOpenClntMgr');
            if~isempty(existDlg),

                handles.output=[];
                guidata(hObject,handles);
                figure(existDlg);
                return;
            end

            mdlName=strtok(hBlock.Path,'/');
            set(hObject,'Name',...
            sprintf('OPC Client Manager (%s)',mdlName));

            hBlkConfig=opcslconfigitf(hBlock,'FindUsed');
            if isempty(hBlkConfig),
                close(hObject);
                error('opc:simulink:noConfigBlock',...
                'Could not find OPC Configuration block for this model.');
            end

            handles.blockHandle=hBlkConfig;
            guidata(hObject,handles);

            opcslclntmgritf(hBlkConfig,'RefreshClientList',handles);

            switch get_param(strtok(hBlock.Path,'/'),'SimulationStatus')
            case{'initializing','running','paused'}

                opcslclntmgritf(hBlock,'SetDialogForStart');
            end
        end


        if isblocklibrary(hBlock)&&strcmp(get_param(strtok(hBlock.Path,'/'),'Lock'),'on'),
            set([handles.btnAdd,...
            handles.btnDelete,...
            handles.btnConnect,...
            handles.btnDisconnect,...
            handles.btnEdit,handles.lstOPCClient],'Enable','off');
        end

        checkenable(handles);



        function varargout=opcslclntmgr_OutputFcn(hObject,eventdata,handles)

            if isempty(handles.output),
                delete(handles.dlgOPCClntMgr);
            end
            varargout{1}=handles.output;



            function lstOPCClient_Callback(hObject,eventdata,handles)

                buttonsenable(handles);



                function lstOPCClient_CreateFcn(hObject,eventdata,handles)%#ok<*INUSD>
                    if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                        set(hObject,'BackgroundColor','white');
                    end



                    function btnAdd_Callback(hObject,eventdata,handles)


                        hDlg=opcslhsdlg({'localhost';'';'10'});
                        uiwait(hDlg);
                        if ishandle(hDlg),
                            vals=getappdata(hDlg,'serverData');
                            delete(hDlg);

                            if~isempty(vals{1})
                                allClnts=opcslclntmgritf(handles.blockHandle,'GetClientList');
                                existInd=opcslclntmgritf(handles.blockHandle,'GetClientIndex',vals{1:2});
                                if~isempty(existInd),

                                    errMsg=sprintf([...
                                    'Specified server is already in the list.\n',...
                                    'Do you want to Modify the timeout value of\n',...
                                    'the existing entry, or Cancel the add operation?']);
                                    result=questdlg(errMsg,'OPC Configuration: Entry Exists',...
                                    'Modify','Cancel','Cancel');
                                    switch result
                                    case 'Modify'
                                        allClnts(existInd).timeout=str2double(vals{3});%#ok<NASGU>

                                        opcslclntmgritf(handles.blockHandle,'RefreshClientList',handles);
                                        set(handles.lstOPCClient,'Value',existInd);
                                    otherwise
                                        return
                                    end
                                else

                                    clntInd=opcslclntmgritf(handles.blockHandle,'AddClient',vals{:});
                                    if~isempty(clntInd),
                                        set(handles.lstOPCClient,'Value',clntInd);
                                    end
                                end
                                buttonsenable(handles);
                            end
                        end



                        function btnDelete_Callback(hObject,eventdata,handles)

                            thisClnt=getcurrentclient(handles);
                            allClnts=opcslclntmgritf(handles.blockHandle,'GetClientList');
                            cI=get(handles.lstOPCClient,'Value');
                            configBlk=handles.blockHandle;
                            blkUsers=opcslclntmgritf(configBlk,'GetClientUsers',thisClnt);
                            if~isempty(blkUsers),

                                if length(allClnts)==1,
                                    response=questdlg({...
                                    'This client is being used by other OPC blocks. You cannot';...
                                    'delete this client without deleting the other blocks.';...
                                    '';...
                                    'Do you want to delete the blocks that use this client, or';...
                                    'cancel the delete operation?'},...
                                    'OPC Client Manager: Client in use',...
                                    'Delete','Cancel','Cancel');
                                else
                                    response=questdlg({...
                                    'This client is being used by other OPC blocks. You cannot';...
                                    'delete this client without deleting the other blocks or';...
                                    'changing those blocks to use another client.';...
                                    '';...
                                    'Do you want to delete the blocks that use this client,';...
                                    'replace the client in those blocks with another, or';...
                                    'cancel the delete operation?'},...
                                    'OPC Client Manager: Client in use',...
                                    'Delete','Replace','Cancel','Cancel');
                                end
                                switch response
                                case 'Delete'

                                    for bI=1:length(blkUsers),
                                        delete_block(blkUsers{bI});
                                    end
                                case 'Replace'

                                    allStr=get(handles.lstOPCClient,'String');
                                    allStr(cI)=[];

                                    tempClnts=allClnts;
                                    tempClnts(cI)=[];
                                    [newInd,ok]=listdlg('ListString',allStr,...
                                    'Name','OPC Client Manager: Select alternate client',...
                                    'SelectionMode','single',...
                                    'PromptString','Choose new client for blocks:',...
                                    'ListSize',[300,160]);
                                    if ok,

                                        newClnt=tempClnts(newInd);
                                        for bI=1:length(blkUsers)
                                            set_param(blkUsers{bI},'serverHost',newClnt.Host);
                                            set_param(blkUsers{bI},'serverID',newClnt.ServerID);














                                        end
                                    else
                                        return
                                    end
                                    response='Delete';
                                otherwise
                                    return;
                                end
                            else


                                response=questdlg('Client deletion is immediate. Confirm deletion of client.',...
                                'OPC Client Manager: Confirm deletion',...
                                'Delete','Cancel','Cancel');
                            end
                            if strcmp(response,'Delete'),

                                disconnect(thisClnt);
                                delete(thisClnt);
                                if length(allClnts)>1,
                                    allClnts(cI)=[];
                                else
                                    allClnts=[];
                                end

                                opcslclntmgritf(configBlk,'SetClientList',allClnts);
                            end



                            function btnEdit_Callback(hObject,eventdata,handles)


                                thisClient=getcurrentclient(handles);
                                origTimeout=num2str(thisClient.timeout);
                                dlgPrompt={'Timeout:'};
                                dlgName='OPC Client Manager: Edit Timeout';
                                dlgOptions=struct('WindowStyle','modal','Interpreter','none');
                                newTimeout=inputdlg(dlgPrompt,dlgName,1,{origTimeout},dlgOptions);
                                if~isempty(newTimeout)
                                    try
                                        newVal=str2double(newTimeout);
                                    catch ME %#ok<NASGU>
                                        newVal=-1;
                                    end
                                    if~isscalar(newVal)||newVal<0||isnan(newVal),
                                        uiwait(errordlg('Timeout must be a scalar non-negative value.',...
                                        'OPC Client Manager: Timeout Incorrect','modal'));
                                        newVal=thisClient.timeout;
                                    end
                                    if newVal~=thisClient.timeout,
                                        thisClient.timeout=newVal;
                                    end
                                end
                                opcslclntmgritf(handles.blockHandle,'RefreshClientList',handles);



                                function btnConnect_Callback(hObject,eventdata,handles)

                                    thisClnt=getcurrentclient(handles);
                                    if opcslclntmgritf(handles.blockHandle,'ConnectClientObject',thisClnt);
                                        opcslclntmgritf(handles.blockHandle,'RefreshClientList',handles);
                                    end



                                    function btnDisconnect_Callback(hObject,eventdata,handles)

                                        thisClnt=getcurrentclient(handles);
                                        try
                                            disconnect(thisClnt);
                                        catch ME
                                            uiwait(warndlg(sprintf('Could not disconnect from client. Error returned was:\n''%s''',ME.message),...
                                            'OPC Client Manager: Could not disconnect','modal'));
                                        end
                                        opcslclntmgritf(handles.blockHandle,'RefreshClientList',handles);



                                        function btnClose_Callback(hObject,eventdata,handles)
                                            delete(handles.dlgOPCClntMgr);



                                            function btnHelp_Callback(hObject,eventdata,handles)
                                                helpview("icomm","block_opc_quality_parts");



                                                function buttonsenable(handles)

                                                    sI=get(handles.lstOPCClient,'Value');
                                                    enED='off';
                                                    enConn='off';
                                                    enDis='off';
                                                    if~isempty(sI),

                                                        enED='on';

                                                        clntInfo=getcurrentclient(handles);
                                                        if~isempty(clntInfo)
                                                            if strcmpi(clntInfo.status,'connected'),
                                                                enDis='on';
                                                            else
                                                                enConn='on';
                                                            end
                                                        end
                                                    end
                                                    set([handles.btnDelete,handles.btnEdit],'Enable',enED);
                                                    set(handles.btnConnect,'Enable',enConn);
                                                    set(handles.btnDisconnect,'Enable',enDis);



                                                    function client=getcurrentclient(handles)

                                                        clntList=opcslclntmgritf(handles.blockHandle,'GetClientList');
                                                        cI=get(handles.lstOPCClient,'Value');
                                                        client=[];
                                                        if isa(clntList,'opcda')&&cI<=length(clntList),
                                                            client=clntList(cI);
                                                        end



                                                        function setcurrentclient(handles,client)

                                                            clntList=opcslclntmgritf(handles.blockHandle,'GetClientList');
                                                            cI=get(handles.lstOPCClient,'Value');
                                                            if isa(client,'opcda'),
                                                                if isa(clntList,'opcda'),
                                                                    clntList(cI)=client;
                                                                else
                                                                    clntList=client;
                                                                end
                                                                opcslclntmgritf(handles.blockHandle,'SetClientList',clntList);
                                                            end

