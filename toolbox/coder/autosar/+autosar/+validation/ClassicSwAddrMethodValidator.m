classdef ClassicSwAddrMethodValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyPostProp(this,hModel)
            throwErrors=true;
            this.verifySwAddrMethods(hModel,throwErrors);
        end

    end

    methods(Static,Access=public)


        function[invalidRunnables,invalidRunnableData,invalidInternalData]=...
            verifySwAddrMethods(hModel,throwErrors)











            invalidRunnables={};
            invalidRunnableData={};
            invalidInternalData={};

            mapping=autosar.api.Utils.modelMapping(hModel);
            m3iModel=autosar.api.Utils.m3iModel(hModel);


            mappingPropertiesWithRunnables=autosar.ui.configuration.PackageString.MappingObjWithRunnables;


            [runnableAcceptableSwAddrMethodNames,runnableAcceptedSectionTypes]=...
            autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(m3iModel,'Runnable');
            [runnableDataAcceptableSwAddrMethodNames,runnableDataAcceptedSectionTypes]=...
            autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(m3iModel,'RunnableInternalData');
            for mappingPropertyName=mappingPropertiesWithRunnables
                mapObjList=mapping.(mappingPropertyName{1});
                for mapObj=mapObjList
                    if mapObj.isvalid()
                        if~isempty(mapObj.MappedTo)&&~isempty(mapObj.MappedTo.SwAddrMethod)


                            isValid=...
                            autosar.validation.ClassicSwAddrMethodValidator.verifyMappedSwAddrMethod(...
                            hModel,mapObj.MappedTo.SwAddrMethod,'Runnable',...
                            runnableAcceptableSwAddrMethodNames,...
                            runnableAcceptedSectionTypes,throwErrors);
                            if~isValid
                                invalidRunnables{end+1}=mapObj;%#ok<AGROW>
                            end
                        end
                        if~isempty(mapObj.MappedTo)&&~isempty(mapObj.MappedTo.InternalDataSwAddrMethod)


                            isValid=...
                            autosar.validation.ClassicSwAddrMethodValidator.verifyMappedSwAddrMethod(...
                            hModel,mapObj.MappedTo.InternalDataSwAddrMethod,'RunnableInternalData',...
                            runnableDataAcceptableSwAddrMethodNames,...
                            runnableDataAcceptedSectionTypes,throwErrors);
                            if~isValid
                                invalidRunnableData{end+1}=mapObj;%#ok<AGROW>
                            end
                        end
                    end
                end
            end

            mappingDataWithSwAddrMethods=autosar.ui.configuration.PackageString.InternalDataObjWithSwAddrMethods;
            for mappingPropertyName=mappingDataWithSwAddrMethods
                if strcmp(mappingPropertyName,'ModelScopedParameters')
                    category='ParameterData';
                else
                    category='VariableData';
                end
                [acceptableSwAddrMethodNames,acceptedSectionTypes]=...
                autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(m3iModel,category);
                mapObjList=mapping.(mappingPropertyName{1});
                for mapObj=mapObjList
                    if mapObj.isvalid()
                        mappedSwAddrMethod=mapObj.MappedTo.getPerInstancePropertyValue('SwAddrMethod');
                        if~isempty(mapObj.MappedTo)&&~isempty(mappedSwAddrMethod)


                            isValid=...
                            autosar.validation.ClassicSwAddrMethodValidator.verifyMappedSwAddrMethod(...
                            hModel,mappedSwAddrMethod,category,...
                            acceptableSwAddrMethodNames,...
                            acceptedSectionTypes,throwErrors);
                            if~isValid
                                invalidInternalData{end+1}=mapObj;%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function isValidSwAddrMethod=verifyMappedSwAddrMethod(hModel,swAddrMethodName,category,acceptableSwAddrMethodNames,acceptedSectionTypes,throwErrors)


            isValidSwAddrMethod=ismember(swAddrMethodName,...
            acceptableSwAddrMethodNames);

            if~isValidSwAddrMethod&&throwErrors

                apiObj=autosar.api.getAUTOSARProperties(hModel);
                swAddrMethodPath=apiObj.find([],'SwAddrMethod','Name',swAddrMethodName,'PathType','FullyQualified');
                if length(swAddrMethodPath)==1
                    selectedSectionType=apiObj.get(swAddrMethodPath{1},'SectionType');
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidSwAddrMethodSectionType',...
                    swAddrMethodName,category,selectedSectionType,autosar.api.Utils.cell2str(acceptedSectionTypes));
                else

                    assert(isempty(swAddrMethodPath),'Expected to find 0 SwAddrMethods');
                    autosar.validation.Validator.logError('autosarstandard:validation:SwAddrMethodDoesNotExist',swAddrMethodName);
                end
            end
        end
    end
end




