function sharedList=gatherSharedDT(this,variableIdentifier)




    sharedList={};
    sharedParams={};


    mlBlk=variableIdentifier.getMATLABFunctionBlock;
    if isempty(mlBlk)||variableIdentifier.isStruct
        return;
    end

    sfDataObject=this.hGetRelatedSFData(variableIdentifier);

    if~isempty(sfDataObject)

        if variableIdentifier.IsArgin&&sfDataObject.Port>0
            inport=mlBlk.PortHandles.Inport(sfDataObject.Port);
            portObj=get_param(inport,'Object');
            [srcBlkObj,srcPathItem,srcInfo]=getSourceSignal(this,portObj,false);

            inputShare.blkObj=srcBlkObj;
            inputShare.pathItem=srcPathItem;
            inputShare.srcInfo=srcInfo;
            sharedParams{end+1}=inputShare;
        end

        paramRec.blkObj=sfDataObject;
        paramRec.pathItem='1';
        sharedParams{end+1}=paramRec;

        paramRec.blkObj=variableIdentifier;
        paramRec.pathItem=variableIdentifier.VariableName;
        sharedParams{end+1}=paramRec;

        sharedList=this.hAppendToSharedLists(sharedList,sharedParams);
    end






