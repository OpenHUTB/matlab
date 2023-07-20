classdef MetaModelCommonValidator<m3i.Validator




    properties(Access=private,Transient)
        M3IModelContext;
        PropertiesToVerify;
    end


    methods(Access=public)

        function self=MetaModelCommonValidator(modelOrInterfaceDictName)
            self.M3IModelContext=autosar.api.internal.M3IModelContext.createContext(modelOrInterfaceDictName);
            self.PropertiesToVerify={};


            self.dispatcher.bind('Simulink.metamodel.foundation.NamedElement',@verifyIdentifiable);
            self.dispatcher.bind('Simulink.metamodel.arplatform.common.AUTOSAR',@verifyARRoot);
            self.dispatcher.bind('Simulink.metamodel.arplatform.common.ApplicationError',@verifyApplicationError);
            self.dispatcher.bind('Simulink.metamodel.arplatform.port.ProvidedRequiredPort',@verifyProvideRequirePort);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.IncludedDataTypeSet',@verifyIncludedDataTypeSet);
            self.dispatcher.bind('Simulink.metamodel.arplatform.interface.FlowData',@verifySwAddrMethod);
            self.dispatcher.bind('Simulink.metamodel.arplatform.interface.ArgumentData',@verifySwAddrMethod);
            self.dispatcher.bind('Simulink.metamodel.arplatform.interface.ParameterData',@verifySwAddrMethod);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.IrvData',@verifySwAddrMethod);
        end


        function verifyARRoot(this,arRoot)
            import autosar.mm.util.XmlOptionsAdapter;


            dataObj=autosar.api.getAUTOSARProperties(this.M3IModelContext.getContextName());
            compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
            intBehQName=dataObj.get('XmlOptions','InternalBehaviorQualifiedName');
            impQName=dataObj.get('XmlOptions','ImplementationQualifiedName');

            this.checkQualifiedNameStr(compQName,'ComponentQualifiedName');
            this.checkQualifiedNameStr(intBehQName,'InternalBehaviorQualifiedName');
            this.checkQualifiedNameStr(impQName,'ImplementationQualifiedName');

            duplicates=this.findDuplicates({compQName,intBehQName,impQName});

            if~isempty(duplicates)
                autosar.validation.Validator.logError('RTW:autosar:duplicatePkgPath',duplicates{1});
            end

            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(arRoot.rootModel)




            else
                this.checkPathStr(arRoot,'DataTypePackage');
                this.checkPathStr(arRoot,'InterfacePackage');
            end

            xmlProps=XmlOptionsAdapter.getValidProperties();
            for ii=1:length(xmlProps)
                propertyName=xmlProps{ii};
                switch propertyName
                case{'CompuMethodDirection',...
                    'ImplementationTypeReference',...
                    'SwCalibrationAccessDefault',...
                    'InternalDataConstraintExport',...
                    'UsePlatformTypeReferences',...
                    'NativeDeclaration',...
                    'XmlOptionsSource',...
                    'MoveElements',...
                    'CanBeInvokedConcurrentlyDiagnostic',...
                    'ExportPropagatedVariantConditions',...
                    'IdentifyServiceInstance',...
                    'ExportSwRecordLayoutAnnotationsOnAdminData',...
                    'ExportLookupTableApplicationValueSpecification',...
                    'SchemaVersion'}

                case XmlOptionsAdapter.ComponentSpecificXmlOptions
                    [isMapped,~,m3iComp]=this.M3IModelContext.hasCompMapping();
                    assert(isMapped,'%s must be mapped!',this.M3IModelContext.getContextName());
                    this.checkPathStr(m3iComp,propertyName);
                otherwise
                    this.checkPathStr(arRoot,propertyName);
                end
            end

        end

        function verifyProperties(this,m3iParent,propertyNames)

            if ischar(propertyNames)||isStringScalar(propertyNames)
                propertyNames={propertyNames};
            end
            this.PropertiesToVerify=propertyNames;


            this.verify(m3iParent);


            this.PropertiesToVerify={};
        end

        function verifyIdentifiable(this,m3iIdentifiable)

            maxShortNameLength=this.M3IModelContext.getMaxShortNameLength();
            idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier(...
            {m3iIdentifiable.Name},'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)&&...
                ~isa(m3iIdentifiable,'Simulink.metamodel.types.EnumerationLiteral')
                autosar.validation.Validator.logError('RTW:fcnClass:finish',idcheckmessage);
            end


            this.verifyUniqueChildrenNames(m3iIdentifiable);
        end

        function verifyUniqueChildrenNames(~,obj)

            duplicates=Simulink.metamodel.arplatform.ModelFinder.findObjectsWithDuplicateNames(obj,true);

            if(~duplicates.isEmpty())
                object1=duplicates.at(1);
                object2=duplicates.at(2);

                autosar.validation.Validator.logError('autosarstandard:validation:shortNameCaseClash',...
                object1.Name,sprintf('%s %s',object1.MetaClass.name,autosar.api.Utils.getQualifiedName(object1)),...
                object2.Name,sprintf('%s %s',object2.MetaClass.name,autosar.api.Utils.getQualifiedName(object2)));
            end

        end

        function verifyApplicationError(~,m3iAppErr)

            errCodeValue=m3iAppErr.errorCode;
            if errCodeValue<0||errCodeValue>63
                autosar.validation.Validator.logError('autosarstandard:validation:invalidAppErrValue',...
                autosar.api.Utils.getQualifiedName(m3iAppErr),num2str(errCodeValue));
            end

        end

        function verifyProvideRequirePort(this,m3iPRPort)

            schemaVersion=this.M3IModelContext.getAutosarSchemaVersion();
            [messageID,message]=autosar.validation.ClassicMetaModelValidator.verifyPRPort(autosar.api.Utils.getQualifiedName(m3iPRPort),schemaVersion);
            if~isempty(messageID)
                mException=MException(messageID,message);
                throw(mException);
            end

        end

        function verifyIncludedDataTypeSet(this,includedDataTypeSet)
            if isempty(this.PropertiesToVerify)

                propertiesToVerify={'LiteralPrefix'};
            else
                propertiesToVerify=this.PropertiesToVerify;
            end

            for idx=1:length(propertiesToVerify)
                propertyName=propertiesToVerify{idx};
                switch(propertyName)
                case 'LiteralPrefix'
                    autosar.validation.MetaModelCommonValidator.verifyLiteralPrefix(includedDataTypeSet.LiteralPrefix);
                otherwise
                    assert(false,'Unrecognized property name "%s".',propertyName);
                end
            end
        end

        function verifySwAddrMethod(this,m3iData)

            if~isempty(this.PropertiesToVerify)
                assert(strcmp(this.PropertiesToVerify,'SwAddrMethod'),...
                'Unexpected property');
            end

            if isempty(m3iData.SwAddrMethod)
                return;
            end
            selectedSwAddrMethod=m3iData.SwAddrMethod;
            if isempty(selectedSwAddrMethod.SectionType)

                return;
            end
            selectedSectionTypeStr=selectedSwAddrMethod.SectionType.toString;

            category=autosar.mm.util.SwAddrMethodHelper.getSwAddrMethodCategoryFromM3IObject(m3iData);

            [~,acceptedSectionTypesStr]=autosar.mm.util.SwAddrMethodHelper.getAcceptedSectionTypesForCategory(category);

            if~ismember(selectedSectionTypeStr,acceptedSectionTypesStr)

                autosar.validation.Validator.logError('autosarstandard:validation:invalidSwAddrMethodSectionType',...
                selectedSwAddrMethod.Name,category,selectedSectionTypeStr,autosar.api.Utils.cell2str(acceptedSectionTypesStr));
            end
        end
    end

    methods(Access=private)

        function checkQualifiedNameStr(this,qname,propertyName)

            maxShortNameLength=this.M3IModelContext.getMaxShortNameLength();
            [isvalid,errMsg,errId]=autosarcore.checkIdentifier(qname,'absPathShortName',maxShortNameLength);
            if~isvalid
                errMsg=sprintf('XmlOptions %s %s',propertyName,errMsg);
                me=MException(errId,errMsg);
                throw(me);
            end
        end

        function checkPathStr(this,m3iObj,propertyName)
            import autosar.mm.util.XmlOptionsAdapter;

            if XmlOptionsAdapter.isProperty(propertyName)
                pathStr=XmlOptionsAdapter.get(m3iObj,propertyName);
                if isempty(pathStr)

                    return
                end
            else
                pathStr=m3iObj.(propertyName);
            end

            maxShortNameLength=this.M3IModelContext.getMaxShortNameLength();

            [isvalid,errMsg,errId]=autosarcore.checkIdentifier(pathStr,'absPath',maxShortNameLength);
            if~isvalid
                errMsg=sprintf('XmlOptions %s %s',propertyName,errMsg);
                me=MException(errId,errMsg);
                throw(me);
            end
        end

    end

    methods(Static,Access=private)

        function duplicates=findDuplicates(names)


            numNames=length(names);
            [~,unique_name_indices]=unique(names);
            duplicates=unique(names(setdiff(1:numNames,unique_name_indices)));

        end

        function verifyLiteralPrefix(propertyValue)







            if~isempty(propertyValue)
                [isValid,errmsg,errId]=autosarcore.checkIdentifier(propertyValue,'shortName',128);
                if~isValid
                    error(errId,errmsg);
                end
            end
        end
    end
end



