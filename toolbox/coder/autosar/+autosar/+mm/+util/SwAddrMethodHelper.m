classdef SwAddrMethodHelper







    methods(Access=public,Static)
        function updateSwAddrMethodsInMapping(modelName,m3iModel)
            modelMapping=Simulink.CodeMapping.get(modelName,'AutosarTarget');
            records=[];
            m3iObjs=autosar.mm.Model.findChildByTypeName(m3iModel,...
            'Simulink.metamodel.arplatform.common.SwAddrMethod');
            for ii=1:numel(m3iObjs)
                m3iObj=m3iObjs{ii};
                if autosar.mm.mm2sl.utils.isCompatibleSwAddrMethod(m3iObj)
                    packageStr=autosar.api.Utils.getQualifiedName(m3iObj);
                    [ownerPackage,name,~]=fileparts(packageStr);
                    if isempty(m3iObj.SectionType)
                        sectionTypeStr={''};
                    else
                        sectionTypeStr=cellfun(@toString,{m3iObj.SectionType},'UniformOutput',false);
                    end
                    records{end+1}=struct('Name',name,'qualifiedName',ownerPackage,...
                    'SectionType',sectionTypeStr{1},'MemoryAllocationKeywordPolicy',...
                    m3iObj.MemoryAllocationKeywordPolicy);%#ok<AGROW>
                end
            end
            modelMapping.SwAddrMethods=jsonencode(records);
        end

        function sectionTypeValue=sectionTypeStrToValue(sectionTypeStr)
            sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.empty();
            switch sectionTypeStr
            case 'CalibrationVariables'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.CalibrationVariables;
            case 'Calprm'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Calprm;
            case 'Code'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Code;
            case 'ConfigData'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.ConfigData;
            case 'Const'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const;
            case 'ExcludeFromFlash'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.ExcludeFromFlash;
            case 'Var'
                sectionTypeValue=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var;
            otherwise
            end
        end

        function[swAddrMethodNames,acceptedSectionTypesStr]=findSwAddrMethodsInMapping(modelMapping,category)
            swAddrMethodNames={};
            acceptedSectionTypesStr='';
            if~isempty(modelMapping.SwAddrMethods)
                records=jsondecode(modelMapping.SwAddrMethods);
                for ii=1:numel(records)
                    records(ii).SectionType=autosar.mm.util.SwAddrMethodHelper.sectionTypeStrToValue(records(ii).SectionType);
                end

                [acceptedSectionTypes,acceptedSectionTypesStr]=...
                autosar.mm.util.SwAddrMethodHelper.getAcceptedSectionTypesForCategory(category);
                swAddrMethodNames=autosar.mm.util.SwAddrMethodHelper.filterSwAddrMethods(records,acceptedSectionTypes);
            end
        end

        function[swAddrMethodNames,acceptedSectionTypesStr]=findSwAddrMethodsForCategory(m3iModel,category)



            [acceptedSectionTypes,acceptedSectionTypesStr]=...
            autosar.mm.util.SwAddrMethodHelper.getAcceptedSectionTypesForCategory(category);
            m3iSwAddrMethods=autosar.ui.utils.collectObject(m3iModel,...
            autosar.ui.metamodel.PackageString.SwAddrMethodClass);
            swAddrMethodNames=autosar.mm.util.SwAddrMethodHelper.filterSwAddrMethods(m3iSwAddrMethods,acceptedSectionTypes);
        end

        function[acceptedSectionTypes,acceptedSectionTypesStr]=getAcceptedSectionTypesForCategory(category)
            switch category
            case 'Runnable'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.RunnableSwAddrMethodSectionTypes;
            case 'RunnableInternalData'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.RunnableInternalDataSwAddrMethodSectionTypes;
            case 'ParameterData'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.ParameterSwAddrMethodSectionTypes;
            case 'VariableData'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.InternalDataSwAddrMethodSectionTypes;
            case 'DataElement'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.DataElementSwAddrMethodSectionTypes;
            case 'IRV'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.IRVSwAddrMethodSectionTypes;
            case 'Argument'
                acceptedSectionTypes=autosar.ui.metamodel.PackageString.ArgumentSwAddrMethodSectionTypes;
            otherwise
                assert(false,'Category not recognized');
            end

            acceptedSectionTypesStr=cellfun(@toString,acceptedSectionTypes,'UniformOutput',false);
        end

        function category=getSwAddrMethodCategoryFromM3IObject(m3iObject)



            className=class(m3iObject);
            switch className
            case autosar.ui.configuration.PackageString.DataElement
                category='DataElement';
            case autosar.ui.configuration.PackageString.ArgumentData
                category='Argument';
            case autosar.ui.configuration.PackageString.ParameterData
                category='ParameterData';
            case autosar.ui.configuration.PackageString.IRV
                category='IRV';
            otherwise
                assert(false,'Unexpected m3iObject class');
            end
        end
    end

    methods(Access=private,Static)
        function swAddrMethodNames=filterSwAddrMethods(m3iSwAddrMethods,acceptedSectionTypes)




            swAddrMethodNames={};

            for ii=1:length(m3iSwAddrMethods)
                cur=m3iSwAddrMethods(ii);
                if any(cellfun(@(x)x==cur.SectionType,acceptedSectionTypes))...
                    ||isempty(cur.SectionType)
                    swAddrMethodNames{end+1}=cur.Name;%#ok<AGROW>
                end
            end
        end
    end
end



