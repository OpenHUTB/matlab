function opcslreadcb(block,action,varargin)








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



    function CopyFcn(block)

        if~isempty(block.serverHost)&&~isempty(block.serverID),


            configBlk=opcslconfigitf(block,'FindUsed',false);
            if~isempty(configBlk)
                opcslclntmgritf(block,'AddClient',...
                block.serverHost,block.serverID,'10');
            end
        end



        function DeleteFcn(block)

            delete(opcslreaditf(block,'GetOpenBlockDlg'));

            ModelCloseFcn(block)



            function InitFcn(block)

                status=get_param(strtok(block.Path,'/'),'SimulationStatus');
                if~isempty(block.serverHost),


                    clientInd=opcslclntmgritf(block,'AddClient',block.serverHost,block.serverID);
                    if isempty(clientInd),
                        error('opcblks:read:clientNotCreated',...
                        'Could not create client during initialisation.');
                    end
                end


                if strcmp(status,'initializing'),
                    configBlk=opcslconfigitf(block,'FindUsed');
                    if isempty(configBlk),
                        error('opcblks:read:configNotFound','OPC Configuration block not found. You cannot start a simulation containing OPC Read blocks without an OPC Configuration block.');
                    end
                end



                function ModelCloseFcn(block)

                    allObjs=opcfind('UserData',block.Handle);
                    for k=1:length(allObjs)
                        delete(allObjs{k});
                    end



                    function StartFcn(block)


                        if isempty(block.itemIDs),
                            error('opcblks:read:readItemsBlank',...
                            'Cannot start simulation. OPC Read block has no items configured.');
                        end
                        myDlg=opcslreaditf(block,'GetOpenBlockDlg');
                        if~isempty(myDlg)

                            handles=guidata(myDlg);

                            if strcmp(get(handles.btnApply,'Enable'),'on'),
                                errStruct.identifier='opcblks:read:unappliedChanges';
                                errStruct.message=sprintf(...
                                '%s/%s has unapplied changes. Please apply or cancel these changes before running the simulation.',...
                                handles.blockHandle.Path,handles.blockHandle.Name);
                                err=MException(errStruct.identifier,errStruct.message);
                                throwAsCaller(err);
                            end
                            hStore=[handles.btnImport,...
                            handles.popClient,...
                            handles.lstItemIDs,...
                            handles.btnMoveUp,handles.btnMoveDn,...
                            handles.btnAdd,handles.btnDelete,...
                            handles.popReadMode,...
                            handles.edtSampleTime,...
                            handles.popDataType,...
                            handles.chkShowQuality,...
                            handles.chkShowTimestamp,...
                            handles.rdoSeconds,...
                            handles.rdoDatenum,...
                            handles.btnApply,...
                            handles.btnOK];
                            hEnabled=get(hStore,'Enable');

                            setappdata(myDlg,'runningStore',{hStore,hEnabled});

                            set(hStore,'Enable','off');
                            checkenable(hStore);
                        end



                        function StopFcn(block)

                            myDlg=opcslreaditf(block,'GetOpenBlockDlg');
                            if~isempty(myDlg)

                                ad=getappdata(myDlg,'runningStore');

                                set(ad{1},{'Enable'},ad{2});
                                checkenable(ad{1});
                            end