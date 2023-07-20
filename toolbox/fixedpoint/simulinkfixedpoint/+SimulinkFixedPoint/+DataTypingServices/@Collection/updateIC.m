function[busObjectResult,busObjHandle]=updateIC(~,IC,busObjHandle,busObjectResult,leafChildIndex,leafBusElementName)


    if~isempty(IC)&&~isempty(IC.value)

        ICValue=IC.value;
        needUpdate=false;

        if~isstruct(ICValue)
            ICValue=double(ICValue);

            [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(ICValue);
            busObjHandle.updateLeafChildInitCondRange(leafChildIndex,[minVal,maxVal]);
            needUpdate=true;
        else







            if~isempty(IC.mapping)




                ICfieldName=IC.mapping(leafBusElementName);
            else
                ICfieldName=leafBusElementName;
            end



            if isfield(ICValue,ICfieldName)

                leafVal=double(ICValue.(ICfieldName));

                if isstruct(leafVal)
                    errorID='SimulinkFixedPoint:autoscaling:StructForLeafElementNotAllowed';
                    DAStudio.error(errorID);

                end

                [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(leafVal);
                busObjHandle.updateLeafChildInitCondRange(leafChildIndex,[minVal,maxVal]);
                needUpdate=true;


            end
        end
        if(needUpdate)
            elementRange=busObjHandle.leafChildInitialConditionRange{leafChildIndex};

            [modelRequiredMin,modelRequiredMax]=SimulinkFixedPoint.extractMinMax(elementRange);
            busObjectResult.setModelRequiredData(modelRequiredMin,modelRequiredMax);
        end
    end
end






