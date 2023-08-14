function pathItems=getBlkPathItemsFromPort(blkObj,inputID,outputID)






    pathItems={};
    inputNum=[];
    outputNum=[];

    if isempty(inputID)&&isempty(outputID)
        return;
    end

    if isa(blkObj,'Simulink.Signal')
        pathItems={outputID};
        return;
    end

    if~isempty(inputID)

        if~isempty(regexp(inputID,'^[0-9]','ONCE'))
            inputNum=str2double(inputID);
        else
            pathItems={inputID};
            return;
        end
    end
    if~isempty(outputID)

        if~isempty(regexp(outputID,'^[0-9]','ONCE'))
            outputNum=str2double(outputID);
        else
            pathItems=getPathItemWithStatePathItemSwap(outputID,blkObj);
            return;
        end
    end


    blkAutoscaler=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface().getAutoscaler(blkObj);


    pathItems=blkAutoscaler.getPortMapping(blkObj,inputNum,outputNum);


    if isempty(pathItems)||isempty(pathItems{:})
        pathItems={outputID};
    end
end

function pathItems=getPathItemWithStatePathItemSwap(outputID,blkObj)










    pathItems={outputID};
    if strcmp(outputID,'States')



        ae=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
        ea=ae.getAutoscaler(blkObj);
        existingPathIemts=ea.getPathItems(blkObj);
        if~any(strcmp(outputID,existingPathIemts))
            pathItems={'1'};
        end
    end
end

