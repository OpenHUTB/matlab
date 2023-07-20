function rangeData=getRangeData(obj,range)

    rangeData=mdom.RangeData(range);
    parentID=range.ParentID;

    if strcmp(parentID,'_INVISIBLE_ROOT_')
        mdlNames={obj.dataModel.topModel};
    else
        pNode=obj.dataModel.getNode(parentID);
        mdlNames=pNode.refMdls;
    end

    for r=range.RowStart:range.RowEnd
        mdlName=mdlNames{r+1};
        if strcmp(parentID,'_INVISIBLE_ROOT_')
            id=mdlName;
        else
            id=[parentID,'/',mdlName];
        end
        role=obj.dataModel.getRole(id);


        col=0;
        [data,meta]=obj.getNameData(id,role);
        rangeData.fillData(r,col,data);
        rangeData.fillMetaData(r,col,meta);


        col=col+1;
        [data,meta]=obj.getDeployableData(id,role);
        rangeData.fillData(r,col,data);
        rangeData.fillMetaData(r,col,meta);

        if slfeature('FCPlatform')

            col=col+1;
            [data,meta]=obj.getCoderDictionaryData(id,role);
            rangeData.fillData(r,col,data);
            rangeData.fillMetaData(r,col,meta);


            col=col+1;
            [data,meta]=obj.getCodeInterfaceData(id,role);
            rangeData.fillData(r,col,data);
            rangeData.fillMetaData(r,col,meta);
        end


        col=col+1;
        [data,meta]=obj.getDeploymentTypeData(id,role);
        rangeData.fillData(r,col,data);
        rangeData.fillMetaData(r,col,meta);
    end

