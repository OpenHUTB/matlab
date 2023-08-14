function varargout=nesl_addedblockregistry(varargin)














    persistent blockRegistry;

    if isempty(blockRegistry)
        blockRegistry=containers.Map;
    end

    switch nargin
    case 0



        blockRegistry.remove(blockRegistry.keys);

    case 1



        block=varargin{1};
        if blockRegistry.isKey(block)
            varargout{1}=blockRegistry(block);
        else
            varargout{1}='';
        end

    case 2



        block=varargin{1};
        blockRegistry(block)=varargin{2};

    otherwise
        pm_assert(0,'unknown mode');

    end

end
