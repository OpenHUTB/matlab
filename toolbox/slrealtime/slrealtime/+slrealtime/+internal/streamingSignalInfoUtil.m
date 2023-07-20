classdef streamingSignalInfoUtil






    methods(Static)

        function signalInfo=getXcpSignalInfoFromCodeDescriptor(signal,codeDescriptor,slrt_task_info)

            if length(signal)>1
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end
            assert(~isempty(codeDescriptor));
            assert(exist(slrt_task_info,'file')==2);




            signalInfo=slrealtime.internal.streamingSignalInfoUtil.getSignalsFromCodeDescriptor(signal,codeDescriptor,slrt_task_info);
            if isempty(signalInfo)
                return;
            end




            for i=1:length(signalInfo)
                signalInfo(i).SimulationDataBlockPath=Simulink.SimulationData.BlockPath(signalInfo(i).blockPath);
                signalInfo(i).decimation=signal.decimation;
            end
        end

        function signals=getSignalsFromCodeDescriptor(signalStruct,codeDescriptor,taskInfoFile)






            signals=[];







            if isdeployed
                fileText=regexp(fileread(taskInfoFile),newline,'split');
                eval(strjoin(fileText(2:end-2),newline));

                taskInfos=taskInfo;
                numTasks=numtask;
            else

                [d,f]=fileparts(taskInfoFile);
                currentDir=pwd;
                cleanup=onCleanup(@()cd(currentDir));
                cd(d);
                [taskInfos,numTasks,isDeploymentDiagram]=eval(f);
                cd(currentDir);
            end

            sigMap=containers.Map('KeyType','char','ValueType','any');
            for nSig=1:length(signalStruct)
                signal=signalStruct(nSig);

                if~isempty(signal.signame)
                    signalsToLookup=slrealtime.internal.streamingSignalInfoUtil.convertSignalNameToBlockAndPort(signal,codeDescriptor);
                    if isempty(signalsToLookup)
                        str=slrealtime.internal.streamingSignalInfoUtil.getSignalStringToDisplay(signal);
                        slrealtime.internal.throw.Error('slrealtime:instrument:NoSignalsMatchingName',str);
                        continue;
                    end
                else
                    signalsToLookup=signal;
                end

                for nSigToLookup=1:length(signalsToLookup)
                    str=slrealtime.internal.streamingSignalInfoUtil.getSignalStringToDisplay(signalsToLookup(nSigToLookup));
                    if~sigMap.isKey(str)
                        sigMap(str)=signalsToLookup(nSigToLookup);
                    end
                end
            end
            signalsToLookup=sigMap.values();
            signalsToLookup=[signalsToLookup{:}];

            for nSigToLookup=1:length(signalsToLookup)
                sig=slrealtime.internal.streamingSignalInfoUtil.getSignalFromCodeDescriptor(...
                taskInfos,numTasks,isDeploymentDiagram,...
                true,...
                '',...
                signalsToLookup(nSigToLookup).blockpath,...
                signalsToLookup(nSigToLookup).portindex,...
                signalsToLookup(nSigToLookup).statename,...
                signalsToLookup(nSigToLookup).metadata,...
                codeDescriptor,0,0);
                if isempty(sig)
                    str=slrealtime.internal.streamingSignalInfoUtil.getSignalStringToDisplay(signalsToLookup(nSigToLookup));
                    slrealtime.internal.throw.Error('slrealtime:instrument:NoStreaming',str);
                else


                    sig=sig.convertToStruct();


                    if isfield(signalsToLookup,'metadata')







                        if~isempty(signalsToLookup(nSigToLookup).metadata)
                            metadata=signalsToLookup(nSigToLookup).metadata;
                            if isfield(metadata,'name')
                                sig.signalName=metadata.name;
                            end
                            if isfield(metadata,'loggedName')
                                sig.loggedName=metadata.loggedName;
                            end
                            if isfield(metadata,'propagatedName')
                                sig.propagatedName=metadata.propagatedName;
                            end
                            if isfield(metadata,'grBlockPath')
                                sig.blockPath=metadata.grBlockPath;
                            end
                            if isfield(metadata,'grPortNumber')
                                sig.portNumber=metadata.grPortNumber;
                            end
                            if isfield(metadata,'startEl')
                                sig.targetAddress=sig.targetAddress+int64(metadata.startEl*sig.dataTypeSize);
                            end
                            if isfield(metadata,'dimensions')
                                sig.dimensions=metadata.dimensions;
                            end
                            if isfield(metadata,'signalSourceUUID')
                                sig.signalSourceUUID=metadata.signalSourceUUID;
                            end
                            if isfield(metadata,'signalSourceUUIDasInteger')
                                sig.signalSourceUUIDasInteger=metadata.signalSourceUUIDasInteger;
                            end
                            if isfield(metadata,'isMessageLine')
                                sig.isMessageLine=metadata.isMessageLine;
                                if(sig.isMessageLine)
                                    sig.tid=numTasks;
                                    sig.discreteInterval=0;
                                end
                            end
                            if isfield(metadata,'isFrame')
                                sig.isFrame=metadata.isFrame;
                            end
                            if isfield(metadata,'sampleTimeString')
                                sig.sampleTimeString=metadata.sampleTimeString;
                            end
                            if isfield(metadata,'domainType')
                                sig.domainType=metadata.domainType;
                            end
                            if isfield(metadata,'maxPoints')
                                sig.maxPoints=metadata.maxPoints;
                            end
                            if isfield(metadata,'matlabObsFcn')
                                sig.matlabObsFcn=metadata.matlabObsFcn;
                            else
                                sig.matlabObsFcn=[];
                            end
                            if isfield(metadata,'matlabObsParam')
                                sig.matlabObsParam=metadata.matlabObsParam;
                            else
                                sig.matlabObsParam=[];
                            end
                            if isfield(metadata,'matlabObsCallbackGroup')

                                if(metadata.matlabObsCallbackGroup<1)
                                    disp('invalid callback group number');
                                    slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                                end

                                sig.matlabObsCallbackGroup=metadata.matlabObsCallbackGroup;
                            else
                                sig.matlabObsCallbackGroup=[];
                            end
                            if isfield(metadata,'matlabObsFuncHandle')
                                sig.matlabObsFuncHandle=metadata.matlabObsFuncHandle;
                            else
                                sig.matlabObsFuncHandle=[];
                            end
                            if isfield(metadata,'matlabObsDropIfBusy')
                                sig.matlabObsDropIfBusy=metadata.matlabObsDropIfBusy;
                            else
                                sig.matlabObsDropIfBusy=[];
                            end
                            if isfield(metadata,'loggingMode')&&isfield(metadata,'ssid')
                                mode=metadata.loggingMode;
                                if mode==coder.descriptor.LoggingModeEnum.SELF_ACTIVITY
                                    domain='sf_state';
                                elseif mode==coder.descriptor.LoggingModeEnum.CHILD_ACTIVITY
                                    domain='sf_state_child';
                                elseif mode==coder.descriptor.LoggingModeEnum.LEAF_ACTIVITY
                                    domain='sf_state_leaf';
                                else
                                    domain='sf_data';
                                end
                                sig.domainType=domain;
                            end
                        else
                            sig.loggedName=sig.signalName;
                            sig.matlabObsFcn=[];
                            sig.matlabObsParam=[];
                            sig.matlabObsCallbackGroup=[];
                            sig.matlabObsFuncHandle=[];
                            sig.matlabObsDropIfBusy=[];
                        end

                    end

                    signals=[signals,sig];%#ok
                end
            end
        end

        function signals=convertSignalNameToBlockAndPort(signal,codeDescriptor)
            signals=[];
            bhm=codeDescriptor.getBlockHierarchyMap();

            signame=signal.signame;


            bhmSignals=bhm.getTunableSignalsForSLRTBySignalLabel(signame);
            for nBHMSignal=1:length(bhmSignals)
                newSignal=struct(...
                'blockpath',Simulink.SimulationData.BlockPath(bhmSignals(nBHMSignal).BlockPath),...
                'portindex',bhmSignals(nBHMSignal).PortIndex,...
                'statename','',...
                'signame','',...
                'metadata',signal.metadata);
                signals=[signals,newSignal];%#ok
            end


            mdlBlks=bhm.getBlocksByType('ModelReference');
            for nMdlBlk=1:length(mdlBlks)
                mdlBlk=mdlBlks(nMdlBlk);
                if mdlBlk.IsProtectedModelBlock
                    continue;
                end

                try
                    subCodeDescriptor=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                catch
                    assert(false);
                end

                sigs=slrealtime.internal.streamingSignalInfoUtil.convertSignalNameToBlockAndPort(signal,subCodeDescriptor);
                if~isempty(sigs)
                    for i=1:length(sigs)
                        strs=sigs(i).blockpath.convertToCell();
                        sigs(i).blockpath=Simulink.SimulationData.BlockPath([mdlBlk.Path,strs']);
                    end
                    signals=[signals,sigs];%#ok
                end
            end
        end

        function subsysParentSID=findRootLevelSubsystemParentSID(codeDescriptor,block)
            modelName=codeDescriptor.ModelName;
            parentSID=block.ParentSystemSID;
            if strcmp(modelName,parentSID)

                subsysParentSID=block.SID;
                return;
            else

                bhm=codeDescriptor.getBlockHierarchyMap();

                parentBlock=slrealtime.internal.getBlockBySID(bhm,parentSID);
                subsysParentSID=slrealtime.internal.streamingSignalInfoUtil.findRootLevelSubsystemParentSID(codeDescriptor,parentBlock);
            end
        end

        function sig=getSignalFromCodeDescriptor(...
            taskInfos,numTasks,isDeploymentDiagram,...
            isTopModel,topLevelModelOrSubsystemBlockSID,...
            blockpath,portindex,statename,metadata,...
            codeDescriptor,rtbAddress,rtdwAddress)
            sig=[];

            bhm=codeDescriptor.getBlockHierarchyMap();

            if blockpath.getLength()>1


                mdlBlks=bhm.getBlocksByType('ModelReference');
                paths=blockpath.convertToCell();
                for nMdlBlk=1:length(mdlBlks)
                    mdlBlk=mdlBlks(nMdlBlk);

                    if strcmp(paths{1},regexprep(mdlBlk.Path,'[\n]+',' '))
                        if mdlBlk.IsProtectedModelBlock
                            slrealtime.internal.throw.Error('slrealtime:instrument:ProtectedModelBlock');
                        end

                        try
                            subCodeDescriptor=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                        catch
                            assert(false);
                        end

                        if(rtbAddress==0&&rtdwAddress==0)










                            rtbAddressNew=mdlBlk.rtbAddressOrOffset;



                            rtdwAddressNew=mdlBlk.rtdwAddressOrOffset;

                        else












                            rtbAddressNew=rtdwAddress+mdlBlk.rtbAddressOrOffset;




                            rtdwAddressNew=rtdwAddress+mdlBlk.rtdwAddressOrOffset;
                        end




                        if isDeploymentDiagram&&isTopModel
                            modelName=codeDescriptor.ModelName;
                            parentSID=mdlBlk.ParentSystemSID;
                            if strcmp(modelName,parentSID)

                                topLevelModelOrSubsystemBlockSID=mdlBlk.SID;
                            else


                                topLevelModelOrSubsystemBlockSID=slrealtime.internal.streamingSignalInfoUtil.findRootLevelSubsystemParentSID(codeDescriptor,mdlBlk);
                            end
                        end

                        blockpathNew=Simulink.SimulationData.BlockPath(paths(2:end));
                        sig=slrealtime.internal.streamingSignalInfoUtil.getSignalFromCodeDescriptor(...
                        taskInfos,numTasks,isDeploymentDiagram,...
                        false,...
                        topLevelModelOrSubsystemBlockSID,...
                        blockpathNew,portindex,statename,metadata,...
                        subCodeDescriptor,rtbAddressNew,rtdwAddressNew);
                        if~isempty(sig)
                            sig.blockPath=[mdlBlk.Path,sig.blockPath];
                            sig.blockSID=[mdlBlk.SID,sig.blockSID];
                        end
                        return;
                    end
                end
            end

            blockpath=blockpath.getBlock(1);
            indices=regexp(blockpath,'[^/]/[^/]');
            if isempty(indices)

                sig=[];
                return;
            end
            blockname=extractAfter(blockpath,indices(end)+1);

            blks=bhm.getBlocksByName(blockname);
            blkPaths=regexprep({blks.Path},'[\n]+',' ');
            blks=blks(strcmp(blockpath,blkPaths));
            for i=1:length(blks)
                blk=blks(i);



                dataIntrfCont=[];
                if portindex~=-1

                    if portindex<=blk.DataOutputPorts.Size

                        if blk.DataOutputPorts(portindex).DataInterfaces.Size~=1
                            if isfield(metadata,'leafSignalNameToken')



                                dataIntrfs=blk.DataOutputPorts(portindex).DataInterfaces.toArray();
                                idxs=strcmp(metadata.leafSignalNameToken,{dataIntrfs.GraphicalName});
                                dataIntrfs=dataIntrfs(idxs);
                                if length(dataIntrfs)~=1
                                    continue;
                                end
                            else
                                continue;
                            end
                        end
                        dataIntrfCont=blk.DataOutputPorts(portindex).DataInterfaces(1);
                    end
                else

                    if~isempty(metadata)&&...
                        isfield(metadata,'ssid')&&...
                        isfield(metadata,'loggingMode')

                        ssid=metadata.ssid;
                        mode=metadata.loggingMode;

                        sfInfoArray=blk.StateflowLoggingMap.toArray;
                        sfInfo=sfInfoArray(arrayfun(@(x)(x.StateflowLoggingTuple.LoggingMode==mode&&x.StateflowLoggingTuple.Ssid==ssid),sfInfoArray));
                        if~isempty(sfInfo)






                            dataIntrfCont=sfInfo(1).DataInterface;
                        end
                    else

                        for nDWork=1:blk.DWorks.Size()
                            if strcmp(statename,blk.DWorks(nDWork).GraphicalName)
                                dataIntrfCont=blk.DWorks(nDWork);
                                break;
                            end
                        end
                        if isempty(dataIntrfCont)
                            for nDState=1:blk.DiscreteStates.Size()
                                if strcmp(statename,blk.DiscreteStates(nDWork).GraphicalName)
                                    dataIntrfCont=blk.DiscreteStates(nDState);
                                    break;
                                end
                            end
                        end
                    end
                end
                if isempty(dataIntrfCont)
                    continue;
                end



                impl=dataIntrfCont.Implementation;
                if~isempty(impl)&&impl.isDefined
                    sig=slrealtime.internal.SignalInfo;

                    sig.type=slrealtime.internal.processCodeDescriptorType(dataIntrfCont.Type,impl.Type);

                    if isempty(impl.CodeType.Identifier)
                        sig.type.dataTypeName=impl.CodeType.BaseType.Identifier;
                    else
                        sig.type.dataTypeName=impl.CodeType.Identifier;
                    end




                    if sig.type.isNVBus&&isempty(blk.DataOutputPorts(portindex).BusSignalInfo)
                        sig=[];
                        return;
                    end

                    if dataIntrfCont.Timing.TimingMode==coder.descriptor.TimingModes('CONTINUOUS')
                        sig.isDiscrete=0;
                        dmr_model=codeDescriptor.getMF0FullModel;

                        sig.discreteInterval=dmr_model.SampleTimeInfo.ModelFixedStepSize;
                        sig.sampleTimeString=num2str(dmr_model.SampleTimeInfo.ModelFixedStepSize);
                    elseif dataIntrfCont.Timing.TimingMode==coder.descriptor.TimingModes('ASYNCHRONOUS')
                        sig.isDiscrete=1;
                        sig.discreteInterval=0;
                        sig.sampleTimeString=num2str(dataIntrfCont.Timing.SamplePeriod);
                    else
                        sig.isDiscrete=1;
                        sig.discreteInterval=dataIntrfCont.Timing.SamplePeriod;
                        sig.sampleTimeString=num2str(dataIntrfCont.Timing.SamplePeriod);
                    end

                    sig.blockPath={Simulink.SimulationData.BlockPath.manglePath(blk.Path)};
                    sig.blockSID={blk.SID};
                    if portindex==-1
                        sig.portNumber=-1;
                        sig.signalName=statename;
                        sig.domainType='';
                    else
                        sig.portNumber=portindex-1;
                        sig.signalName=blk.DataOutputPorts(portindex).SignalLabel;
                        sig.domainType='';



                        if sig.type.isNVBus
                            slrealtime.internal.streamingSignalInfoUtil.updateNVBusNames(sig.type,blk.DataOutputPorts(portindex).BusSignalInfo);
                        end
                    end

                    if dataIntrfCont.AddressOrOffset==-1
                        sig.targetAddress=dataIntrfCont.AddressOrOffset;
                    else
                        sig.targetAddress=rtbAddress+dataIntrfCont.AddressOrOffset;
                    end




                    if~isempty(metadata)&&isfield(metadata,'busElement')
                        if~sig.type.isNVBus
                            slrealtime.internal.throw.Error('slrealtime:instrument:CannotSpecifyBusElement');
                        end

                        busElem=metadata.busElement;
                        busElemLevels=split(busElem,'.');








                        topLevelProdDims=prod(sig.type.dimensions);
                        tokens=regexp(busElemLevels{1},'^\((\d*)\)$','tokens');
                        if~isempty(tokens)
                            topLevelIdxSpecified=true;
                            topLevelArrayIdx=str2double(tokens{1}{1});

                            if topLevelArrayIdx>topLevelProdDims
                                slrealtime.internal.throw.Error('slrealtime:instrument:BusElementInvalidDims',...
                                topLevelArrayIdx,topLevelProdDims);
                            end

                            sig.targetAddress=sig.targetAddress+int64((topLevelArrayIdx-1)*sig.type.dataTypeSize);
                            busElemLevels=busElemLevels(2:end);
                        else
                            topLevelIdxSpecified=false;
                            if topLevelProdDims>1
                                slrealtime.internal.throw.Error('slrealtime:instrument:BusElementRequiresDims',...
                                topLevelProdDims);
                            end
                        end

                        numBusElemLevels=length(busElemLevels);
                        for nBusElemLevel=1:numBusElemLevels






                            tokens=regexp(busElemLevels{nBusElemLevel},'^(.*)\((\d*)\)$','tokens');
                            if~isempty(tokens)
                                arrayIdxSpecified=true;
                                elemName=tokens{1}{1};
                                elemArrayIdx=str2double(tokens{1}{2});
                            else
                                arrayIdxSpecified=false;
                                elemName=busElemLevels{nBusElemLevel};
                                elemArrayIdx=1;
                            end



                            elIdx=find(strcmp({sig.type.structElements.structElementName},elemName));
                            if isempty(elIdx)
                                slrealtime.internal.throw.Error('slrealtime:instrument:BusElementIncorrectPath',busElem);
                            end
                            sig.type=sig.type.structElements(elIdx);




                            if arrayIdxSpecified
                                prodDims=prod(sig.type.dimensions);
                                if elemArrayIdx>prodDims
                                    slrealtime.internal.throw.Error('slrealtime:instrument:BusElementInvalidDims',...
                                    elemArrayIdx,prodDims);
                                end
                            end

                            sig.targetAddress=sig.targetAddress+int64(sig.type.structElementOffset)+int64((elemArrayIdx-1)*sig.type.dataTypeSize);
                        end

                        if~isempty(sig.type.structElements)
                            slrealtime.internal.throw.Error('slrealtime:instrument:BusElementNotLeaf',busElem);
                        end


                        if~isempty(sig.signalName)
                            rootName=sig.signalName;
                        else
                            indices=regexp(sig.blockPath{end},'[^/]/[^/]');
                            if isempty(indices)
                                blockname=sig.blockPath{end};
                            else
                                blockname=extractAfter(sig.blockPath{end},indices(end)+1);
                            end
                            rootName=[blockname,':',num2str(sig.portNumber+1)];
                        end

                        if topLevelIdxSpecified
                            sig.signalName=[rootName,busElem];
                        else
                            sig.signalName=[rootName,'.',busElem];
                        end
                        metadata.name=sig.signalName;
                    end

                    sig.signalSourceUUID=char(matlab.lang.internal.uuid);
                    sig.signalSourceUUIDasInteger=Simulink.HMI.AsyncQueueObserverAPI.getUUIdFromString(sig.signalSourceUUID);

                    sig.isMessageLine=dataIntrfCont.isMessageDataInterface;
                    if sig.isMessageLine






                        sig=[];
                        return;
                    end




                    if numTasks>0
                        entryPoint='';
                        if isDeploymentDiagram
                            if isTopModel
                                entryPoint=sig.blockSID;
                                entryPointBlock=slrealtime.internal.getBlockBySID(bhm,entryPoint{1});
                                if~strcmp(entryPointBlock.Type,'ModelReference')

                                    entryPoint=slrealtime.internal.streamingSignalInfoUtil.findRootLevelSubsystemParentSID(...
                                    codeDescriptor,entryPointBlock);
                                end
                            else
                                entryPoint=topLevelModelOrSubsystemBlockSID;
                            end
                        end


                        if~isnan(str2double(sig.sampleTimeString))
                            if dataIntrfCont.Timing.TimingMode==coder.descriptor.TimingModes.CONTINUOUS
                                dmr_model=codeDescriptor.getMF0FullModel;

                                period=dmr_model.SampleTimeInfo.ModelFixedStepSize;
                                offset=0;
                            else
                                period=dataIntrfCont.Timing.SamplePeriod;
                                offset=dataIntrfCont.Timing.SampleOffset;
                            end

                            foundIt=false;
                            for nTask=1:numTasks
                                if taskInfos(nTask).samplePeriod==period&&...
                                    taskInfos(nTask).sampleOffset==offset&&...
                                    (isempty(entryPoint)||any(strcmp(entryPoint,taskInfos(nTask).entryPoints)))
                                    sig.tid=nTask-1;
                                    foundIt=true;
                                    break;
                                end
                            end
                            if~foundIt
                                sig=[];
                                return;
                            end
                        end
                    end
                end
            end
        end

        function str=getSignalStringToDisplay(signalStruct)
            if~isempty(signalStruct.signame)
                str=signalStruct.signame;
            else
                signalCell=signalStruct.blockpath.convertToCell();
                if length(signalCell)>1
                    str=signalCell{1};
                    for j=2:length(signalCell)
                        str=strcat(str,'/',extractAfter(signalCell{j},'/'));
                    end
                else
                    str=signalCell{1};
                end

                if signalStruct.portindex~=-1
                    str=strcat(str,':',num2str(signalStruct.portindex));
                else
                    str=strcat(str,':',signalStruct.statename);
                end

            end
        end

        function[codeDesc,slrt_task_info,app]=getCodeDescriptorFromMLDATX(mldatxfile)
            if~exist(mldatxfile,'file')
                slrealtime.internal.throw.Error('slrealtime:instrument:NoAppFile',mldatxfile);
            end

            try
                app=slrealtime.Application(mldatxfile);
                app.extract('/host/dmr/');
                wd=app.getWorkingDir;
                RTWDirStruct=load(fullfile(wd,'host','dmr','RTWDirStruct.mat'));
                codeDescFolder=fullfile(wd,'host','dmr',RTWDirStruct.dirStruct.RelativeBuildDir);
                codeDesc=coder.internal.getCodeDescriptorInternal(codeDescFolder,247362);

                app.extract('/misc/');
                mldatxMiscFolder=fullfile(wd,'misc');
                slrt_task_info=fullfile(mldatxMiscFolder,'slrealtime_task_info.m');
                assert(exist(slrt_task_info,'file')==2);

            catch
                codeDesc=[];
                slrt_task_info=[];
                app=[];
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidApp',mldatxfile);
            end
        end

        function updateNVBusNames(type,info)
            if isempty(info),return;end
            for i=1:length(type.structElements)
                type.structElements(i).structElementName=...
                info.Children(i).SDISignalName;

                if~isempty(type.structElements(i).structElements)
                    slrealtime.internal.streamingSignalInfoUtil.updateNVBusNames(type.structElements(i),info.Children(i));
                end
            end
        end
    end
end
