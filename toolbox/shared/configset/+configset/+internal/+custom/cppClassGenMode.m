function[status,dscr]=cppClassGenMode(cs,name)

    dscr=[name,' is InAccessible if IsCPPClassGenMode is on and CPPComponent is available'];

    status=configset.internal.data.ParamStatus.Normal;
    classGenMode=cs.getProp('IsCPPClassGenMode');
    isClassGen=strcmp(classGenMode,'on');
    if isClassGen
        ert=cs.getComponent('Code Generation').getComponent('Target');
        if isa(ert,'Simulink.ERTTargetCC')&&~isempty(configset.ert.getCPPComponent(ert))
            status=configset.internal.data.ParamStatus.InAccessible;
        end
    end
