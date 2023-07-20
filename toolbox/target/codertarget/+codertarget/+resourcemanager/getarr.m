function value=getarr(hBlk,family,name,varargin)





    if isequal(nargin,3)
        model=codertarget.utils.getModelForBlock(hBlk);
        hCS=getActiveConfigSet(model);
    elseif isa(varargin{1},'Simulink.ConfigSet')
        hCS=varargin{1};
    else
        hCS=getActiveConfigSet(varargin{1});
    end

    if nargin>3
        isRegistered=codertarget.resourcemanager.isregistered(hBlk,family,name,varargin{1});
    else
        isRegistered=codertarget.resourcemanager.isregistered(hBlk,family,name);
    end

    if~isRegistered

        value=0;
        return
    else
        data=codertarget.resourcemanager.getAllResources(hCS);
        val=data.(family).(name);
        if~iscell(val)
            value={val};
        else
            value=val;
        end
    end

end