classdef SignalSelectorUtilities<handle






    properties(Constant)
        UtilsFunction='Simulink.scopes.source.SignalSelectorController.Util';
        SigScopeMgrFunction='sigandscopemgr';
    end

    methods(Static,Access=public)
        function addSelection(blockHandle,inputNumber,slObjects,relPath,modelRefBlockHandle)



















            if iscell(slObjects)
                slObjects=[slObjects{:}]';
            end

            if(isempty(slObjects)||~ishandle(slObjects))
                return
            end

            parentBlock=get_param(slObjects(1),'Parent');
            parentBlockIsInsideModelRef=slsignalselector.utils.SignalSelectorUtilities....
            i_IsObjectInsideModelRef(blockHandle,parentBlock);

            if(parentBlockIsInsideModelRef)
                blkHandleToBeAdded=modelRefBlockHandle;
            else
                blkHandleToBeAdded=slObjects(1);
            end


            if(strcmp(get_param(slObjects(1),'Type'),'block')||parentBlockIsInsideModelRef)

                sIOSigs=get_param(blockHandle,'IOSignals');
                ioSigs{inputNumber}.Handle=blkHandleToBeAdded;
                ioSigs{inputNumber}.RelativePath=relPath;
                if(~isempty(sIOSigs))

                    sIOSigs{inputNumber}([sIOSigs{inputNumber}.Handle]==-1)=[];
                    sIOSigs{inputNumber}(end+1)=ioSigs{inputNumber};
                else
                    DAStudio.error('Simulink:blocks:NoIOSignals');
                end

                set_param(blockHandle,'IOSignals',sIOSigs)
            else

                ports=slObjects;
                try
                    feval(slsignalselector.utils.SignalSelectorUtilities.UtilsFunction,...
                    'AddSelection',blockHandle,inputNumber,ports);
                catch ME
                    ME.message;
                end
            end

            slsignalselector.utils.SignalSelectorUtilities.updateSignalScopeManager(blockHandle);
        end

        function result=removeSelection(blockHandle,inputNumber,slObjects,relPath,modelRefBlockHandle)



















            result=0;

            if iscell(slObjects)
                slObjects=[slObjects{:}]';
            end

            if(isempty(slObjects)||~ishandle(slObjects))
                return
            end

            parentBlock=get_param(slObjects(1),'Parent');
            parentBlockIsInsideModelRef=slsignalselector.utils.SignalSelectorUtilities....
            i_IsObjectInsideModelRef(blockHandle,parentBlock);

            if(parentBlockIsInsideModelRef)
                blkHandleToBeRemoved=modelRefBlockHandle;
            else
                blkHandleToBeRemoved=slObjects(1);
            end

            viewerMask=Simulink.Mask.get(blockHandle);
            isMPlay=~isempty(viewerMask)&&contains(viewerMask.Type,'MPlay');


            if(strcmp(get_param(slObjects(1),'Type'),'block')||parentBlockIsInsideModelRef)&&~isMPlay

                sIOSigs=get_param(blockHandle,'IOSignals');
                rC=[];


                for m=1:length(sIOSigs{inputNumber})
                    if(strcmp(relPath,sIOSigs{inputNumber}(m).RelativePath))
                        if(blkHandleToBeRemoved==sIOSigs{inputNumber}(m).Handle)
                            rC=m;
                            result=1;
                        end
                    end
                end
                sIOSigs{inputNumber}(rC)=[];
                set_param(blockHandle,'IOSignals',sIOSigs)
            else

                ports=slObjects;
                try
                    if~isMPlay
                        feval(slsignalselector.utils.SignalSelectorUtilities.UtilsFunction,...
                        'RemoveSelection',blockHandle,inputNumber,ports);
                    else
                        feval(slsignalselector.utils.SignalSelectorUtilities.SigScopeMgrFunction,...
                        'RemoveSelection',blockHandle,inputNumber,ports);
                    end
                    result=1;
                catch ME
                    ME.message;
                end
            end

            slsignalselector.utils.SignalSelectorUtilities.updateSignalScopeManager(blockHandle);
        end

        function switchSelection(blockHandle,inputNumber,oldPort,newPort,relPath,modelRefBlockHandle,SSMUpdateCallback)






















            if(strcmp(get_param(bdroot(blockHandle),'SimulationStatus'),'running'))
                MSLDiagnostic('Simulink:blocks:SigSelectionNADuringSim').reportAsWarning;
                return
            end

            parentBlock=get_param(newPort,'Parent');
            parentBlockIsInsideModelRef=slsignalselector.utils.SignalSelectorUtilities....
            i_IsObjectInsideModelRef(blockHandle,parentBlock);

            if(parentBlockIsInsideModelRef)
                blkHandleToBeAdded=modelRefBlockHandle;
            else
                blkHandleToBeAdded=newPort;
            end

            if(strcmp(get_param(newPort,'type'),'block')||parentBlockIsInsideModelRef)
                sIOSigs=get_param(blockHandle,'IOSignals');
                if(~isempty(sIOSigs))
                    sIOSigs{inputNumber}=struct('Handle',blkHandleToBeAdded,'RelativePath',relPath);
                    set_param(blockHandle,'IOSignals',sIOSigs)
                end
            else
                try
                    feval(slsignalselector.utils.SignalSelectorUtilities.SigScopeMgrFunction,...
                    'SwitchSelection',blockHandle,inputNumber,oldPort,newPort);
                catch ME %#ok<*NASGU>
                    ME.message;
                end
            end

            slsignalselector.utils.updateSSMConnectedSignals(blockHandle,SSMUpdateCallback);
        end

        function switchInputOrDisplaySelection(blockHandle,selectionHandle,oldInputNumber,newInputNumber)












            sIOSigs=get_param(blockHandle,'IOSignals');
            if ischar(oldInputNumber)
                oldInputNumber=str2double(oldInputNumber);
            end
            outportHandles=[sIOSigs{oldInputNumber}.Handle];
            sigIdx=arrayfun(@(x)x==selectionHandle,outportHandles);

            relPath=sIOSigs{oldInputNumber}(sigIdx);
            if(~isempty(sIOSigs))


                isScope=strcmp('Scope',get_param(blockHandle,'BlockType'));



                unconnectedAxes=false;
                if numel(sIOSigs{newInputNumber})==1&&sIOSigs{newInputNumber}.Handle==-1
                    unconnectedAxes=true;
                end
                if isScope||unconnectedAxes

                    sIOSigs{newInputNumber}([sIOSigs{newInputNumber}.Handle]==-1)=[];
                    sIOSigs{newInputNumber}(end+1)=sIOSigs{oldInputNumber}(sigIdx);


                    if numel(sIOSigs{oldInputNumber})>1
                        sIOSigs{oldInputNumber}(sigIdx)=[];
                    else
                        sIOSigs{oldInputNumber}(sigIdx).Handle=-1;
                        sIOSigs{oldInputNumber}(sigIdx).RelativePath='';
                    end
                else




                    swapAxesTemp=sIOSigs{oldInputNumber};
                    sIOSigs{oldInputNumber}=sIOSigs{newInputNumber};
                    sIOSigs{newInputNumber}=swapAxesTemp;
                end
                set_param(blockHandle,'IOSignals',sIOSigs);
            else
                DAStudio.error('Simulink:blocks:NoIOSignals');
            end


            Simulink.scopes.SigScopeMgr.updateAllSSMWindows()
        end
    end


    methods(Static,Hidden,Access=public)

        function updateSignalScopeManager(blockHandle)








            try
                bindModeObject=BindMode.BindMode.getInstance();
                SSMUpdateCallback=[];

                if~isempty(bindModeObject)
                    SSMUpdateCallback=bindModeObject.bindModeSourceDataObj.UpdateCallback;
                end
                slsignalselector.utils.updateSSMConnectedSignals(blockHandle,SSMUpdateCallback);
            catch ME
                ME.message;
            end
        end

        function out=i_IsObjectInsideModelRef(ScopeBlock,SubSystemBlock)

            scopeRootName=get_param(bdroot(ScopeBlock),'Name');
            subsysRootName=get_param(bdroot(SubSystemBlock),'Name');

            out=~strcmp(scopeRootName,subsysRootName);
        end

        function[modelRefBlockIndex,SFBlockIndex]=hasSelectionModelRefOrSF(selectionHandles)

            modelRefBlockIndex=[];
            SFBlockIndex=[];

            selectedBlocks=strcmp(get_param(selectionHandles,'Type'),'block');


            if~any(selectedBlocks)
                return
            end


            selectedBlocks=selectionHandles(selectedBlocks);




            SFBlocks=arrayfun(@(x)strcmp(slsignalselector.utils.SignalSelectorUtilities....
            determineBlockType(x),'Stateflow'),selectedBlocks);


            if any(SFBlocks)
                SFBlockIndex=slsignalselector.utils.SignalSelectorUtilities....
                findBlockIndexForModelRefAndSF(SFBlocks,selectedBlocks,selectionHandles);
            end


            modelRefBlocks=strcmp(get_param(selectedBlocks,'BlockType'),'ModelReference');


            if any(modelRefBlocks)
                modelRefBlockIndex=slsignalselector.utils.SignalSelectorUtilities....
                findBlockIndexForModelRefAndSF(modelRefBlocks,selectedBlocks,selectionHandles);
            end
        end

        function[blockHandleIndex]=findBlockIndexForModelRefAndSF(blockTypeHandles,selectedBlocks,selectionHandles)







            modelBlockHandle=unique(selectedBlocks(blockTypeHandles));

            blockHandleIndex=zeros(numel(modelBlockHandle),numel(selectionHandles));
            for i=1:numel(modelBlockHandle)


                blockHandleIndex(i,:)=modelBlockHandle(i)==selectionHandles;
            end

            blockHandleIndex=logical(sum(blockHandleIndex,1));

        end

        function[relPaths,ParentMdlBlkHandle,ports]=getRelativePath(hierarchicalPath,ports,...
            PortsAndBlocks)










            if(~isempty(PortsAndBlocks))
                portParent=get_param(ports,'Parent');



                IDX=strfind(hierarchicalPath,['|',bdroot(portParent)]);
                if~isempty(IDX)
                    hierarchicalPath=hierarchicalPath(1:IDX(end));
                end

                portParent=get_param(ports,'Parent');
                encPortParent=slprivate('encpath',portParent,'','','none');
                pn=get_param(ports,'PortNumber');
                relPaths=[hierarchicalPath,encPortParent];




                [pathParentMdlBlk,~,relPaths]=slprivate('decpath',relPaths,true);
                if(~isempty(relPaths))
                    relPaths=[relPaths,':o',num2str(pn)];
                    try
                        ParentMdlBlkHandle=get_param(pathParentMdlBlk,'Handle');
                    catch ME
                        ME.message;
                        ParentMdlBlkHandle=PortsAndBlocks;
                    end
                end




                isSubsystem=~strcmp(bdroot(portParent),get_param(PortsAndBlocks,'Parent'));
                if~isSubsystem
                    ports=PortsAndBlocks{1};
                end
            end
        end

        function metaData=createMRMetaData(outportRelativePaths,modelRefHandles)

            [encPath,portNumber]=strtok(outportRelativePaths,':');
            outportNumber=str2double(portNumber(end));

            noSpecialCharsEncPath=encPath;
            noSpecialCharsEncPath(encPath==newline)=' ';





            modelHierarchy=strsplit(noSpecialCharsEncPath,'|');
            hierPath=getfullname(modelRefHandles);
            restPath='';
            for i=numel(modelHierarchy):-1:1

                if isempty(restPath)
                    restPath=modelHierarchy{i};
                else
                    restPath=[modelHierarchy{i},'|',restPath];
                end





                if any(strfind(modelHierarchy{i},'~'))
                    modelHierarchy{i}=slprivate('decpath',modelHierarchy{i},true);
                end
            end

            hierPath=[hierPath,'|',restPath];

            hierarchicalPathArr={hierPath};
            hierarchicalPathArr{end+1}=getfullname(modelRefHandles);
            hierarchicalPathArr=horzcat(hierarchicalPathArr,modelHierarchy);

            metaDataStruct.hierarchicalPathArr=hierarchicalPathArr;


            if any(strfind(encPath,'~'))
                IDX=strfind(encPath,'|');
                IDX=[0,IDX,numel(encPath)];
                noSpecCharEncPath='';
                for i=1:numel(IDX)-1
                    tempPath=slprivate('decpath',encPath(IDX(i)+1:IDX(i+1)),true);
                    if isempty(noSpecCharEncPath)
                        noSpecCharEncPath=tempPath;
                    else
                        noSpecCharEncPath=[noSpecCharEncPath,'|',tempPath];
                    end
                end
                encPath=noSpecCharEncPath;
            end

            IDX=strfind(encPath,'|');
            tempEncPath=encPath;
            for i=1:numel(IDX)
                tempEncPath=encPath(IDX(i)+1:end);
            end

            blockPathStr=tempEncPath;












            encPath=tempEncPath;
            modelName=strtok(blockPathStr,'/');



            if~bdIsLoaded(modelName)
                try


                    load_system(modelName)
                catch
                    DAStudio.error('Simulink:blocks:ModelNotFound',modelName);
                end
            end
            isStateflow=0;



            isValidHandle=getSimulinkBlockHandle(encPath);
            if isValidHandle>0
                try
                    portHandles=get_param(encPath,'PortHandles');
                    signalName=get_param(portHandles.Outport(outportNumber),'Name');
                    metaDataStruct.blockPathStr=blockPathStr;
                catch
                end
            else

                pathIdx=strfind(encPath,'/');
                for i=0:numel(pathIdx)-1
                    tempEncPath=encPath(1:pathIdx(end-i)-1);


                    isValidHandle=getSimulinkBlockHandle(tempEncPath);
                    if isValidHandle==-1
                        continue;
                    end
                    isStateflow=strcmp(slsignalselector.utils.SignalSelectorUtilities....
                    determineBlockType(get_param(tempEncPath,'Handle')),'Stateflow');
                    if isStateflow

                        blockPathStr=tempEncPath;



                        [signalName,relPath,~,~,sfInfo]=slsignalselector.utils....
                        SignalSelectorUtilities.getSFSignalData(get_param(blockPathStr,'Handle'),1,hierarchicalPathArr{1},outportRelativePaths);
                        if isempty(relPath)
                            isValidHandle=-1;
                            break;
                        end
                        if isfield(sfInfo,'blockPathStr')
                            metaDataStruct.blockPathStr=sfInfo.blockPathStr;
                        else
                            metaDataStruct.blockPathStr=relPath;
                        end
                        isValidHandle=0;
                        break;
                    end
                end
                if isValidHandle==-1
                    metaData=[];
                    return;
                end
            end

            if(signalName)
                metaDataStruct.name=signalName;
            else

                blockName=get_param(blockPathStr,'Name');
                metaDataStruct.name=[blockName,':',num2str(outportNumber)];
            end

            if isStateflow
                if~isempty(relPath)
                    metaDataStruct.name=signalName;
                    metaDataStruct.sid=sfInfo.sid;
                    metaDataStruct.localPath=sfInfo.localPath;




                    IDX=strfind(metaDataStruct.hierarchicalPathArr{1},'|');
                    if isempty(IDX)
                        tempHierPath=metaDataStruct.hierarchicalPathArr{1}(1:end-numel(signalName)-1);
                    else
                        tempHierPath=[metaDataStruct.hierarchicalPathArr{1}(1:IDX(end)),sfInfo.localPath];
                    end
                    metaDataStruct.hierarchicalPathArr{1}=tempHierPath;
                    if sfInfo.isSFData
                        metaDataStruct.scope=sfInfo.SFDataScope;
                        bindableType='SFDATA';
                    else

                        metaDataStruct.activityType=sfInfo.activityType;
                        bindableType='SFSTATE';
                    end
                end
            else
                metaDataStruct.outputPortNumber=outportNumber;
                metaDataStruct.id=['sig',':',metaDataStruct.name,':',metaDataStruct.hierarchicalPathArr{1},':',num2str(outportNumber)];
                bindableType='SLSIGNAL';
            end
            metaData=BindMode.utils.getBindableMetaDataFromStruct(bindableType,metaDataStruct);

        end

        function[bindableName,relPath,parent,port,sfInfo]=getSFSignalData(sfBlk,isInsideModelRefBlock,encPath,outportRelativePaths,signalMetaData)



            sfChart=sf('Private','block2chart',sfBlk);



            sfTps=sf('Private','test_points_in',sfChart,0,sfBlk);

            chartPath=getfullname(sfBlk);
            sfInfo={};

            if~isInsideModelRefBlock
                sigRelPathStem='StateflowChart';
                sigHandle=sfBlk;
            else



                IDX=strfind(encPath,['|',bdroot(chartPath)]);
                if~isempty(IDX)
                    encPath=encPath(1:IDX(end));
                end
                encChartPath=slprivate('encpath',chartPath,'','','none');

                sigRelPathStem=[encPath,encChartPath];













                [topMFBlk,~,sigRelPathStem]=slprivate('decpath',sigRelPathStem,true);


                chartPath=sigRelPathStem;
                sigHandle=get_param(topMFBlk,'Handle');
            end

            objId=sfTps;
            bindableName=[];
            relPath=[];


            if isempty(objId)
                parent=-1;
                port=-1;
                return
            end








            if nargin>4



                validSignal=1;

                stateHandle=Simulink.ID.getHandle(signalMetaData.sid);
                sfInfo.bindableName=get(stateHandle,'Name');






                sigRelPathStem_comp=regexprep(sigRelPathStem,'\n',' ');

                if isempty(strfind(sigRelPathStem_comp,stateHandle.Path))


                    IDX=strfind(stateHandle.Path,'/');
                    tempPath=stateHandle.Path;
                    for i=numel(IDX):-1:1
                        tempPath=tempPath(1:IDX(i)-1);
                        if contains(sigRelPathStem_comp,tempPath)
                            break
                        end
                    end
                    subPath=strrep(stateHandle.Path(IDX(i)+1:end),'/','.');
                    sfInfo.blockPathStr=[sigRelPathStem,stateHandle.Path(IDX(i):end)];
                    sigRelPathStem=[sigRelPathStem,'/',subPath];


                    relPath=sprintf('%s.%s:o1',sigRelPathStem,sfInfo.bindableName);
                else
                    relPath=sprintf('%s/%s:o1',sigRelPathStem,sfInfo.bindableName);
                end
                sfInfo.sid=Simulink.ID.getSID(stateHandle);
                sfInfo.isSFData=isa(stateHandle,'Stateflow.Data');
                sfInfo.SFDataScope='Local';
                if sfInfo.isSFData
                    sfInfo.SFDataScope=stateHandle.Scope;
                end
                sfInfo.activityType='self activity';
                sfInfo.isSFData=isa(stateHandle,'Stateflow.Data');
                sfInfo.SFDataScope='Local';
                if sfInfo.isSFData
                    sfInfo.SFDataScope=stateHandle.Scope;
                end
                sfInfo.path=stateHandle.Path;
            else



                validSignal=0;
                for i=1:numel(objId)
                    bindableName=sf('FullNameOf',objId(i),sfChart,'.');
                    relPath=sprintf('%s/%s:o1',sigRelPathStem,bindableName);
                    if numel(objId)>1
                        if~isempty(outportRelativePaths)&&...
                            (contains(outportRelativePaths,relPath)||...
                            contains(relPath,outportRelativePaths))
                            validSignal=1;




                            stateHandle=sf('IdToHandle',objId(i));
                            sfInfo.bindableName=get(stateHandle,'Name');
                            sfInfo.sid=Simulink.ID.getSID(stateHandle);
                            sfInfo.isSFData=isa(stateHandle,'Stateflow.Data');
                            sfInfo.SFDataScope='Local';
                            sfInfo.localPath=stateHandle.Path;
                            if sfInfo.isSFData
                                sfInfo.SFDataScope=stateHandle.Scope;
                            end

                            sfInfo.activityType='self activity';
                            sfInfo.path=stateHandle.Path;

                            break;
                        end
                    else
                        validSignal=1;
                        stateHandle=sf('IdToHandle',objId(i));
                        sfInfo.bindableName=get(stateHandle,'Name');
                        sfInfo.sid=Simulink.ID.getSID(stateHandle);
                        sfInfo.activityType='self activity';
                        sfInfo.isSFData=isa(stateHandle,'Stateflow.Data');
                        sfInfo.SFDataScope='Local';
                        if sfInfo.isSFData
                            sfInfo.SFDataScope=stateHandle.Scope;
                        end
                        sfInfo.path=stateHandle.Path;
                        sfInfo.localPath=stateHandle.Path;
                    end
                end
            end

            if validSignal
                parent=chartPath;
                port=sigHandle;
            else
                bindableName=[];
                relPath=[];
                parent=-1;
                port=-1;
                return
            end

        end

        function metaData=createSFMetaData(signalName,blockPathStr,parentPathStr,outputPortNumber)

            metaDataStruct.name=signalName;
            metaDataStruct.blockPathStr=blockPathStr;
            metaDataStruct.hierarchicalPathArr=SLM3I.SLDomain.getHierarchicalBlockPath(get_param(parentPathStr,'Handle'));
            metaDataStruct.outputPortNumber=outputPortNumber;
            metaDataStruct.id=['sig',':',metaDataStruct.name,':',metaDataStruct.hierarchicalPathArr{1},':',num2str(outputPortNumber)];

            metaData=BindMode.utils.getBindableMetaDataFromStruct('SLSIGNAL',metaDataStruct);

        end

        function metaDataStruct=createSFDataMetaData(signalName,sid,localPath,scope)
            metaDataStruct.name=signalName;
            metaDataStruct.sid=sid;
            metaDataStruct.localPath=localPath;
            metaDataStruct.scope=scope;
            metaDataStruct.hierarchicalPathArr{1}=localPath;
            metaDataStruct.hierarchicalPathArr{2}=localPath;
        end

        function metaDataStruct=createSFStateMetaData(signalName,sid,localPath,activityType)
            metaDataStruct.name=signalName;
            metaDataStruct.sid=sid;
            metaDataStruct.localPath=localPath;
            metaDataStruct.activityType=activityType;
            metaDataStruct.hierarchicalPathArr{1}=localPath;
            metaDataStruct.hierarchicalPathArr{2}=localPath;
        end

        function validRows=notBindableSignalTypes(selectionRows)



            validRowsIdx=ones(1,numel(selectionRows));
            for i=1:numel(selectionRows)




                blockPath=strtrim(selectionRows{i}.bindableMetaData.hierarchicalPathArr{end-1});
                if~any(strfind(blockPath,'~'))
                    blockHandle=get_param(blockPath,'Handle');
                else
                    blockHandle=selectionRows{i}.bindableMetaData.blockPathStr;
                end

                blockType=slsignalselector.utils.SignalSelectorUtilities.determineBlockType(blockHandle);
                if~strcmp(blockType,'block')
                    blockHandle=get_param(blockHandle,'Parent');
                    isBlock=get_param(blockHandle,'Type');
                    if strcmp(isBlock,'block')
                        blockType=slsignalselector.utils.SignalSelectorUtilities.determineBlockType(blockHandle);
                    else
                        blockType=isBlock;
                    end
                end

                if(strcmp(get_param(blockHandle,'Type'),'block')&&...
                    strcmp(blockType,'SubSystem')&&...
                    (~isempty(get_param(blockHandle,'BlockChoice'))||...
                    isequal(get_param(blockHandle,'IsForEachSSOrInside'),'on')))

                    validRowsIdx(i)=0;
                    activeEditor=BindMode.utils.getLastActiveEditor();
                    assert(~isempty(activeEditor));
                    if~isempty(get_param(blockHandle,'BlockChoice'))
                        BindMode.utils.showHelperNotification(activeEditor,message('Spcuilib:scopes:ConfigurableSSNotSupportedTextViewer').string());
                    elseif isequal(get_param(blockHandle,'IsForEachSSOrInside'),'on')
                        BindMode.utils.showHelperNotification(activeEditor,message('Spcuilib:scopes:ForEachSSNotSupportedTextViewer').string());
                    end
                end
            end
            validRows=selectionRows(logical(validRowsIdx));
        end


        function blkType=determineBlockType(blkHandle)

            blkType=get_param(blkHandle,'BlockType');

            if slprivate('is_stateflow_based_block',blkHandle)
                blkType='Stateflow';
            end
        end

        function[modelRefBlockHandle,modelRefBlockIndex]=hasSelectionModelRef(selectionHandles)

            selectedBlocks=strcmp(get_param(selectionHandles,'Type'),'block');

            if~any(selectedBlocks)
                modelRefBlockHandle=-1;
                modelRefBlockIndex=[];
                return
            end

            selectedBlocks=selectionHandles(selectedBlocks);

            modelRefBlocks=strcmp(get_param(selectedBlocks,'BlockType'),'ModelReference');

            if~any(modelRefBlocks)
                modelRefBlockHandle=-1;
                modelRefBlockIndex=[];
                return
            end



            modelRefBlockHandle=unique(selectedBlocks(modelRefBlocks));

            modelRefBlockIndex=zeros(numel(modelRefBlockHandle),numel(selectionHandles));
            for i=1:numel(modelRefBlockHandle)


                modelRefBlockIndex(i,:)=modelRefBlockHandle(i)==selectionHandles;
            end

            modelRefBlockIndex=logical(sum(modelRefBlockIndex,1));
        end

        function[selectionHandles,blks]=hasVariantSS(selectionHandles)

            parents=get_param(selectionHandles,'Parent');
            if~iscell(parents)
                parents={parents};
            end



            blks=zeros(1,numel(parents));
            for i=1:length(parents)
                if~isempty(parents{i})&&...
                    strcmp(get_param(parents{i},'Type'),'block')&&...
                    strcmp(get_param(parents{i},'BlockType'),'SubSystem')&&...
                    strcmp(get_param(parents{i},'Variant'),'on')
                    blks(i)=i;
                end
            end
            if(~isempty(blks))
                selectionHandles(~blks)=[];
            end
        end

    end
end

