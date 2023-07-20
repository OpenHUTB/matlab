function fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,inportIdxList)%#ok










    topLvlMDL=blkObj.getParent;
    while~isa(topLvlMDL,'Simulink.BlockDiagram')

        parentMDL=getParent(topLvlMDL);
        topLvlMDL=parentMDL;
    end

    if~strcmpi(topLvlMDL.SimulationStatus,'stopped')




        inportDTStrs=blkObj.CompiledPortDataTypes.Inport;
        numInports=length(inportDTStrs);
        if(~isequal(inportIdxList,unique(inportIdxList)))
            error(message('vision:visionautoscaler:nonunique'));
        elseif~all(ismember(inportIdxList,1:numInports))
            error(message('vision:visionautoscaler:invalidportindex'));
        end
        for inpIdx=1:length(inportIdxList)

            isInportUnsigned=...
            strncmpi(inportDTStrs{inportIdxList(inpIdx)},'u',1)||...
            strncmpi(inportDTStrs{inportIdxList(inpIdx)},'fltu',4);

            if isInportUnsigned



                fixdtSignValStr='0';
            else



                fixdtSignValStr='1';
                break;
            end
        end
    else



        fixdtSignValStr='[]';
    end


