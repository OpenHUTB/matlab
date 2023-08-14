classdef SubsystemReplacer<handle
    properties
Model
ConversionData
ConversionParameters
        temporaryModelForVirtualBusExpansion_Handle=-1
expansionTable
CachedGraphicalInfo
ParentSystems
CopyStrategies
    end

    methods(Access=public)
        function this=SubsystemReplacer(Model,ConversionData,ParentSystems,CachedGraphicalInfo,temporaryModelForVirtualBusExpansion_Handle,expansionTable,CopyStrategies)
            this.Model=Model;
            this.ConversionData=ConversionData;
            this.ParentSystems=ParentSystems;
            this.ConversionParameters=ConversionData.ConversionParameters;
            this.CachedGraphicalInfo=CachedGraphicalInfo;
            this.temporaryModelForVirtualBusExpansion_Handle=temporaryModelForVirtualBusExpansion_Handle;
            this.expansionTable=expansionTable;
            this.CopyStrategies=CopyStrategies;
        end
        function replace(this)


            arrayfun(@(idx)this.replaceOneSubsystem(idx),1:numel(this.ConversionParameters.Systems));


            cellfun(@(aBlock)this.updateCodeCoverageInfo(aBlock),...
            this.ConversionParameters.SystemNames);
        end
    end
    methods(Access=private)
        function replaceOneSubsystem(this,idx)
            if this.ConversionParameters.CreateWrapperSubsystem
                aBlock=this.ParentSystems(idx);
            else
                aBlock=this.ConversionData.ModelBlocks(idx);
            end
            subsysH=this.ConversionParameters.Systems(idx);
            ssName=get_param(subsysH,'Name');



            parent=get_param(subsysH,'Parent');
            aNewBlock=add_block(getfullname(aBlock),[parent,'/',ssName],'makenameunique','on');

            if~this.ConversionParameters.CreateWrapperSubsystem
                this.updateShowReinitPorts(subsysH,aNewBlock);
            end


            modelHandle=get_param(this.Model,'Handle');
            try
                copyStrategy=this.CopyStrategies{idx};
                this.convertSSMgrConnections(modelHandle,subsysH,aNewBlock,copyStrategy);
            catch me
                delete_block(aNewBlock);
                rethrow(me);
            end


            subsysLineHandles=get_param(subsysH,'LineHandles');

            this.updateOutportLabels(subsysH,aNewBlock);


            warningID='Simulink:Harness:HarnessDeletedForBlock';
            warn=warning('off',warningID);
            oc=onCleanup(@()warning(warn.state,warningID));
            delete_block(subsysH);
            warning(warn.state,warningID);

            set_param(aNewBlock,'name',ssName);
            this.CachedGraphicalInfo{idx}.copy(aNewBlock);


            mdlRefLineHandles=get_param(aNewBlock,'LineHandles');
            ssInport=[subsysLineHandles.Inport,subsysLineHandles.Event];
            mdlInport=mdlRefLineHandles.Inport;
            notEqIn=find(ssInport-mdlInport,1);
            notEqOut=find(subsysLineHandles.Outport-mdlRefLineHandles.Outport,1);
            if~(isempty(notEqIn)&&isempty(notEqOut))
                open_system(parent);
                hilite_system(aNewBlock);
                throw(MException(message('Simulink:modelReference:convertToModelReference_UnableToWireBlock',ssName,parent)));
            end


            if this.ConversionParameters.CreateWrapperSubsystem
                this.ConversionData.ModelBlocks(idx)=Simulink.ModelReference.Conversion.GuiUtilities.findModelBlock(aNewBlock);
            else
                this.ConversionData.ModelBlocks(idx)=aNewBlock;
            end
        end

        function updateOneOutportLabel(this,phSysOuts,phMdlOuts,iOut)
            if isKey(this.expansionTable,phSysOuts(iOut))
                isExpanded=this.expansionTable(phSysOuts(iOut));
                if iscell(isExpanded)
                    isExpanded=isExpanded{:};
                end
                if isExpanded(1)
                    phSysOutObj=get_param(phSysOuts,'Object');
                    if isempty(get_param(phMdlOuts,'SignalNameFromLabel'))&&isempty(phSysOutObj.SignalNameFromLabel)
                        set_param(phMdlOuts,'SignalNameFromLabel',phSysOutObj.PropagatedSignals);
                    end
                end
            end
        end

        function updateShowReinitPorts(~,subsysH,aNewBlock)
            prmVal=get_param(subsysH,'ShowSubsystemReinitializePorts');
            set_param(aNewBlock,'ShowModelReinitializePorts',prmVal);
        end

        function updateOutportLabels(this,subsysH,aNewBlock)

            if this.temporaryModelForVirtualBusExpansion_Handle~=-1&&(this.expansionTable.Count>0)
                phSystem=get_param(subsysH,'PortHandles');
                phMdlBlk=get_param(aNewBlock,'PortHandles');


                phSysOuts=phSystem.Outport;
                phMdlOuts=phMdlBlk.Outport;
                if numel(phSysOuts)==numel(phMdlOuts)
                    updateFunctor=@(iOut)this.updateOneOutportLabel(phSysOuts,phMdlOuts,iOut);
                    arrayfun(updateFunctor,1:numel(phSysOuts));
                end
            end
        end

        function convertSSMgrConnections(this,modelHandle,subsysH,mdlRefBlkH,copyStrategy)
            subsysH=get_param(subsysH,'Handle');
            SSMgrViewers=find_system(modelHandle,...
            'SearchDepth',1,...
            'AllBlocks','on',...
            'type','block',...
            'iotype','viewer');

            SSMgrSiggens=find_system(modelHandle,...
            'SearchDepth',1,...
            'AllBlocks','on',...
            'type','block',...
            'iotype','siggen');

            SSMgrBlks=[SSMgrViewers(:);SSMgrSiggens(:)];
            nSSMgrBlks=length(SSMgrBlks);


            for i=1:nSSMgrBlks
                SSMgrBlk=SSMgrBlks(i);
                isViewer=strcmp(get_param(SSMgrBlk,'iotype'),'viewer');
                IOSigs=get_param(SSMgrBlk,'iosignals');
                nIOSigSets=length(IOSigs);


                for j=1:nIOSigSets
                    nSignals=length(IOSigs{j});


                    for k=1:nSignals
                        Signal=IOSigs{j}(k);


                        if(Signal.Handle==-1)
                            continue;
                        end

                        isPort=isempty(Signal.RelativePath);

                        parent=get_param(Signal.Handle,'parent');
                        parentH=get_param(parent,'handle');


                        if(isPort)
                            portIdx=get_param(Signal.Handle,'portnumber');


                            if(parentH==subsysH)
                                mdlRefPortHs=get_param(mdlRefBlkH,'PortHandles');

                                if(isViewer)
                                    mdlRefPortH=mdlRefPortHs.Outport(portIdx);
                                else
                                    mdlRefPortH=mdlRefPortHs.Inport(portIdx);
                                end


                                IOSigs{j}(k).Handle=mdlRefPortH;



                            elseif(this.IsBlkInSubsysHier(parentH,subsysH))




                                if(~isViewer)
                                    throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidSigGenConnection')));
                                end





                                subsysFullName=getfullname(subsysH);
                                destFullName=getfullname(parent);
                                mdlRefName=get_param(mdlRefBlkH,'modelName');
                                newDestFullName=this.getNewBlockFullName(subsysFullName,destFullName,mdlRefName,copyStrategy);

                                relativePath=[newDestFullName,':o',num2str(portIdx)];
                                IOSigs{j}(k).Handle=mdlRefBlkH;
                                IOSigs{j}(k).RelativePath=slprivate('encpath',relativePath,'','','none');


                                newDestPortHs=get_param(newDestFullName,'PortHandles');
                                newDestPortH=newDestPortHs.Outport(portIdx);
                                set_param(newDestPortH,'testpoint','on');
                            else
                                continue;
                            end

                        else


                            if(this.IsBlkInSubsysHier(parentH,subsysH))
                                subsysFullName=getfullname(subsysH);
                                destFullName=getfullname(Signal.Handle);
                                mdlRefName=get_param(mdlRefBlkH,'modelName');
                                newDestFullName=this.getNewBlockFullName(subsysFullName,destFullName,mdlRefName,copyStrategy);













                                relativePath=Signal.RelativePath;
                                pathSeparator='modelref';

                                stateflow=0;
                                if strcmp(get_param(Signal.Handle,'Type'),'block')&&...
                                    slprivate('is_stateflow_based_block',Signal.Handle)

                                    stateflow=1;
                                    relativePath=relativePath(length('StateflowChart')+1:end);
                                    pathSeparator='none';
                                end
                                newRelPath=slprivate('encpath',newDestFullName,'',relativePath,pathSeparator);


                                if(stateflow)
                                    sigPath=newRelPath(1:strfind(newRelPath,':o')-1);
                                    r=sigPath;
                                    while(~isempty(r))
                                        [t,r]=strtok(r,'/');%#ok
                                    end
                                    sigName=t;
                                    sigPath=sigPath(1:strfind(sigPath,t)-2);
                                    h=find(sfroot,'Name',sigName,'Path',sigPath);
                                    if(~isempty(h))
                                        h.Testpoint=1;
                                    end
                                end

                                IOSigs{j}(k).Handle=mdlRefBlkH;
                                IOSigs{j}(k).RelativePath=newRelPath;
                            else
                                continue;
                            end
                        end
                    end
                end
                set_param(SSMgrBlk,'iosignals',IOSigs);
            end
        end

        function updateCodeCoverageInfo(~,subsys)
            subsys=getfullname(subsys);
            modelName=bdroot(subsys);
            covPath=get_param(modelName,'CovPath');
            if~isempty(covPath)||~strcmp(covPath,'/')
                fullCovPath=[modelName,'/',covPath];
                if strcmp(subsys,fullCovPath)||...
                    Simulink.ModelReference.Conversion.Utilities.isChild([fullCovPath,'/'],{[subsys,'/']})


                    set_param(modelName,'CovPath','/');
                end
            end
        end

        function isInHier=IsBlkInSubsysHier(~,blkH,subsysH)
            isInHier=false;
            subsysName=[getfullname(subsysH),'/'];
            blkName=getfullname(blkH);
            idx=strfind(blkName,subsysName);
            if(idx==1)
                isInHier=true;
            end
        end

        function newBlockFullName=getNewBlockFullName(~,subsysFullName,destFullName,mdlRefName,copyStrategy)
            splitedSubsys=split(subsysFullName,'/');
            splitedDest=split(destFullName,'/');
            if copyStrategy.isCopySubsystemContent
                newBlockFullName=join([mdlRefName;splitedDest(length(splitedSubsys)+1:end)],'/');
            else
                newBlockFullName=join([mdlRefName;splitedDest(length(splitedSubsys):end)],'/');
            end
            newBlockFullName=char(newBlockFullName);
        end
    end
end
