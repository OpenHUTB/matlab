

classdef ConstraintManagerDataLoader<handle






    properties
BlockHandle
MF0Model
constraintManagerModelObject
    end

    methods
        function obj=ConstraintManagerDataLoader(aMF0Model,aBlockHandle)
            obj.BlockHandle=aBlockHandle;
            obj.MF0Model=aMF0Model;

            aMaskObj=[];
            if~isempty(aBlockHandle)
                aMaskObj=Simulink.Mask.get(aBlockHandle);
            end

            obj.init(aMaskObj);
        end

        function init(this,aMaskObj)
            this.constraintManagerModelObject=simulink.constraintmanager.ConstraintManagerObject(this.MF0Model,struct('BlockHandle',this.BlockHandle));

            this.loadSharedConstraintsFromRegistry();

            if~isempty(aMaskObj)
                this.loadConstraintsFromMaskBlock(aMaskObj);
            end
        end


        function constraintmanagerModelData=getConstraintManagerModelData(this)
            constraintmanagerModelData=this.constraintManagerModelObject;
        end


        function loadConstraintsFromMaskBlock(this,maskObj)

            parameterConstraints=maskObj.ParameterConstraints;
            for i=1:length(parameterConstraints)
                context=constraint_manager.ModelUtils.getMaskContext(this.MF0Model,this.BlockHandle);

                constraint=constraint_manager.ModelUtils.getParameterConstraintModelObj(this.MF0Model,...
                this.getUniqueId(),...
                parameterConstraints(i),context);
                this.constraintManagerModelObject.constraints.add(constraint);
            end

            crossParameterConstraints=maskObj.CrossParameterConstraints;
            for i=1:length(crossParameterConstraints)
                context=constraint_manager.ModelUtils.getMaskContext(this.MF0Model,this.BlockHandle);

                constraint=constraint_manager.ModelUtils.getCrossParameterConstraintModelObj(this.MF0Model,...
                this.getUniqueId(),...
                crossParameterConstraints(i),context);
                this.constraintManagerModelObject.constraints.add(constraint);
            end

            portConstraints=maskObj.PortConstraints;
            for i=1:length(portConstraints)
                context=constraint_manager.ModelUtils.getMaskContext(this.MF0Model,this.BlockHandle);

                constraint=constraint_manager.ModelUtils.getPortConstraintModelObj(this.MF0Model,...
                this.getUniqueId(),...
                portConstraints(i),context);
                this.constraintManagerModelObject.constraints.add(constraint);
            end


            portIdentifiers=maskObj.PortIdentifiers;
            for i=1:length(maskObj.PortIdentifiers)
                portIdentifierObj=simulink.constraintmanager.PortIdentifier(this.MF0Model,...
                struct('id',this.getUniqueId(),...
                'name',portIdentifiers(i).Name,...
                'type',portIdentifiers(i).Type,...
                'identifierType',portIdentifiers(i).IdentifierType,...
                'identifier',portIdentifiers(i).Identifier));
                this.constraintManagerModelObject.portIdentifiers.add(portIdentifierObj);
            end

            portConstraintAssociations=maskObj.PortConstraintAssociations;

            for i=1:length(portConstraintAssociations)
                portConstraintAssociationObj=this.addPortConstraintAssociationsToModel(portConstraintAssociations(i));
                if(~isempty(portConstraintAssociationObj))
                    this.constraintManagerModelObject.portConstraintAssociations.add(portConstraintAssociationObj);
                end
            end

            crossPortConstraints=maskObj.CrossPortConstraints;
            for i=1:length(crossPortConstraints)
                context=constraint_manager.ModelUtils.getMaskContext(this.MF0Model,this.BlockHandle);

                constraint=constraint_manager.ModelUtils.getCrossPortConstraintModelObj(this.MF0Model,...
                this.constraintManagerModelObject,...
                this.getUniqueId(),...
                crossPortConstraints(i),context);
                this.constraintManagerModelObject.constraints.add(constraint);
            end

        end


        function portConstraintAssociationObj=addPortConstraintAssociationsToModel(this,portConstraintAssociationInfo)
            portConstraintAssociationObj=[];
            portConstraintName=portConstraintAssociationInfo.PortConstraintName;
            portIdentifierNames=portConstraintAssociationInfo.PortIdentifiers;

            portConstraintId=constraint_manager.ModelUtils.getPortConstraintId(this.constraintManagerModelObject,...
            portConstraintName);

            if~isempty(portConstraintId)
                portIdentifierIds=cellfun(@(a)constraint_manager.ModelUtils.getPortIdentifierId...
                (this.constraintManagerModelObject,a),portIdentifierNames,...
                'UniformOutput',false);
                portConstraintAssociationObj=simulink.constraintmanager.PortConstraintAssociation(this.MF0Model,...
                struct('constraintId',portConstraintId));
                for j=1:length(portIdentifierIds)
                    portConstraintAssociationObj.portIdentifierIds.add(portIdentifierIds{j});
                end
            end
        end

        function addNewMATFileToModel(this,sharedConstraintList,product,matFileName,matFilePath)
            matFilePathWithFileName=[matFilePath,matFileName];
            if~contains(matFilePathWithFileName,'.mat')
                matFilePathWithFileName=strcat(matFilePathWithFileName,'.mat');
            end

            isMATFileAlreadyLoaded=constraint_manager.ModelUtils.isMATFileLoadedInModel(this.constraintManagerModelObject,...
            matFileName,matFilePathWithFileName);
            if(isMATFileAlreadyLoaded)
                return;
            end

            transaction=this.MF0Model.beginRevertibleTransaction;

            newMATFileObj=simulink.constraintmanager.MATFile(this.MF0Model,struct('id',this.getUniqueId()));

            newMATFileObj.context=constraint_manager.ModelUtils.getSharedContext(this.MF0Model,product,...
            matFileName,matFilePathWithFileName);

            this.addSharedConstraintToModel(sharedConstraintList,newMATFileObj);

            this.constraintManagerModelObject.MATFiles.add(newMATFileObj);

            transaction.commit('MATFileConstraintsLoaded');
        end

        function addSharedConstraintToModel(this,sharedConstraintsList,MATFileObj)
            for k=1:length(sharedConstraintsList)
                sharedContext=constraint_manager.ModelUtils.cloneSharedContext(this.MF0Model,MATFileObj.context);

                constraint=constraint_manager.ModelUtils.getParameterConstraintModelObj(this.MF0Model,...
                this.getUniqueId(),...
                sharedConstraintsList{k},sharedContext);
                MATFileObj.matFileConstraints.add(constraint);
            end
        end


        function loadSharedConstraintsFromRegistry(this)

            allProducts=Simulink.Mask.getAllRegisteredSharedConstraints();
            for i=1:length(allProducts)
                productName=allProducts(i).Product;
                matFiles=allProducts(i).MATFiles;
                for j=1:length(matFiles)
                    matFileName=matFiles{j};
                    matFilePath=constraint_manager.SharedConstraintsHelper.GetAbsMatFileName(matFileName);
                    matFileId=this.getUniqueId();
                    MATFileObj=constraint_manager.ModelUtils.getMATFileModelObject(this.MF0Model,matFileId,productName,matFileName,matFilePath);
                    sharedConstraintsList=constraint_manager.SharedConstraintsHelper.loadMATFileConstraints(matFileName);
                    this.addSharedConstraintToModel(sharedConstraintsList,MATFileObj);
                    this.constraintManagerModelObject.MATFiles.add(MATFileObj);
                end
            end
        end

        function onImportMask(this,aMaskObj)
            this.init(aMaskObj);
        end

        function uuid=getUniqueId(~)
            uuid=matlab.lang.internal.uuid;
        end
    end
end

