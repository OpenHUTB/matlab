function needed=checkNeedsConstraint(blkObj)





















    blkType=class(blkObj);
    notneeded=(blkType=="Simulink.Inport"&&blkObj.IsBusElementPort=="on")||...
    (blkType=="Simulink.BusCreator"||blkType=="Simulink.BusSelector")||...
    (blkType=="Simulink.Mux"||blkType=="Simulink.Demux")||...
    (blkType=="Simulink.Goto"||blkType=="Simulink.From")||...
    (blkType=="Simulink.SubSystem"||blkType=="Simulink.ModelReference")||...
    (blkObj.CompiledIsActive=="off");

    needed=~notneeded;
end

