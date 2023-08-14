function[status,dscr]=tlmg_GenerateTestbenchOnOffDepend(cs,name)

    status=configset.internal.data.ParamStatus.Normal;
    dscr='';

    propVal=cs.getProp('tlmgTargetOSSelect');
    l_host=computer;

    switch(propVal)
    case 'Linux 64'
        if(~strcmp(l_host,'GLNXA64'))
            status=configset.internal.data.ParamStatus.InAccessible;
        end

    case 'Windows 64'
        if(~strcmp(l_host,'PCWIN64'))
            status=configset.internal.data.ParamStatus.InAccessible;
        end

    end
end