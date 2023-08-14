classdef InterfaceMappingPropertySchema<Simulink.InterfaceDataPropertySchema





    properties(Access=protected)
        mappingInspectorColumnName='...'
    end

    methods
        function this=InterfaceMappingPropertySchema()
        end

        function handleHelp(obj,~)
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                model=bdroot(obj.Source.getForwardedObject.Handle);
            end
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if any(strcmp(mappingType,{'AutosarTarget','AutosarTargetCPP'}))
                helpview(fullfile(docroot,'autosar','helptargets.map'),'autosar_code_mappings');
            elseif strcmp(mappingType,'CoderDictionary')
                helpview(fullfile(docroot,'ecoder','helptargets.map'),'code_mappings');
            elseif strcmp(mappingType,'CppModelMapping')...
                &&strcmp(modelMapping.DeploymentType,'Application')
                helpview(fullfile(docroot,'dds','helptargets.map'),'Code_Mappings_DDS');
            else
                helpview(fullfile(docroot,'rtw','helptargets.map'),'code_mappings_sc');
            end
        end

        function names=getStereotypeNames(obj,category)
            names={};
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                slObj=obj.Source.getForwardedObject;
                if isempty(slObj)
                    return;
                end
                model=obj.getOwnerGraphHandle();
            end

            showCalAttributes=simulinkcoder.internal.toolstrip.util.canShowCalAttributes(model);

            if showCalAttributes
                names={};
                profileName='Calibration';
                if~sl.data.annotation.api.Api.isProfileLoaded(profileName)
                    profile=sl.data.annotation.api.Api.loadFromFile(profileName);
                else
                    profile=sl.data.annotation.api.Api.getProfileByName(profileName);
                end
                for jj=1:numel(profile.prototypes)
                    prototypes=profile.prototypes.toArray;
                    for kk=1:numel(prototypes)
                        prototype=prototypes(kk);
                        for ll=1:prototype.appliesTo.Size
                            if strcmp(category,prototype.appliesTo(ll))
                                names=[names,prototype.friendlyName];
                            end
                        end
                    end
                end
            end
        end

        function toolTip=propertyTooltip(obj,prop)
            if strcmp(prop,DAStudio.message('RTW:autosar:SwAddrMethodProperty'))
                toolTip=DAStudio.message('RTW:autosar:SwAddrMethodForInternalDataTooltip');
            elseif strcmp(prop,'Simulink:studio:DataViewPerspective_Design')
                toolTip=DAStudio.message('Simulink:studio:DataViewPerspective_Design');
            elseif strcmp(prop,'Simulink:studio:DataViewPerspective_CodeGen')
                toolTip=DAStudio.message('Simulink:studio:DataViewPerspective_CodeGen');
            else
                toolTip=coder.internal.asap2.Utils.getASAP2Tooltip(obj,prop);
            end
        end
    end
end


