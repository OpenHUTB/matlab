function[out,dscr]=PLC_TargetIDE_entries(cs,~)


    dscr='PLC_TargetIDE has dynamic enum values';

    if strcmp(cs.get_param('PLC_ShowFullTargetList'),'on')
        str=plcprivate('plc_targetide_strings','codes');
        disp=plcprivate('plc_targetide_strings','strings');
    else
        currentTarget=cs.get_param('PLC_TargetIDE');
        str=plcprivate('plc_targetide_strings','pref_target_ide_codes');
        disp=plcprivate('plc_targetide_strings','pref_target_ide_names');
        if~any(strcmp(currentTarget,str))
            currentTargetString=plcprivate('plc_targetide_strings','code2string',currentTarget);
            str{end+1}=currentTarget;
            disp{end+1}=currentTargetString;
        end
    end
    out=struct('str',str,'disp',disp);