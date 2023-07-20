function varargout=opcslconfigcb(block,action)








    if ischar(block),
        block=get_param(block,'Object');
    else
        block=get(block,'Object');
    end

    if nargout,
        [varargout{1:nargout}]=feval(action,block);
    else
        feval(action,block);
    end




    function CopyFcn(block)
        allLocs=opcslconfigitf(block,'FindAll');
        if length(allLocs)>1,

            block.beingUsed='off';

            errorStr={...
            'Multiple OPC Configuration blocks are not permitted in a';...
            'model. This block will be disabled and must be deleted.';...
            '';...
            'Would you like to highlight the enabled OPC Configuration block?'};
            response=questdlg(errorStr,'OPC Configuration',...
            'Yes','No','Yes');
            if strcmp(response,'Yes'),
                opcslconfigitf(block,'HighlightUsed');
            end


            block.UserData=[];
        end

        if~isempty(block.UserData),
            block.UserData=copyobj(block.UserData);


            for k=1:length(block.UserData);
                delete(get(block.UserData(k),'Group'));
                opcslclntmgritf(block,'ConnectClientObject',block.UserData(k),false);
            end
        end




        function DeleteFcn(block)




            lockState=[];
            if isblocklibrary(block)&&~strcmp(block.Path,'opclib')

                lockState=get_param(strtok(block.Path,'/'),'Lock');
                set_param(strtok(block.Path,'/'),'Lock','off');
            end

            myDlg=[opcslconfigitf(block,'GetOpenBlockDlg'),...
            opcslclntmgritf(block,'GetOpenClntMgr')];
            delete(myDlg);

            clntObj=get(block,'UserData');
            delete(clntObj);
            set(block,'UserData',[]);
            if strcmp(block.beingUsed,'on')

                allLocs=opcslconfigitf(block,'FindAll');
                for k=1:length(allLocs)
                    blkObj=get_param(allLocs{k},'Object');
                    if strcmp(blkObj.beingUsed,'off')

                        blkObj.beingUsed='on';
                        break;
                    end
                end
            end
            if~isempty(lockState)
                set_param(strtok(block.Path,'/'),'Lock',lockState);
            end



            function LoadFcn(block)



                lockState=[];
                if isblocklibrary(block)

                    lockState=get_param(strtok(block.Path,'/'),'Lock');
                    set_param(strtok(block.Path,'/'),'Lock','off');
                end


                clntList=regexp(block.opcServers,...
                '(?<host>[^/]*)/(?<serverid>[^/]*)/(?<timeout>[\d\.]*)(, )*','names');


                numClnts=length(clntList);
                hBar=[];
                if numClnts>2,

                    hBar=waitbar(0,'OPC Configuration: Connecting to Servers',...
                    'Name','OPC Configuration: Connecting');
                    set(findall(hBar,'type','text'),'FontName','Tahoma');
                    drawnow;
                    pause(0.1);
                end
                if numClnts==0,
                    clntObj=[];
                else
                    for k=1:numClnts
                        clntObj(k)=opcda(clntList(k).host,clntList(k).serverid);
                        set(clntObj(k),'Timeout',str2double(clntList(k).timeout));

                        try
                            connect(clntObj(k));
                        end
                        if numClnts>2,
                            waitbar(k./numClnts,hBar);
                            drawnow;
                            pause(0.1);
                        end
                    end
                end
                delete(hBar);

                set(block,'UserData',clntObj,'UserDataPersistent','off');
                if~isempty(lockState),
                    set_param(strtok(block.Path,'/'),'Lock',lockState);
                end



                function PostSaveFcn(block)

                    clntDlg=opcslclntmgritf(block,'GetOpenClntMgr');
                    if~isempty(clntDlg)

                        opcslclntmgritf(block,'SetName',strtok(block.Path,'/'));
                    end



                    function StartFcn(block)


                        myDlg=opcslconfigitf(block,'GetOpenBlockDlg');
                        if~isempty(myDlg),

                            handles=guidata(myDlg);

                            if strcmp(get(handles.btnApply,'Enable'),'on'),
                                errStruct.identifier='opcblks:config:unappliedChanges';
                                errStruct.message=sprintf(...
                                '%s/%s has unapplied changes. Please apply or cancel these changes before running the simulation.',...
                                handles.blockHandle.Path,handles.blockHandle.Name);
                                err=MException(errStruct.identifier,errStruct.message);
                                throwAsCaller(err);
                            end
                            hStore=[handles.popItmNotAvailable,...
                            handles.popServerShutdown,handles.popReadWriteError,...
                            handles.popRTViolated,...
                            handles.chkEnableRT,...
                            handles.edtSpeedup,...
                            handles.chkShowLatency,...
                            handles.btnApply,...
                            handles.btnOK];
                            hEnabled=get(hStore,'Enable');

                            setappdata(myDlg,'runningStore',{hStore,hEnabled});

                            set(hStore,'Enable','off');
                            checkenable(hStore);
                        end


                        opcslclntmgritf(block,'SetDialogForStart');



                        function StopFcn(block)


                            myDlg=opcslconfigitf(block,'GetOpenBlockDlg');
                            if~isempty(myDlg)

                                ad=getappdata(myDlg,'runningStore');

                                set(ad{1},{'Enable'},ad{2});
                                checkenable(ad{1});
                            end


                            opcslclntmgritf(block,'SetDialogForStop');



                            function UndoDeleteFcn(block)

                                if strcmp(block.beingUsed,'on'),

                                    allBlks=opcslconfigitf(block,'FindAll');
                                    thisUsed=strcmp(allBlks,sprintf('%s/%s',block.Path,block.Name));
                                    allBlks(thisUsed)=[];
                                    configBlk='';
                                    for k=1:length(allBlks)
                                        if strcmp(get_param(allBlks{k},'beingUsed'),'on'),
                                            configBlk=allBlks{k};
                                            break
                                        end
                                    end
                                    if~isempty(configBlk),
                                        set_param(configBlk,'beingUsed','off');

                                        delete(opcslconfigitf(configBlk,'GetOpenBlockDlg'));
                                        delete(opcslclntmgritf(configBlk,'GetOpenClntMgr'));
                                        clntList=opcslclntmgritf(configBlk,'GetClientList');
                                        delete(clntList);
                                    end

                                    LoadFcn(block);
                                end
