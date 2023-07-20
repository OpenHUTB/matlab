function[errStr,modelH,blockH]=cmd_resolveobj(obj)





    blockH=[];
    modelH=[];

    msg=getString(message('Sldv:checkArgsOptions:ModelOrAtomic'));

    [slObjH,errStr]=Sldv.utils.getObjH(obj,true);
    if isempty(slObjH)
        if isempty(errStr)
            errStr=msg;
        end
        return;
    end

    blockDiagramType=get_param(bdroot(slObjH),'BlockDiagramType');
    switch blockDiagramType
    case 'library'
        errStr=getString(message('Sldv:checkArgsOptions:UnsupLibraries'));
        return;

    case 'subsystem'
        errStr=getString(message('Sldv:checkArgsOptions:UnsupSubsystem'));
        return;
    end



    errStr=sldvprivate('mdl_check_observer_port',slObjH);
    if~isempty(errStr)
        return;
    end

    if bdroot(slObjH)~=slObjH
        blockH=slObjH;
        modelH=bdroot(blockH);


        if slavteng('feature','ExtractModelReference')
            isPortCheckNeeded=~strcmp(get_param(blockH,'BlockType'),'ModelReference');
        else
            isPortCheckNeeded=~extendFromReferenceHarness(modelH);
        end

        if isPortCheckNeeded
            blockstatus=...
            Sldv.SubSystemExtract.checkPortConfiguration(blockH);
            if blockstatus
                [blockstatus,errStr]=Sldv.SubSystemExtract.checkPorts(blockH);
            else
                errStr=msg;
            end

            if~blockstatus
                return;
            end
        end
    else
        modelH=slObjH;
    end

    if isempty(errStr)
        configSetNames=getConfigSets(modelH);
        nameMatchs=strcmp(configSetNames,'SLDV Temporary Config Set');
        indexEqual=find(nameMatchs);
        if~isempty(indexEqual)
            indexNotEqual=find(~nameMatchs);
            if isempty(indexNotEqual)
                errStr=getString(message('Sldv:Setup:SLDVTemporaryConfigAttached',get_param(modelH,'Name')));
                return;
            end
            dirty=get_param(modelH,'Dirty');
            sldvConfigSet=getConfigSet(modelH,configSetNames{indexEqual});
            if sldvConfigSet.isActive
                setActiveConfigSet(modelH,configSetNames{indexNotEqual(1)});
            end
            detachConfigSet(modelH,sldvConfigSet.Name);
            set_param(modelH,'Dirty',dirty);
        end
    end
end

function status=extendFromReferenceHarness(modelH)



    status=Sldv.HarnessUtils.isSldvGenHarness(modelH)...
    &&(~(isempty(Sldv.HarnessUtils.sigbuild_handle(modelH))))...
    &&slavteng('feature','MergeHarness');
    if status
        testUnitBlock=Sldv.HarnessUtils.extractInlineModel(modelH);
        status=status&&strcmp(get_param(testUnitBlock,'BlockType'),'ModelReference');
    end
end
