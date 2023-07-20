function signednessStr=getInportSignednessString(h,blkObj)%#ok










    topLvlMDL=blkObj.getParent;
    while~isa(topLvlMDL,'Simulink.BlockDiagram')

        parentMDL=getParent(topLvlMDL);
        topLvlMDL=parentMDL;
    end

    if~strcmpi(topLvlMDL.SimulationStatus,'stopped')







        inportDTStrs=blkObj.CompiledPortDataTypes.Inport;
        numInports=length(inportDTStrs);

        for inpIdx=1:numInports

            isInportUnsigned=...
            strncmpi(inportDTStrs{inpIdx},'u',1)||...
            strncmpi(inportDTStrs{inpIdx},'fltu',4);

            if isInportUnsigned



                if isequal(inpIdx,numInports)

                    signednessStr='Unsigned';
                end
            else



                signednessStr='Signed';
                break;
            end
        end
    else



        signednessStr='Auto';
    end


