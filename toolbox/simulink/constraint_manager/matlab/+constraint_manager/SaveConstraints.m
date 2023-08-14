function success=SaveConstraints(varargin)



    aDialog=varargin{1};
    environment=varargin{2};

    dataModelObject=aDialog.getConstraintManagerModelObject();
    if isempty(dataModelObject)
        success=true;
        return;
    end
    blockHandle=dataModelObject.BlockHandle;


    if~isempty(blockHandle)

        if~strcmp(get_param(bdroot(blockHandle),'SimulationStatus'),'stopped')
            error(message('Simulink:Masking:Simulate'));
        end
    end


    maskObj=Simulink.Mask.get(blockHandle);
    if isempty(maskObj)
        Simulink.Mask.create(blockHandle);
    end
    try
        aMaskObj=Simulink.Mask.get(blockHandle);
        saveAllConstraints(dataModelObject,aMaskObj)
        success=true;
    catch exp
        msg=slprivate('getExceptionMsgReport',exp);
        errordlg(msg);
        success=false;
    end

    function isSharedContext=isSharedContext(constraintObj)
        isSharedContext=strcmp(constraintObj.context.StaticMetaClass.qualifiedName...
        ,'simulink.constraintmanager.SharedContext');
    end

    function isMaskContext=isMaskContext(constraintObj)
        isMaskContext=strcmp(constraintObj.context.StaticMetaClass.qualifiedName...
        ,'simulink.constraintmanager.MaskContext');
    end

    function saveAllConstraints(dataModelObject,aMaskObj)
        aMaskObj.removeAllParameterConstraints();
        aMaskObj.removeAllCrossParameterConstraints();
        aMaskObj.removeAllPortConstraints();
        aMaskObj.removeAllCrossPortConstraints();
        aMaskObj.removeAllPortIdentifiers();
        aMaskObj.removeAllPortConstraintAssociations();

        savePortIdentifiers(dataModelObject,aMaskObj);

        allConstraints=dataModelObject.constraints;
        for i=1:allConstraints.Size
            constraintObj=allConstraints(i);
            if(isMaskContext(constraintObj))
                saveMaskConstraint(dataModelObject,constraintObj,aMaskObj);
            end
        end


        savePortConstraintAssociations(dataModelObject,aMaskObj);


        saveAllSharedConstraint(dataModelObject);
    end

    function saveMaskConstraint(dataModelObject,constraintObj,aMaskObj)
        switch constraintObj.type
        case 'ParameterConstraint'
            parameterConstraint=constraint_manager.ModelUtils.createParameterConstraintObject(constraintObj);
            aMaskObj.addParameterConstraint(parameterConstraint);

        case 'CrossParameterConstraint'
            crossparameterConstraint=constraint_manager.ModelUtils.createCrossParameterConstraintObject(constraintObj);
            aMaskObj.addCrossParameterConstraint(crossparameterConstraint);

        case 'PortConstraint'
            portConstraint=constraint_manager.ModelUtils.createPortConstraintObject(constraintObj);
            aMaskObj.addPortConstraint(portConstraint);

        case 'CrossPortConstraint'
            crossPortConstraint=constraint_manager.ModelUtils.createCrossPortConstraintObject(dataModelObject,constraintObj);
            aMaskObj.addCrossPortConstraint(crossPortConstraint);
        end
    end

    function saveAllSharedConstraint(dataModelObject)
        MATFilesObject=dataModelObject.MATFiles;
        try
            [warningMsgs]=constraint_manager.SharedConstraintsHelper.saveAllSharedConstraintsToMATFile(MATFilesObject);
            if~isempty(warningMsgs)
                warndlg(warningMsgs);
            end
        catch exception
            rethrow(exception)
        end
    end

    function savePortConstraintAssociations(dataModelObject,aMaskObj)
        allAssociations=dataModelObject.portConstraintAssociations;
        portConstraintIds=allAssociations.keys();

        for i=1:length(portConstraintIds)
            portIdentifiersIds=allAssociations.getByKey(portConstraintIds{i}).portIdentifierIds.toArray;
            portIdentifiersNames=cellfun(@(a)constraint_manager.ModelUtils.getPortIdentifierName...
            (dataModelObject,a),portIdentifiersIds,'UniformOutput',false);

            portConstraintName=constraint_manager.ModelUtils.getPortConstraintName(dataModelObject,portConstraintIds{i});
            if~isempty(portConstraintName)&&~isempty(portIdentifiersNames)
                aMaskObj.addPortConstraintAssociation(portConstraintName,portIdentifiersNames);
            end
        end
    end

    function savePortIdentifiers(dataModelObject,aMaskObj)
        portIdentifiers=dataModelObject.portIdentifiers;
        for j=1:portIdentifiers.Size
            pi=constraint_manager.ModelUtils.createPortIdentifier(portIdentifiers(j));
            aMaskObj.addPortIdentifier(pi);
        end
    end
end

