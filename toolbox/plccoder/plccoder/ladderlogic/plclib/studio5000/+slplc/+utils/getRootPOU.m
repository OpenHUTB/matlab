function rootPOUBlock=getRootPOU(block,varargin)
    rootPOUType='';
    if~isempty(varargin)
        rootPOUType=varargin{1};
    end

    parentPOUBlock=block;
    while~isempty(parentPOUBlock)
        block=parentPOUBlock;
        parentPOUBlock=slplc.utils.getParentPOU(block,'Scoped');

        if isempty(rootPOUType)&&isempty(parentPOUBlock)
            break
        end

        if~isempty(rootPOUType)&&isempty(parentPOUBlock)
            block=[];
            break;
        end

        if~isempty(rootPOUType)&&~isempty(parentPOUBlock)&&...
            strcmpi(rootPOUType,slplc.utils.getParam(parentPOUBlock,'PLCPOUType'))
            block=parentPOUBlock;
            break;
        end
    end

    rootPOUBlock=block;
end