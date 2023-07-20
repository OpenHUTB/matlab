function addFilterBom(characHandle,p)



    isMLHDLCFlow=hdlismatlabmode();
    if isempty(isMLHDLCFlow)

        isMLHDLCFlow=false;
    end

    resrc=PersistentHDLResource;
    if~isempty(resrc)
        for i=1:length(resrc)
            thisComp=resrc(i).comp;

            if~isMLHDLCFlow
                if(~strcmp(thisComp.Owner.getCtxName,p.ModelName))
                    continue;
                end
            end

            compType=resrc(i).bom.keys;
            compNum=resrc(i).bom.values;
            if~isempty(compType)&&~isempty(compNum)
                instNum=resrc(i).numInst;
                owner=thisComp.Owner;
                if~isMLHDLCFlow
                    while(owner.SimulinkHandle==-1&&~isempty(owner.instances))
                        inst=owner.instances;
                        owner=inst(1).Owner;
                    end
                else

                    p2=pir;
                    owner=p2.getTopNetwork;
                end
                bom=characHandle.getBillOfMaterials(owner);
                for j=1:length(compType)
                    thisCompType=compType{j};
                    thisCompNum=compNum{j}*instNum;
                    opType=thisCompType(1:8);
                    numPorts=2;
                    if strcmpi(opType,'reg_comp')
                        numPorts=1;
                    end
                    bom.addCompInfoByName(thisComp,thisCompType,opType,numPorts,1,thisCompNum);
                end
            end
        end
    end
end