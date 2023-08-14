function blkContext=hGetValidContext(h,blkObj)%#ok<INUSL>





    blkContext=blkObj;

    while(~checkValidContext(blkContext))
        blkContext=blkContext.getParent;
    end


    function isValidContext=checkValidContext(blkContext)
        isValidContext=isa(blkContext,'Stateflow.Chart')||...
        isa(blkContext,'Stateflow.EMChart')||...
        isa(blkContext,'Stateflow.TruthTableChart')||...
        isa(blkContext,'Simulink.BlockDiagram')||...
        isa(blkContext,'Stateflow.LinkChart')||...
        isa(blkContext,'Stateflow.StateTransitionTableChart');


