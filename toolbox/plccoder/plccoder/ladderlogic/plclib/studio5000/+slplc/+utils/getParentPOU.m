function pouBlock=getParentPOU(block,varargin)
    isScoped=false;
    if~isempty(varargin)&&strcmpi(varargin{1},'Scoped')
        isScoped=true;
    end

    if~isempty(slplc.utils.getParam(block,'PLCPOUType'))
        block=get_param(block,'Parent');
    end
    pouBlock=locGetPareantPOU(block,isScoped);
end

function pouBlock=locGetPareantPOU(block,isScoped)
    pouBlock='';

    if strcmp(block,bdroot(block))
        return
    end

    pouType=slplc.utils.getParam(block,'PLCPOUType');
    if~isempty(pouType)&&(~isScoped||(isScoped&&~strcmpi(pouType,'subroutine')))
        pouBlock=block;
    else
        block=get_param(block,'Parent');
        pouBlock=locGetPareantPOU(block,isScoped);
    end

end