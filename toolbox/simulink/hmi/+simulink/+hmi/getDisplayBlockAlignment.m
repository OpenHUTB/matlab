

function alignment=getDisplayBlockAlignment(msg)
    switch msg
    case DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment')
        alignment=int32(0);
    case DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment')
        alignment=int32(1);
    case DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment')
        alignment=int32(2);
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidAlignmentEnum'));
    end
end
