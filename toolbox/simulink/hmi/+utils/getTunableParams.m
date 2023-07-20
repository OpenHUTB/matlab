

function tpStruct=getTunableParams(blk,varargin)



    boundElem='';
    if nargin>1
        boundElem=varargin{1};
    end
    tpStruct.isParam={};
    tpStruct.paramCtrlBndSrcs={};
    tpStruct.paramCtrlBndUUIDs={};
    tpStruct.paramBndStatus={};
    tpStruct.varWksType={};
    tpStruct.element={};
    tpStruct.isComposite={};
    mdl=bdroot(blk);
    parameterInterface=Simulink.HMI.ParamInterface(mdl);
    [bindableParams,bUpdateDiagramNeeded,bHasTunableParams]=...
    parameterInterface.getBindableParams(blk);
    tpStruct.tunableParamsLabel={bindableParams.ParamName};
    tpStruct.tunableParamsIdx=...
    num2cell(1:length(tpStruct.tunableParamsLabel));
    tpStruct.bUpdateDiagramNeeded=bUpdateDiagramNeeded;
    tpStruct.bHasTunableParams=bHasTunableParams;
    for i=1:length(tpStruct.tunableParamsLabel)
        tpStruct.isParam{end+1}=strcmp(bindableParams(i).WksType,'');
        tpStruct.paramCtrlBndSrcs{i}='';
        tpStruct.paramCtrlBndUUIDs{i}='';
        tpStruct.element{i}=bindableParams(i).getElementToDisplay;
        value=bindableParams(i).getValue;
        if isa(value,'Simulink.Parameter')
            value=value.Value;
        end
        tpStruct.isComposite{i}=isstruct(value)||~isscalar(value);
        tpStruct.varWksType{i}=bindableParams(i).WksType;

        if~tpStruct.isParam{i}
            tpStruct.tunableParamsLabel{i}=bindableParams(i).VarName;
        end
        tpStruct.paramBndStatus{i}=getBndStatus(boundElem,tpStruct.tunableParamsLabel{i},...
        tpStruct.varWksType{i},blk);
        if strcmp(tpStruct.paramBndStatus{i},'default')
            tpStruct.element{i}=boundElem.getElementToDisplay;
        end
    end
end

function bndStatus=getBndStatus(boundElem,tunableParamsLabel,varWksType,blk)
    bndStatus='';

    fullBlk=Simulink.BlockPath(blk);
    if isempty(boundElem)
        return;
    end
    if~utils.isValidBinding(boundElem)
        return;
    end
    if isempty(boundElem.WksType)
        if(isequal(boundElem.BlockPath,fullBlk)&&...
            strcmp(boundElem.WksType,varWksType)&&...
            strcmp(boundElem.ParamName,tunableParamsLabel))
            bndStatus='default';
        end
    else



        if(strcmp(boundElem.WksType,varWksType)&&...
            strcmp(boundElem.VarName,tunableParamsLabel))
            bndStatus='default';
        end
    end
end