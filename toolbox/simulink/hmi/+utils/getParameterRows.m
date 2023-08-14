


function rowInfo=getParameterRows(mdl,widgetID,currSelectedBlks,boundElem,widgetType)



    tunableParams={};
    isParam={};
    tunableParamsIdx={};
    paramCtrlBndSrcs={};
    paramCtrlBndUUIDs={};
    paramBndStatus={};
    varWksType={};
    blks={};
    isElemSelected={};
    elements={};
    isComposite={};
    bAddBoundElement=true;
    bUpdateDiagramNeeded=false;
    bHasTunableParams=false;










    if~isempty(boundElem)&&strcmp(boundElem.getElementToDisplay,'1')
        cachedElement=boundElem.Element_;
        boundElem.Element='';
        try



            boundElem.getDoubleValue;
        catch me
            boundElem.Element=cachedElement;
        end
    end
    for i=1:length(currSelectedBlks)
        tpStruct=utils.getTunableParams(currSelectedBlks{i},boundElem);





        if~isempty(tpStruct.isParam)
            isElemSelected{end+1}=true;%#ok %         
            blks{end+1}=currSelectedBlks{i};%#ok
            tunableParams{end+1}=tpStruct.tunableParamsLabel;%#ok           
            tunableParamsIdx{end+1}=tpStruct.tunableParamsIdx;%#ok
            varWksType{end+1}=tpStruct.varWksType;%#ok
            paramBndStatus{end+1}=tpStruct.paramBndStatus;%#ok    
            paramCtrlBndSrcs{end+1}=tpStruct.paramCtrlBndSrcs;%#ok
            paramCtrlBndUUIDs{end+1}=tpStruct.paramCtrlBndUUIDs;%#ok
            isParam{end+1}=tpStruct.isParam;%#ok
            elements{end+1}=tpStruct.element;%#ok
            isComposite{end+1}=tpStruct.isComposite;%#ok
        end

        if~isempty(tpStruct.paramBndStatus)&&...
            any(strcmp(tpStruct.paramBndStatus,'default'))
            bAddBoundElement=false;
        end
        if(tpStruct.bUpdateDiagramNeeded)
            bUpdateDiagramNeeded=true;
        end

        if(tpStruct.bHasTunableParams)
            bHasTunableParams=true;
        end
    end



    if~isempty(boundElem)&&bAddBoundElement&&utils.isValidBinding(boundElem)
        blks{end+1}=boundElem.BlockPath.getBlock(1);
        varWksType{end+1}={boundElem.WksType};
        paramBndStatus{end+1}={'default'};
        paramCtrlBndSrcs{end+1}={''};
        paramCtrlBndUUIDs{end+1}={''};
        isElemSelected{end+1}=false;
        elements{end+1}={boundElem.getElementToDisplay};
        value=boundElem.getValue;
        if(~isempty(boundElem.Element_)||~isscalar(value)||isstruct(value))&&~utils.isLockedLibrary(mdl)
            isComposite{end+1}={true};
        else
            isComposite{end+1}={false};
        end
        if isempty(boundElem.WksType)
            isParam{end+1}={1};
            tunableParams{end+1}={boundElem.ParamName};
        else
            isParam{end+1}={0};
            tunableParams{end+1}={boundElem.VarName};
        end
    end

    blkHandles=get_param(blks,'Handle')';

    blkHandles=cellfun(@(x)num2str(x,64),blkHandles,'UniformOutput',false);
    blkNames=get_param(blks,'Name')';
    bIsInlineParametersOn=strcmpi(get_param(mdl,'InlineParameters'),'on');
    selectionText=getTextBasedOnSelection(currSelectedBlks,tunableParams,widgetType,bHasTunableParams,bIsInlineParametersOn);
    rowInfo={mdl,widgetID,blks,blkNames,blkHandles,tunableParams,varWksType,...
    paramBndStatus,paramCtrlBndSrcs,paramCtrlBndUUIDs,isParam,...
    isElemSelected,bUpdateDiagramNeeded,selectionText,elements,isComposite};
end

function selectionText=getTextBasedOnSelection(blks,tunableParams,widgetType,bHasTunableParams,bIsInlineParametersOn)
    selectionText='';
    if isempty(tunableParams)
        if isempty(blks)
            selectionText=utils.getInitialTextForWidget(widgetType);
        elseif(bHasTunableParams)
            if(bIsInlineParametersOn)
                selectionText=DAStudio.message('SimulinkHMI:selectionwidget:NoTunableParameterInlineParameterOn');
            else
                selectionText=DAStudio.message('SimulinkHMI:selectionwidget:TunableParameterButNoBindableParameter');
            end
        else
            selectionText=DAStudio.message('SimulinkHMI:selectionwidget:NoTunableParamsInSelection');
        end
    end
end



