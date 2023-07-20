function[status,dscr]=generateAllocFcn(cs,name)

    dscr=[name,' is InAccessible if the configset is ERT and CPPComponent is available'];

    status=configset.internal.data.ParamStatus.Normal;
    owner=cs.getPropOwner(name);
    if isa(owner,'Simulink.ERTTargetCC')
        cpp=configset.ert.getCPPComponent(owner);
        if~isempty(cpp)
            status=configset.internal.data.ParamStatus.InAccessible;
        end
    end



