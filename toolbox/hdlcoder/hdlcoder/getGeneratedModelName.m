function genModelName=getGeneratedModelName(prefix,baseFileName,varargin)







    if(nargin>2)
        forceClose=varargin{1};
    else
        forceClose=true;
    end

    genModelName=[prefix,baseFileName];

    if(forceClose)
        try
            gmMdlFound=~isempty(find_system('type','block_diagram','name',genModelName));
            if gmMdlFound
                set_param(genModelName,'CloseFcn','');
                close_system(genModelName,0,'CloseReferencedModels',0);
            end
            return;
        catch me %#ok<NASGU>


        end
    end

end