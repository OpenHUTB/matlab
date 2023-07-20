function editedData=editDataPoint(dataToBeEdited,inputData,item)






    [rootID,sigID]=Simulink.stawebscope.servermanager.util.getRootAndSigID(item);


    repoUtil=starepository.RepositoryUtility();
    metaData_sig=repoUtil.getMetaDataStructure(sigID);
    metaData_parent=repoUtil.getMetaDataStructure(rootID);

    if metaData_sig.TreeOrder~=metaData_parent.TreeOrder
        columnLocation=metaData_sig.TreeOrder-metaData_parent.TreeOrder+1;
    else
        columnLocation=2;
    end

    dataToBeOffset=struct;

    for kRefinePoint=1:length(dataToBeEdited.newPoint)

        if ischar(dataToBeEdited.newPoint(kRefinePoint).x)
            dataToBeEdited.newPoint(kRefinePoint).x=datacreation.internal.resolveMinMaxStr2Num(dataToBeEdited.newPoint(kRefinePoint).x,item.DataType);
            dataToBeEdited.oldPoint(kRefinePoint).x=datacreation.internal.resolveMinMaxStr2Num(dataToBeEdited.oldPoint(kRefinePoint).x,item.DataType);

        end

        if ischar(dataToBeEdited.newPoint(kRefinePoint).y)
            dataToBeEdited.newPoint(kRefinePoint).y=datacreation.internal.resolveMinMaxStr2Num(dataToBeEdited.newPoint(kRefinePoint).y,item.DataType);
            dataToBeEdited.oldPoint(kRefinePoint).y=datacreation.internal.resolveMinMaxStr2Num(dataToBeEdited.oldPoint(kRefinePoint).y,item.DataType);
        end
    end


    dataToBeOffset.offset_x=dataToBeEdited.newPoint(1).x-dataToBeEdited.oldPoint(1).x;
    if strcmp(item.DataType,'string')
        dataToBeOffset.offset_y=0;
    else


        dataToBeOffset.offset_y=dataToBeEdited.newPoint(1).y-dataToBeEdited.oldPoint(1).y;

        if(strcmp(item.DataType,'logical')||...
            strcmp(item.DataType,'boolean'))&&isfield(dataToBeEdited,'offsetYOverride')
            dataToBeOffset.offset_y=dataToBeEdited.offsetYOverride;
        end
    end


    xMinId=0;
    xMaxId=0;

    pointId=length(dataToBeEdited.oldPoint);

    for id=length(inputData):-1:1
        sigTime=inputData{id}{1};

        if ischar(sigTime)
            sigTime=datacreation.internal.resolveMinMaxStr2Num(sigTime,item.DataType);
        end

        if dataToBeEdited.oldPoint(pointId).x==sigTime||strcmp(num2str(dataToBeEdited.oldPoint(pointId).x),inputData{id}{1})
            dataToBeEditedY=Simulink.stawebscope.servermanager.util.processData(dataToBeEdited.oldPoint(pointId).y,item);
            sigData=inputData{id}{columnLocation};

            if islogical(dataToBeEditedY)&&ischar(sigData)
                sigData=datacreation.internal.resolveMinMaxStr2Num(sigData,item.DataType);
            end

            sigData=Simulink.stawebscope.servermanager.util.processData(sigData,item);
            if Simulink.stawebscope.servermanager.util.compareData(dataToBeEditedY,sigData)||strcmp(num2str(dataToBeEditedY),num2str(sigData))

                if xMaxId==0
                    xMaxId=id;
                else
                    xMinId=id;
                end
                pointId=pointId-1;
                if pointId==0
                    if xMinId==0
                        xMinId=xMaxId;
                    end
                    break;
                end
            end
        end
    end





    if xMinId==0&&xMaxId>1
        xMinId=xMaxId-1;
    end

    if xMinId==0||xMaxId==0
        editedData=inputData;
        return;
    end

    dataToBeOffset.lowerLimitX=min(dataToBeEdited.newPoint(1).x,dataToBeEdited.newPoint(end).x);
    dataToBeOffset.higherLimitX=max(dataToBeEdited.newPoint(1).x,dataToBeEdited.newPoint(end).x);


    offsetRange=Simulink.stawebscope.servermanager.offsetData(dataToBeOffset,inputData(xMinId:xMaxId),item);


    editedData=[inputData(1:xMinId-1),offsetRange,inputData(xMaxId+1:end)];

end
