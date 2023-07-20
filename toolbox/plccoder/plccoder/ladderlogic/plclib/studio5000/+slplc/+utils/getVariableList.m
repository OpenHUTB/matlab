function[varList,varSSBlockPath]=getVariableList(pouBlock,varargin)




    varList=[];
    varSSBlockPath='';

    if isempty(pouBlock)
        return
    end

    if numel(varargin)==1&&strcmpi(varargin{1},'VariableSS')
        varSSBlockPath=slplc.utils.getInternalBlockPath(pouBlock,'VariableSS');
        varList=locGetVariableList(varSSBlockPath);
    else
        logicBlockPath=slplc.utils.getInternalBlockPath(pouBlock,'Logic');
        varList=locGetVariableList(logicBlockPath,varargin{:});
    end
end

function varList=locGetVariableList(block,varargin)
    varList=[];
    if getSimulinkBlockHandle(block)<=0,return,end

    plcBlockData=get_param(block,'UserData');
    if isempty(plcBlockData)
        return
    end
    varList=plcBlockData.VariableList;

    for i=1:length(varList)
        if isempty(varList(i).InitialValue)
            varList(i).InitialValue='0';
        end
    end

    if~isempty(varList)&&~isempty(varargin)
        varAttributeName=varargin{1};
        varAttributeValue=varargin{2};
        varList=varList(ismember({varList.(varAttributeName)},varAttributeValue));
    end
end


