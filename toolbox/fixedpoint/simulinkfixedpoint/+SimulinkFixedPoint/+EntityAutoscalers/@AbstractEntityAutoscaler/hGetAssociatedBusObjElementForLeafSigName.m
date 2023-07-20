function busObjID=hGetAssociatedBusObjElementForLeafSigName...
    (h,busSigHier,busLeafSigName,busObjHandleMap)






    busObjID=[];
    hierLevels=regexp(busLeafSigName,'\.','split');

    L=length(hierLevels);

    currentSigH=busSigHier;


    for iLevel=1:L-1

        levelFound=false;

        busHierChildren=currentSigH.Children;



        for iChild=1:length(busHierChildren)
            if strcmp(busHierChildren(iChild).SignalName,hierLevels{iLevel})

                currentSigH=busHierChildren(iChild);
                levelFound=true;
                break;
            end
        end


        if~levelFound
            errorID='SimulinkFixedPoint:autoscaling:UnRecognizedSigNameInSigHier';
            DAStudio.error(errorID,hierLevels{iLevel});
        end
    end


    leafLevelSigName=hierLevels{L};
    leafEleFound=false;


    busHierChildren=currentSigH.Children;


    for iChild=1:length(busHierChildren)
        if strcmp(busHierChildren(iChild).SignalName,leafLevelSigName)




            busOBjectName=h.hCleanDTOPrefix(currentSigH.BusObject);

            if~isempty(busOBjectName)


                busObjHandle=hGetBusObjHandleFromMap(h,...
                busOBjectName,busObjHandleMap);


                busObjEleName=busObjHandle.elementNames{iChild};

                busObjID.blkObj=busObjHandle;
                busObjID.pathItem=busObjEleName;
            end

            leafEleFound=true;
            break;
        end
    end



    if~leafEleFound
        DAStudio.error('SimulinkFixedPoint:autoscaling:UnRecognizedSigNameInSigHier',leafLevelSigName);
    end



