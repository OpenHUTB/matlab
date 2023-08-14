function varargout=opcslconfigitf(block,action,varargin)








    if ischar(block)
        block=get_param(block,'Object');
    else
        block=get(block,'Object');
    end

    if nargout
        [varargout{1:nargout}]=feval(action,block,varargin{:});
    else
        feval(action,block,varargin{:});
    end



    function configPath=AddConfigToRoot(anyBlk)

        rootSys=strtok(anyBlk.Path,'/');
        confPos=slfreespace('opclib/OPC Configuration',rootSys);

        configPath=add_block('opclib/OPC Configuration',...
        sprintf('%s/OPC Configuration',rootSys),...
        'MakeNameUnique','on',...
        'Position',confPos);



        function allLocs=FindAll(anyBlk)

            myLoc=get(anyBlk,'Path');
            if strcmp(myLoc,'opclib')
                allLocs={'opclib/OPC Configuration'};
            else


                allLocs=find_system(strtok(myLoc,'/'),'SearchDepth',inf,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','MaskType','OPC Configuration');
            end


            function usedConfigBlk=FindUsed(anyBlk,makeOne)

                if nargin<2
                    makeOne=false;
                end
                usedConfigBlk=[];
                allLocs=FindAll(anyBlk);
                for k=1:length(allLocs)
                    blkObj=get_param(allLocs{k},'Object');
                    if strcmp(blkObj.beingUsed,'on')
                        usedConfigBlk=blkObj;
                        break
                    end
                end
                if isempty(usedConfigBlk)&&makeOne
                    response=questdlg({...
                    'There is no OPC Configuration block in this model.';...
                    'You must include an OPC Configuration block in';...
                    'order to define clients to use in an OPC Read block.';...
                    '';...
                    'Click OK to add an OPC Configuration block to the root';...
                    'of the system, or Cancel to abort the operation.'},...
                    'OPC Read: Configuration Block Not Found',...
                    'OK','Cancel','OK');
                    if strcmp(response,'OK')

                        usedConfigBlk=AddConfigToRoot(anyBlk);
                    end
                end



                function HighlightUsed(anyBlk)%#ok<*DEFNU>

                    usedConfigBlk=FindUsed(anyBlk);
                    hilite_system(sprintf('%s/%s',usedConfigBlk.Path,usedConfigBlk.Name),'find');



                    function errState=GetErrorState(anyBlk)


                        configBlk=FindUsed(anyBlk);
                        if isempty(configBlk)



                            errState=struct('missingItems',1,'readWrite',1,'shutdown',1);
                        else
                            states={'Error';'Warn';'None'};
                            errState=struct('missingItems',find(strcmp(configBlk.errMissingItems,states)),...
                            'readWrite',find(strcmp(configBlk.errReadWrite,states)),...
                            'shutdown',find(strcmp(configBlk.errShutdown,states)));
                        end



                        function myDlg=GetOpenBlockDlg(block)

                            myDlg=[];
                            allDlg=findall(0,'Tag','dlgOPCConfig');
                            for k=1:length(allDlg)
                                dlgHandles=guidata(allDlg(k));
                                if isfield(dlgHandles,'blockHandle')&&...
                                    ~isempty(dlgHandles.blockHandle)&&...
                                    dlgHandles.blockHandle==block
                                    myDlg=allDlg(k);
                                    break
                                end
                            end
