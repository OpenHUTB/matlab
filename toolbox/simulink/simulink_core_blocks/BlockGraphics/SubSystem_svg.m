function res=Subsystem_svg(funcName,varargin)
    f=str2func(funcName);
    res=f(varargin{:});
end

function res=isEditable(elemId)
    res=true;
end

function res=onTextEditComplete(blockHandle,elemId,portSide,portIndex,text)
    res='OK';
    if isempty(portSide)||portIndex<0;return;end

    portIndex=portIndex+1;
    subsys=get(blockHandle,'object');
    if strcmp(portSide,'L')
        portBlock=SLBlockIcon.ImportedSLGraphUtil.getInportBlock(subsys,portIndex);
    elseif strcmp(portSide,'R')
        portBlock=SLBlockIcon.ImportedSLGraphUtil.getOutportBlock(subsys,portIndex);
    end

    SLBlockIcon.setBlockParamsWithUndo(portBlock.Handle,'Name',text);











end
