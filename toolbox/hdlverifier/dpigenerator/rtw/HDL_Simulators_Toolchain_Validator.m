function[status,mesg]=HDL_Simulators_Toolchain_Validator(tool)




    if contains(getName(tool),'Mentor Graphics QuestaSim/Modelsim')
        [status_sys,~]=system('vsim -version');
        HDLTool='Mentor Graphics QuestaSim/Modelsim';
    elseif contains(getName(tool),'Cadence Xcelium')
        [status_sys,~]=system('xrun -version');
        HDLTool='Cadence Xcelium';
    else
        status=false;
        mesg='Toolchain not found. Click ''Apply'' to save the toolchain settings.';
        return;
    end

    if status_sys
        msg=message('HDLLink:DPIG:NoToolOnPath',HDLTool);
        mesg=msg.getString;
        status=false;
    else
        mesg='Toolchain was found on the system path.';
        status=true;
    end


