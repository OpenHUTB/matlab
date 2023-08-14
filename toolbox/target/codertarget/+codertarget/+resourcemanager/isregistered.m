function status=isregistered(hBlk,family,name,varargin)





    status=false;
    if isequal(nargin,3)
        if isempty(hBlk)
            return
        end
        model=codertarget.utils.getModelForBlock(hBlk);
        hCS=getActiveConfigSet(model);
    elseif isa(varargin{1},'Simulink.ConfigSet')
        hCS=varargin{1};
    else
        hCS=getActiveConfigSet(varargin{1});
    end

    data=codertarget.resourcemanager.getAllResources(hCS);
    if isfield(data,family)
        if(nargin==2)||isfield(data.(family),name)
            status=true;
            return
        end
    end
end