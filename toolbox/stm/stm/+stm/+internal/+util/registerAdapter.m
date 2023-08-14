

function registerAdapter(adapterHandelOrName,varargin)
    isDefaultAdapter=false;
    if~isempty(varargin)
        if~isa(varargin{1},'logical')
            error(message('stm:LinkToExternalFile:SecondArgumentRegisterAdapterNotLogical',varargin{1}));
        end
        isDefaultAdapter=varargin{1};
    end

    if isa(adapterHandelOrName,'function_handle')
        adapterName=func2str(adapterHandelOrName);
    elseif isa(adapterHandelOrName,'char')
        adapterName=adapterHandelOrName;
    else
        error(message('stm:LinkToExternalFile:InvalidAdapterFormat'));
    end

    adapterPath=which(adapterName);

    if(isempty(adapterPath)||strcmp(adapterPath,'variable'))
        error(message('stm:LinkToExternalFile:AdapterNotOnPath',adapterName));
    end

    [~,adapterName,ext]=fileparts(adapterPath);
    if(~strcmpi(ext,'.m')&&~strcmpi(ext,'.mlx'))
        error(message('stm:LinkToExternalFile:AdapterShouldBeMatlabFile'));
    end

    stm.internal.registerAdapter(adapterName,isDefaultAdapter);
end
