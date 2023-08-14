function varargout=nesl_blockregistry(varargin)











    persistent blockRegistry;
    if isempty(blockRegistry)




        blockRegistry=containers.Map;
    end

    if nargin==0



        blockRegistry.remove(blockRegistry.keys);
    elseif nargin==1



        block=varargin{1};
        if blockRegistry.isKey(block)
            solver=blockRegistry(block);
            varargout{1}=solver.name;
            varargout{2}=solver.blockInfo;
            varargout{3}=solver.active;
        else
            varargout{1}='';
            varargout{2}=[];
            varargout{3}=false;
        end
    elseif nargin==2



        block=varargin{1};
        if blockRegistry.isKey(block)
            solver=blockRegistry(block);
            solver.active=varargin{2};
            blockRegistry(block)=solver;
        end
        varargout={};
    elseif nargin==3



        block=varargin{1};
        blockRegistry(block)=struct('name',varargin{2},...
        'blockInfo',varargin{3},...
        'active',false);
        varargout={};
    else



        pm_assert(0,'unknown mode');
    end

end
