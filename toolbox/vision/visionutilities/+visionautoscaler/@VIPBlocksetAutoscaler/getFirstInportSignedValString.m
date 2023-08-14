function signedValStr=getFirstInportSignedValString(~,blkObj)



    topLvlMDL=blkObj.getParent;
    while~isa(topLvlMDL,'Simulink.BlockDiagram')
        parentMDL=getParent(topLvlMDL);
        topLvlMDL=parentMDL;
    end

    if~strcmpi(topLvlMDL.SimulationStatus,'stopped')


        inportDTStrs=blkObj.CompiledPortDataTypes.Inport;


        isInportUnsigned=...
        strncmpi(inportDTStrs{1},'u',1)||...
        strncmpi(inportDTStrs{1},'fltu',4);

        if isInportUnsigned
            signedValStr='0';
        else
            signedValStr='1';
        end
    else

        signedValStr='[]';
    end