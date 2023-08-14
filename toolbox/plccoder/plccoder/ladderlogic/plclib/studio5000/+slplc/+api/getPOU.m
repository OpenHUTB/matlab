function paramValue=getPOU(block,varargin)



    if isempty(varargin)

        params={...
        'PLCBlockType',...
        'PLCPOUType',...
        'PLCPOULanguage',...
        'PLCPOUName',...
        'PLCOperandTag',...
        'VariableList',...
        'LogicBlock',...
        'EnableBlock',...
        'PrescanBlock',...
        'EnableInFalseBlock'};

        if strcmpi(get_param(block,'Mask'),'on')
            maskObj=Simulink.Mask.get(block);
            maksParamNames={maskObj.Parameters.Name};
            params=union(params,maksParamNames);
        end

        for paramCount=1:numel(params)
            param=params{paramCount};
            paramValue.(param)=slplc.api.getPOU(block,param);
        end

    else

        if numel(varargin)~=1
            error('slplc:invalidArgumentNumber',...
            'Wrong number (%d) of input arguments detected. 1 or 2 argument are needed for slplc.api.getPOU.',...
            numel(varargin)+1);
        end
        paramName=varargin{1};

        logicBlk=localGetInternalBlockPath(block,'Logic');
        if strcmpi(paramName,'VariableList')
            if~isempty(logicBlk)
                paramValue=slplc.utils.getVariableList(block);
            else
                paramValue=[];
            end
        elseif strcmpi(paramName,'EnableBlock')
            paramValue=localGetInternalBlockPath(block,'Enable');
        elseif strcmpi(paramName,'PrescanBlock')
            paramValue=localGetInternalBlockPath(block,'Prescan');
        elseif strcmpi(paramName,'EnableInFalseBlock')
            paramValue=localGetInternalBlockPath(block,'EnableInFalse');
        elseif strcmpi(paramName,'LogicBlock')
            paramValue=logicBlk;
        else
            paramValue=slplc.utils.getParam(block,paramName);
        end

    end

end

function blockPath=localGetInternalBlockPath(block,shortName)
    blockPath=slplc.utils.getInternalBlockPath(block,shortName);
    if isempty(blockPath)||getSimulinkBlockHandle(blockPath)<=0
        blockPath=[];
    end
end
