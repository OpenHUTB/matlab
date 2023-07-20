function varargout=opcslclntmgritf(block,action,varargin)






    if ischar(block),
        block=get_param(block,'Object');
    else
        block=get(block,'Object');
    end

    if nargout,
        [varargout{1:nargout}]=feval(action,block,varargin{:});
    else
        feval(action,block,varargin{:});
    end



    function myDlg=GetOpenClntMgr(anyBlock)

        myDlg=[];

        configBlk=opcslconfigitf(anyBlock,'FindUsed');
        if~isempty(configBlk),
            allDlg=findall(0,'Tag','dlgOPCClntMgr');
            for k=1:length(allDlg),
                dlgHandles=guidata(allDlg(k));
                if isfield(dlgHandles,'blockHandle')&&...
                    dlgHandles.blockHandle==configBlk,
                    myDlg=allDlg(k);
                    break
                end
            end
        end




        function SetDialogForStart(anyBlock)
            myDlg=GetOpenClntMgr(anyBlock);
            if~isempty(myDlg),
                handles=guidata(myDlg);

                hStore=[handles.lstOPCClient,...
                handles.btnAdd,...
                handles.btnDelete,...
                handles.btnEdit,...
                handles.btnConnect,...
                handles.btnDisconnect];
                hEnabled=get(hStore,'Enable');

                setappdata(myDlg,'runningStore',{hStore,hEnabled});

                set(hStore,'Enable','off');
                checkenable(hStore);
            end




            function SetDialogForStop(anyBlock)
                myDlg=GetOpenClntMgr(anyBlock);
                if~isempty(myDlg),
                    handles=guidata(myDlg);

                    ad=getappdata(myDlg,'runningStore');

                    set(ad{1},{'Enable'},ad{2});
                    checkenable(ad{1});
                end




                function SetName(anyBlock,mdlName)
                    myDlg=GetOpenClntMgr(anyBlock);
                    if~isempty(myDlg),
                        set(myDlg,'Name',...
                        sprintf('OPC Configuration: Client List (%s)',mdlName));
                    end



                    function RefreshClientList(anyBlock,handles,clntList)

                        if nargin<3,

                            clntList=GetClientList(anyBlock);
                        end
                        if~isa(clntList,'opcda')
                            clntString='';
                        else
                            dParts=get(clntList,{'host','serverid','timeout','status'});
                            clntString=cell(length(clntList),1);
                            for k=1:length(clntList),
                                dParts{k,4}(1)=upper(dParts{k,4}(1));
                                clntString{k}=sprintf('%s/%s [Timeout = %g, %s]',dParts{k,:});
                            end
                        end
                        if isempty(clntString),
                            set(handles.lstOPCClient,'String','<No clients defined>',...
                            'Enable','off',...
                            'Max',2,...
                            'Value',[]);
                        else
                            curVal=get(handles.lstOPCClient,'Value');
                            if isempty(curVal),
                                curVal=1;
                            elseif curVal>length(clntString),
                                curVal=length(clntString);
                            end
                            set(handles.lstOPCClient,'String',clntString,...
                            'Enable','on',...
                            'Value',curVal,...
                            'Max',1);
                        end

                        enED='off';
                        enConn='off';
                        enDis='off';
                        if~isempty(clntList),

                            enED='on';

                            if strcmpi(dParts{curVal,4},'connected'),
                                enDis='on';
                            else
                                enConn='on';
                            end
                        end
                        set([handles.btnDelete,handles.btnEdit],'Enable',enED);
                        set(handles.btnConnect,'Enable',enConn);
                        set(handles.btnDisconnect,'Enable',enDis);
                        checkenable(handles.lstOPCClient);





                        function clntInd=AddClient(anyBlock,host,serverID,timeout,mustConnect)

                            if nargin<5,
                                mustConnect=true;
                            end
                            if nargin<4,
                                timeout='10';
                            end

                            configBlk=opcslconfigitf(anyBlock,'FindUsed',true);
                            if isempty(configBlk),
                                error('opcblks:clientmanager:configNotFound',...
                                'Configuration block not found.');
                            end

                            clntInd=GetClientIndex(configBlk,host,serverID);
                            if~isempty(clntInd)
                                return;
                            end

                            clntList=GetClientList(configBlk);

                            try
                                thisObj=opcda(host,serverID);
                                set(thisObj,'Timeout',str2num(timeout));
                            catch ME
                                error('opcblks:clientmanager:clientCreationFailed',...
                                'Client creation failed. Error was:\n''%s''',ME.message);
                            end
                            if isempty(clntList),
                                clntList=thisObj;
                            else
                                clntList(end+1)=thisObj;
                            end

                            if mustConnect,
                                ConnectClientObject(configBlk,thisObj,false);
                            end

                            SetClientList(configBlk,clntList);
                            clntInd=length(clntList);



                            function clntList=GetClientList(anyBlock)

                                configBlk=opcslconfigitf(anyBlock,'FindUsed');
                                clntList=[];
                                if~isempty(configBlk),
                                    clntList=get(configBlk,'UserData');
                                end



                                function SetClientList(anyBlock,clntList)


                                    configBlk=opcslconfigitf(anyBlock,'FindUsed');
                                    set(configBlk,'UserData',clntList);

                                    if isempty(clntList),
                                        clntStr='';
                                    else
                                        opcData=get(clntList,{'Host','ServerID','Timeout'})';
                                        clntStr=sprintf('%s/%s/%d, ',opcData{:});
                                        clntStr(end-1:end)=[];
                                    end
                                    configBlk.opcServers=clntStr;


                                    allClntMgr=findall(0,'Tag','dlgOPCClntMgr');
                                    for k=1:length(allClntMgr),
                                        handles=guidata(allClntMgr(k));
                                        if isfield(handles,'blockHandle')&&(handles.blockHandle==configBlk),

                                            RefreshClientList(configBlk,handles,clntList);
                                        end
                                    end

                                    allReadDlg=findall(0,'Tag','dlgOPCRead');
                                    for k=1:length(allReadDlg),
                                        handles=guidata(allReadDlg(k));
                                        if isfield(handles,'blockHandle'),


                                            if strcmp(strtok(configBlk.Path,'/'),...
                                                strtok(handles.blockHandle.Path,'/')),

                                                set(handles.popClient,'Enable','off');
                                                opcslreaditf(configBlk,'RefreshClientList',handles,clntList);
                                            end
                                        end
                                    end

                                    allWriteDlg=findall(0,'Tag','dlgOPCWrite');
                                    for k=1:length(allWriteDlg),
                                        handles=guidata(allWriteDlg(k));
                                        if isfield(handles,'blockHandle')


                                            if strcmp(strtok(configBlk.Path,'/'),...
                                                strtok(handles.blockHandle.Path,'/')),

                                                set(handles.popClient,'Enable','off');
                                                opcslwriteitf(configBlk,'RefreshClientList',handles,clntList);
                                            end
                                        end
                                    end



                                    function clntObj=GetClient(rwBlock)



                                        clntObj=[];
                                        clntList=opcslclntmgritf(rwBlock,'GetClientList');
                                        if~isempty(clntList),
                                            clntInd=find(strcmpi(rwBlock.serverHost,clntList.host)&...
                                            strcmpi(rwBlock.serverID,clntList.serverid));
                                            if~isempty(clntInd),
                                                clntObj=clntList(clntInd);
                                            end
                                        end



                                        function ind=GetClientIndex(configBlock,host,serverID)


                                            clntList=get(configBlock,'UserData');
                                            ind=[];
                                            if~isempty(clntList)
                                                hstList=get(clntList,'Host');
                                                srvIDList=get(clntList,'ServerID');
                                                ind=find(strcmpi(host,hstList)&strcmpi(serverID,srvIDList),1);
                                            end



                                            function status=ConnectClient(anyBlock,host,serverID)




                                                switch nargin
                                                case 1

                                                    clntObj=GetClient(anyBlock);
                                                case 2

                                                    clntList=GetClientList(anyBlock);
                                                    if host<=length(clntList)&&host>=1
                                                        clntObj=clntList(host);
                                                    else

                                                        error('opcblks:clntmgritf:internal',...
                                                        'Client with specified index does not exist.')
                                                    end
                                                case 3

                                                    configBlk=opcslconfigitf(anyBlock,'FindUsed');
                                                    clntInd=GetClientIndex(configBlk,host,serverID);
                                                    clntList=GetClientList(anyBlock);
                                                    clntObj=clntList(clntInd);
                                                end
                                                status=ConnectClientObject(anyBlock,clntObj);



                                                function status=ConnectClientObject(anyBlock,clntObj,showWarn);
                                                    if nargin<3,
                                                        showWarn=true;
                                                    end

                                                    try
                                                        connect(clntObj);
                                                        status=true;
                                                    catch ME

                                                        if showWarn,
                                                            errStruct=ME;

                                                            if strcmp(errStruct.identifier,'opc:connect:timeout'),

                                                                uiwait(warndlg({...
                                                                'Client timed out trying to connect to server.';...
                                                                'Consider increasing the timeout value for this client.'},...
                                                                'OPC: Timeout connecting to server'));
                                                            else
                                                                uiwait(warndlg({...
                                                                'Error attempting to connect to server:';...
                                                                errStruct.message},...
                                                                'OPC: Error connecting to server'));
                                                            end
                                                        end
                                                        status=false;
                                                    end



                                                    function blks=GetClientUsers(anyBlock,clnt)

                                                        rootSys=strtok(anyBlock.Path,'/');
                                                        blkTypes={'OPC Read','OPC Write'};
                                                        blks={};
                                                        for k=1:length(blkTypes)
                                                            thisType=blkTypes{k};


                                                            thisBlks=find_system(rootSys,'LookUnderMasks','all',...
                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                            'MaskType',thisType);

                                                            for bI=1:length(thisBlks),
                                                                thisHost=get_param(thisBlks{bI},'serverHost');
                                                                thisID=get_param(thisBlks{bI},'serverID');
                                                                if(strcmpi(thisHost,clnt.Host)&&strcmpi(thisID,clnt.ServerID))

                                                                    blks{end+1}=thisBlks{bI};
                                                                end
                                                            end
                                                        end
