function[result,storage,isDefault,hasLinkedBlocks]=modelHasReqLinks(modelH,checkLibRefs,checkModelRefs)

    if nargin<2
        checkLibRefs=false;
    end
    if nargin<3
        checkModelRefs=false;
    end

    if rmidata.isExternal(modelH)
        [storage,isDefault]=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
        [hasLinkSet,hasLinkedBlocks,hasLinkedOther]=slreq.artifactHasOutgoingLinks(modelH);%#ok<ASGLU>
        result=hasLinkedBlocks||hasLinkedOther;
    elseif rmidata.storageModeCache('marked_from_lib',modelH)
        storage='';
        result=checkLibRefs;
        hasLinkedBlocks=result;
        isDefault=true;
    else
        storage='';
        result=strcmp(get_param(modelH,'hasReqInfo'),'on');
        if result

            isDefault=~rmi.settings_mgr('get','storageSettings','external');
        else

            isDefault=true;
        end
        hasLinkedBlocks=result;
    end

    if~result&&checkLibRefs
        result=libRefsHaveLinks(modelH);
    end

    if~result&&checkModelRefs

        modelObj=get_param(modelH,'Object');
        mdlBlocks=find(modelObj,'-isa','Simulink.ModelReference');
        for i=1:length(mdlBlocks)
            mdlName=mdlBlocks(i).ModelName;
            try
                mdlH=get_param(mdlName,'Handle');
                if rmisl.modelHasReqLinks(mdlH,true,true)
                    result=true;
                    break;
                end
            catch ex %#ok<NASGU>

            end
        end
    end
end


function result=libRefsHaveLinks(modelH)
    result=false;
    slObjs=find_system(modelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','LookUnderMasks','on','FollowLinks','on','type','block');
    for i=1:length(slObjs)
        myObj=get_param(slObjs(i),'Object');
        switch myObj.StaticLinkStatus;
        case 'implicit'
            libObjPath=getLibObj(myObj);
            if rmi.objHasReqs(libObjPath,[])
                result=true;
                break;
            end
        case 'resolved'
            libObjPath=getLibObj(myObj);
            if rmi.objHasReqs(libObjPath,[]);
                result=true;
                break;
            end

            if slprivate('is_stateflow_based_block',libObjPath)
                if sfRefHasRmiLinks(libObjPath)
                    result=true;
                    break;
                end
            end

        otherwise
            continue;
        end
    end
end


function libObjPath=getLibObj(mdlObj)
    libObjPath=mdlObj.ReferenceBlock;

    try
        get_param(libObjPath,'Handle');
    catch ex %#ok<NASGU>
        load_system(strtok(libObjPath,'/'));
    end
end


function result=sfRefHasRmiLinks(chartObj)
    result=false;
    chartId=sf('Private','block2chart',chartObj);
    if sf('Private','is_eml_chart',chartId)||sf('Private','is_truth_table_chart',chartId)
        return;
    end
    result=sfCheckDescendents(chartId);
end


function result=sfCheckDescendents(parentId)
    result=false;
    trans=sf('TransitionsOf',parentId);
    for tran=trans(:)'
        if rmi.objHasReqs(tran,[])
            result=true;
            return;
        end
    end
    substates=sf('AllSubstatesOf',parentId);
    for state=substates(:)'
        if rmi.objHasReqs(state,[])
            result=true;
            return;
        elseif sfCheckDescendents(state)
            result=true;
            return;
        else
            continue;
        end
    end
end
