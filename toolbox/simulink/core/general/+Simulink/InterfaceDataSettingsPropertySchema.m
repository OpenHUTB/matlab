classdef InterfaceDataSettingsPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataDefaultsSettings');
        end
    end

    methods
        function this=InterfaceDataSettingsPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen'};
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Name',true};
        end
        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=true;
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=false;
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if strcmp(mappingType,'AutosarTargetCPP')

                isVisible=false;
            elseif strcmp(mappingType,'CoderDictionary')
                if slfeature('DeploymentTypeInCMapping')==1&&modelMapping.isFunctionPlatform
                    if strcmp(obj.Source.m_ssComponent.ID,'GLUE2:SpreadSheet/CodeProperties')
                        isVisible=false;
                    elseif strcmp(obj.Source.m_ssComponent.ID,'GLUE2:SpreadSheet/DefaultsProperties')
                        isVisible=true;
                    end
                elseif slfeature('DefaultsSSInCMapping')==1&&...
                    strcmp(modelMapping.DeploymentType,'Unset')
                    if strcmp(obj.Source.m_ssComponent.ID,'GLUE2:SpreadSheet/CodeProperties')
                        isVisible=false;
                    elseif strcmp(obj.Source.m_ssComponent.ID,'GLUE2:SpreadSheet/DefaultsProperties')
                        isVisible=true;
                    end
                else
                    isVisible=true;
                end
            elseif strcmp(mappingType,'SimulinkCoderCTarget')
                isVisible=true;
            elseif strcmp(mappingType,'CppModelMapping')&&modelMapping.DeploymentType=="Unset"
                isVisible=true;
            elseif strcmp(mappingType,'AutosarTarget')
                isVisible=slfeature('DefaultsInAUTOSARMapping')>0;
            else
                isVisible=false;
            end
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            props={DAStudio.message('coderdictionary:mapping:DataCategoryColumnName')};
        end

        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};
                if~isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                else
                    model=bdroot(obj.Source.m_Source.Handle);
                end
                [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'SimulinkCoderCTarget')
                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:StorageClassColumnName')];
                elseif strcmp(mappingType,'AutosarTarget')
                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:MappedToColumnName')];
                elseif strcmp(mappingType,'CppModelMapping')
                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:CppMethodVisibilityColumnName'),...
                    DAStudio.message('coderdictionary:mapping:CppAccessColumnName')];
                end
                if~isa(obj.Source,'DataView')
                    if strcmp(mappingType,'AutosarTarget')


                        val=obj.Source.getPropValue(DAStudio.message('coderdictionary:mapping:MappedToColumnName'));
                        if strcmp(val,'StorageClass')
                            props=[props,...
                            DAStudio.message('coderdictionary:mapping:StorageClassColumnName')];
                        end
                    end
                    if~isempty(modelMapping)&&~strcmp(mappingType,'CppModelMapping')
                        memberName=obj.Source.getPropValue('Name');
                        member=eval(['modelMapping.DefaultsMapping.',memberName]);
                        if~isempty(member)
                            cscAttributeNames=member.getCSCAttributeNames(model);
                            cscAttributeNames=setdiff(cscAttributeNames,member.getPerInstanceAttributeNames,'stable');


                            cscAttributeNames=cscAttributeNames(...
                            ~contains(cscAttributeNames,'MemorySection'));
                            props=[props,cscAttributeNames'];
                        end
                    end
                    if strcmp(mappingType,'AutosarTarget')


                        val=obj.Source.getPropValue(DAStudio.message('coderdictionary:mapping:MappedToColumnName'));
                        if strcmp(val,'StorageClass')
                            props=[props,...
                            DAStudio.message('coderdictionary:mapping:MemorySectionColumnName')];
                        end
                    end
                elseif strcmp(mappingType,'CoderDictionary')

                    props{end+1}=obj.mappingInspectorColumnName;
                end
                if strcmp(mappingType,'CoderDictionary')&&~isa(obj.Source,'DataView')

                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:MemorySectionColumnName')];
                end
            otherwise
                props={};
            end
        end
    end

end


