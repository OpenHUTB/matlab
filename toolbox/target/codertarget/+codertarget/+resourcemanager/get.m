function value=get(hBlk,family,name,varargin)





    if isequal(nargin,3)
        model=codertarget.utils.getModelForBlock(hBlk);
        hCS=getActiveConfigSet(model);
    elseif isa(varargin{1},'Simulink.ConfigSet')
        hCS=varargin{1};
    else
        hCS=getActiveConfigSet(varargin{1});
    end

    data=codertarget.resourcemanager.getAllResources(hCS);

    if~codertarget.resourcemanager.isregistered(hBlk,family,name,hCS)

        value=0;
        return
    else
        value=data.(family).(name);
    end

end