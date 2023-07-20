function applySimStateForSlicedModel(msObj,simStateSlice,sliceMdl,sliceMapper)






    simStateOrig=msObj.SimState;
    hasMultiInstanceRef=~isempty(msObj.mdlRefCtxMgr)&&msObj.mdlRefCtxMgr.hasMultiInstanceRefMdls;


    overwriteBlockLoggedStates();


    sfBaseBlkH=Transform.AtomicGroup.getStateflow(get_param(sliceMdl,'Handle'));
    if~isempty(sfBaseBlkH)
        overwriteStateflowSimState(sfBaseBlkH);
    end


    if~isempty(msObj.getGlobalDsmNames())||~isempty(msObj.getLocalDsms())
        overwriteDSMSimState();
    end

    simStateName=get_param(sliceMdl,'InitialState');
    assignin('base',simStateName,simStateSlice);
    evalin('base',sprintf('save %s %s',simStateName,simStateName));


    function overwriteBlockLoggedStates()

        statesInOrig=containers.Map('KeyType','double','ValueType','any');


        origLoggedStates=simStateOrig.loggedStates;
        if isa(origLoggedStates,'Simulink.SimulationData.Dataset')


            origHasDataSet=true;
            numElementsOrig=origLoggedStates.numElements;
        else
            origHasDataSet=false;
            numElementsOrig=length(origLoggedStates);
        end

        for n=1:numElementsOrig
            if origHasDataSet
                [origBlockH,inRefModel]=resolveBlockPathObj(origLoggedStates.get(n).BlockPath);
                value=origLoggedStates.get(n).Values;
            else
                bPath=origLoggedStates(n).blockName;
                inRefModel=origLoggedStates(n).inReferencedModel;
                if inRefModel
                    origBlockH=resolveBlockInReferencedModel(bPath);
                else
                    origBlockH=get_param(bPath,'Handle');
                end
                value=origLoggedStates(n).values;
            end

            if msObj.isSubsystemSlice


                inRefModel=~(bdroot(origBlockH)==bdroot(msObj.sliceSubSystemH));
            end



            if inRefModel
                sliceBlkH=sliceMapper.findInSlice(origBlockH,get(bdroot(origBlockH),'Name'));
            else
                sliceBlkH=sliceMapper.findInSlice(origBlockH);
            end
            if~isempty(sliceBlkH)


                statesInOrig(sliceBlkH)=value;
            end
        end

        sliceLoggedStates=simStateSlice.loggedStates;
        if isa(sliceLoggedStates,'Simulink.SimulationData.Dataset')
            sliceHasDataSet=true;
            numElementsSlice=sliceLoggedStates.numElements;
        else
            sliceHasDataSet=false;
            numElementsSlice=length(sliceLoggedStates);
        end

        for n=1:numElementsSlice
            if sliceHasDataSet
                nBlock=sliceLoggedStates.get(n).BlockPath.getLength;
                sBpath=sliceLoggedStates.get(n).BlockPath.getBlock(nBlock);
                sliceBlkH=get_param(sBpath,'Handle');
            else
                sBpath=sliceLoggedStates(n).blockName;
                if sliceLoggedStates(n).inReferencedModel
                    sliceBlkH=resolveBlockInReferencedModel(sBpath);
                else
                    sliceBlkH=get_param(sBpath,'Handle');
                end
            end
            if statesInOrig.isKey(sliceBlkH)
                thisStateInOrig=statesInOrig(sliceBlkH);

                try
                    if sliceHasDataSet
                        sigInfo=sliceLoggedStates.get(n);
                        if origHasDataSet
                            if~isequal(sigInfo.Values,thisStateInOrig)
                                sigInfo.Values=thisStateInOrig;
                            end
                        else
                            if~isequal(sigInfo.Values.Data,thisStateInOrig)
                                sigInfo.Values.Data=thisStateInOrig;
                            end
                        end
                        simStateSlice.loggedStates=simStateSlice.loggedStates.setElement(n,sigInfo);
                    else
                        if origHasDataSet
                            if~isequal(simStateSlice.loggedStates(n).values,thisStateInOrig.Data)
                                simStateSlice.loggedStates(n).values=thisStateInOrig.Data;
                            end
                        else
                            if~isequal(simStateSlice.loggedStates(n).values,thisStateInOrig)
                                simStateSlice.loggedStates(n).values=thisStateInOrig;
                            end
                        end
                    end
                catch me
                    if strcmp(me.identifier,'Simulink:SimState:SimStateLoggedStateNotFound')
                        error('ModelSlicer:SimStateForBusExpansion',...
                        getString(message('Sldv:ModelSlicer:ModelSlicer:BusExpandedSimState',getfullname(sliceBlkH))));
                    else
                        rethrow(me);
                    end
                end
            end
        end


        overwriteMergeSimState();


        function blockH=resolveBlockInReferencedModel(bPathInSS)



            out=bPathInSS;
            while~isValidBlockPath(out)
                [out,~,outn]=slprivate('decpath',out,true);
                if isempty(outn)
                    break;
                else
                    out=outn;
                end
            end
            [~,blockH]=isValidBlockPath(out);
            function[yesno,blkH]=isValidBlockPath(path)
                try
                    blkH=get_param(path,'Handle');
                    yesno=~isempty(blkH);
                catch
                    blkH=[];
                    yesno=false;
                end
            end
        end
        function overwriteMergeSimState()




            mergeH=find_system(sliceMdl,'LookUnderMasks','all','FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','Merge');


            if isempty(mergeH)
                return;
            end

            oldVal=slsvTestingHook('SimStateSnapshot',2);
            testHookCleanup=onCleanup(@()slsvTestingHook('SimStateSnapshot',oldVal));


            mergeMapOrig=containers.Map('KeyType','char','ValueType','any');
            mergeMapOrig=Transform.queryStatesInSimState(mergeMapOrig,simStateOrig,'simStateOrig','Merge');
            mergeMapSlice=containers.Map('KeyType','char','ValueType','any');
            mergeMapSlice=Transform.queryStatesInSimState(mergeMapSlice,simStateSlice,'simStateSlice','Merge');

            sliceKeys=mergeMapSlice.keys;

            for m=1:length(sliceKeys)
                mergeSlice=mergeMapSlice(sliceKeys{m});
                origBlockH=sliceMapper.findInOrig(get_param(sliceKeys{m},'Handle'));
                origBlockPath=getfullname(origBlockH);
                if isKey(mergeMapOrig,origBlockPath)
                    mergeOrig=mergeMapOrig(origBlockPath);
                    lhsStr=mergeSlice.pathStr;
                    thisValue=mergeOrig.persistentOutputs;
                    try


                        eval([lhsStr,' = thisValue;']);
                    catch Mx %#ok<NASGU>
                    end
                end
            end
        end
    end


    function overwriteDSMSimState()












        oldVal=slsvTestingHook('SimStateSnapshot',2);
        testHookCleanup=onCleanup(@()slsvTestingHook('SimStateSnapshot',oldVal));

        dsmMapOrig=containers.Map('KeyType','char','ValueType','any');
        dsmMapOrig=Transform.queryStatesInSimState(dsmMapOrig,simStateOrig,'simStateOrig','DataStoreMemory');
        dsmMapSlice=containers.Map('KeyType','char','ValueType','any');
        dsmMapSlice=Transform.queryStatesInSimState(dsmMapSlice,simStateSlice,'simStateSlice','DataStoreMemory');

        dsmNameSlice=dsmMapSlice.keys;
        for n=1:length(dsmNameSlice)
            thisDSMName=dsmNameSlice{n};
            dsmSlice=dsmMapSlice(thisDSMName);

            if isKey(dsmMapOrig,thisDSMName)
                dsmOrig=dsmMapOrig(thisDSMName);
                if isscalar(dsmSlice)&&isscalar(dsmOrig)
                    lhsStr=dsmSlice.pathStr;
                    thisValue=dsmOrig.value;%#ok<NASGU>
                    try


                        eval([lhsStr,' = thisValue;']);
                    catch Mx %#ok<NASGU>
                    end
                else

                    for j=1:length(dsmSlice)
                        sliceBlockH=get_param(dsmSlice(j).BlockPath,'Handle');
                        origBlockH=sliceMapper.findInOrig(sliceBlockH);
                        if~isempty(origBlockH)
                            for k=1:length(dsmOrig)
                                thisOrigBlockH=get_param(dsmOrig(k).BlockPath,'Handle');
                                if origBlockH==thisOrigBlockH
                                    lhsStr=dsmSlice(j).pathStr;
                                    thisValue=dsmOrig(k).value;%#ok<NASGU>
                                    try
                                        eval([lhsStr,' = thisValue;']);
                                    catch Mx %#ok<NASGU>
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end


    function overwriteStateflowSimState(sfBaseBlkH)

        for n=1:length(sfBaseBlkH)

            origBH=sliceMapper.findInOrig(sfBaseBlkH(n));
            sliceBlkPath=getfullname(sfBaseBlkH(n));
            origBlkPath=getfullname(origBH);



            origBlkPath=constructEncodedPath(origBlkPath);
            origSS=simStateOrig.getBlockSimState(origBlkPath);

            simStateSlice=simStateSlice.setBlockSimState(sliceBlkPath,origSS);
        end
    end
    function resultPath=constructEncodedPath(origBlkPath)
        import slslicer.internal.*
        blkH=get_param(origBlkPath,'handle');

        allParentH=SLCompGraphUtil.Instance.getBlockAncestors(blkH,msObj.refMdlToMdlBlk);
        parentH=allParentH(Simulink.SubsystemType.isModelBlock(allParentH));




        resultPath=slprivate('encpath',origBlkPath,'','','modelref');
        for idx=length(parentH):-1:1
            parent=getfullname(parentH(idx));
            resultPath=slprivate('encpath',parent,'',resultPath,'modelref');
        end
    end
    function[origBlockH,inRefModel]=resolveBlockPathObj(blkObj)
        import slslicer.internal.*;
        inRefModel=false;
        if~hasMultiInstanceRef
            nBlock=blkObj.getLength;
            bPath=blkObj.getBlock(nBlock);
            if nBlock>1
                inRefModel=true;
            end
            origBlockH=get_param(bPath,'Handle');
        else
            [origBlockH,inRefModel]=MdlRefCtxMgr.mapBlkPathObjToActHandle(blkObj);
        end
    end
end

