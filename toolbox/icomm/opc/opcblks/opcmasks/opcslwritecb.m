function opcslwritecb(block,action,varargin)








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



            opcslclntmgritf(block,'AddClient',block.serverHost,block.serverID,'10');
        end



        function DeleteFcn(block)

            delete(opcslwriteitf(block,'GetOpenBlockDlg'));

            ModelCloseFcn(block)



            function InitFcn(block)

                status=get_param(strtok(block.Path,'/'),'SimulationStatus');
                if~isempty(block.serverHost),


                    clientInd=opcslclntmgritf(block,'AddClient',block.serverHost,block.serverID);
                    if isempty(clientInd),
                        error('opcblks:write:clientNotCreated',...
                        'Could not create client during initialisation.');
                    end
                end


                if strcmp(status,'initializing'),
                    configBlk=opcslconfigitf(block,'FindUsed');
                    if isempty(configBlk),
                        error('opcblks:write:configNotFound',...
                        'OPC Configuration block not found. You cannot start a simulation containing OPC Write blocks without an OPC Configuration block.');
                    end
                end



                function ModelCloseFcn(block)

                    allObjs=opcfind('UserData',block.Handle);
                    for k=1:length(allObjs)
                        delete(allObjs{k});
                    end



                    function StartFcn(block)


                        if isempty(block.itemIDs),
                            error('opcblks:write:writeItemsBlank',...
                            'Cannot start simulation. OPC Write block has no items configured.');
                        end

                        myDlg=opcslwriteitf(block,'GetOpenBlockDlg');
                        if~isempty(myDlg)

                            handles=guidata(myDlg);

                            if strcmp(get(handles.btnApply,'Enable'),'on'),
                                errStruct.identifier='opcblks:write:unappliedChanges';
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
                            handles.popWriteMode,...
                            handles.edtSampleTime,...
                            handles.btnApply,...
                            handles.btnOK];
                            hEnabled=get(hStore,'Enable');

                            setappdata(myDlg,'runningStore',{hStore,hEnabled});

                            set(hStore,'Enable','off');
                            checkenable(hStore);
                        end



                        function StopFcn(block)

                            myDlg=opcslwriteitf(block,'GetOpenBlockDlg');
                            if~isempty(myDlg)

                                ad=getappdata(myDlg,'runningStore');

                                set(ad{1},{'Enable'},ad{2});
                                checkenable(ad{1});
                            end

