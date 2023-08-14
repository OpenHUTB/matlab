function msg=navDoorsToSl(objString)




    msg='';
    transFromStr=' from "';
    startIdx=strfind(objString,transFromStr);

    if isempty(startIdx)

        modelName=strtok(objString,'/');
    else

        [~,fromStr,toStr]=rmisf.parse_trans_path(objString);

        if~isempty(fromStr)

            modelName=strtok(fromStr,'/');
        else

            modelName=strtok(toStr,'/');
        end
    end


    try
        open_system(modelName);
        modelH=get_param(modelName,'Handle');
    catch Mex %#ok<NASGU>
        modelH=[];

        if~isempty(startIdx)



            altModelName=strtok(objString,'/');
            if~isempty(altModelName)
                modelName=altModelName;
                try
                    open_system(modelName);
                    modelH=get_param(modelName,'Handle');
                catch Mex %#ok<NASGU>
                    modelH=[];
                end
            end
        end
    end

    if isempty(modelH)
        msg=getString(message('Slvnv:rmi:navigate:CouldNotResolveModel',modelName));
        return;
    end



    if strcmp(get_param(modelH,'ReqHilite'),'on')
        set_param(modelH,'ReqHilite','off');
    else
        action_highlight('clear');
    end

    try
        handle=get_param(objString,'Handle');
    catch Mex %#ok<NASGU>




        handle=[];
    end

    if~isempty(handle)




        if Stateflow.SLUtils.isChildOfStateflowBlock(handle)
            subsysUddH=get_param(objString,'Object');
            stateflowObjUddH=Stateflow.SLUtils.getStateflowUddH(subsysUddH);
            highlightInStateflow(stateflowObjUddH.Id);
        else
            highlightInSimulink(handle,modelName);
        end
    else

        handle=rmisf.path2handle(objString);
        if sf('ishandle',handle)
            highlightInStateflow(handle);
        else

            [handle,groupIndex]=rmisl.sigbPath2handle(objString);
            if ishandle(handle)&&(groupIndex>=1)
                highlightInSigBuilder(handle,groupIndex);
            else

                msg=getString(message('Slvnv:rmi:navigate:CouldNotResolveObject',objString));
            end
        end
    end
end

function highlightInSimulink(handle,modelName)


    parent=get_param(handle,'Parent');
    if isempty(parent)
        reqmgt('winFocus',[modelName,'$']);
    else
        open_system(parent,'force');
        action_highlight('reqHere',handle);
        parentName=get_param(parent,'name');
        isPrimaryBlock=true;
        while~isempty(get_param(parent,'Parent'))
            isPrimaryBlock=false;
            parent=get_param(parent,'Parent');
            primeBlockName=get_param(parent,'name');
        end
        if isPrimaryBlock
            reqmgt('winFocus',[parentName,'$']);
        else
            reqmgt('winFocus',[primeBlockName,'.*',regexprep(parentName,'[\n\r\f\t]',' ')]);
        end
    end
end

function highlightInStateflow(handle)
    [autogen,srcHandle]=sf('get',handle,'.autogen.isAutoCreated','.autogen.source');

    if autogen&&srcHandle>0&&~isReactiveTestingTable(srcHandle)
        objSfHandle=srcHandle;
    else
        objSfHandle=handle;
    end
    sf('Open',objSfHandle);
    target_chart=action_highlight_sf('req',objSfHandle);

    chartBlock=sf('Private','chart2block',target_chart);
    set_param(chartBlock,'HiliteAncestors','reqInside');
end

function yesno=isReactiveTestingTable(id)
    if sf('get',id,'.isa')==1
        sfRoot=sfroot;
        chartObj=sfRoot.idToHandle(id);
        yesno=isa(chartObj,'Stateflow.ReactiveTestingTableChart');
    else
        yesno=false;
    end
end

function highlightInSigBuilder(handle,groupIndex)
    parent=get_param(handle,'Parent');
    if~isempty(parent)
        open_system(parent,'force');
        action_highlight('reqInside',handle);

        rmisl.navigateToSigbuilder(handle,groupIndex);
    end
end

