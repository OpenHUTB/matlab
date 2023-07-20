classdef NvBlockNeedsCodePropsHelper<handle





    methods(Access=public,Static)

        function nvBlockNeedsCodeProps=createStructOfNvBlockNeeds(m3iNvBlockNeeds)

            nvBlockNeedAttributes=autosar.mm.util.NvBlockNeedsCodePropsHelper.getSupportedNvBlockNeedsAttributes;
            for i=1:length(nvBlockNeedAttributes)
                nvBlockNeedsCodeProps.(nvBlockNeedAttributes{i})=m3iNvBlockNeeds.(nvBlockNeedAttributes{i});
            end
        end

        function updateNvBlockNeedsFromCodeProperties(m3iNvBlockNeeds,mappingElement)
            nvBlockNeedAttributes=autosar.mm.util.NvBlockNeedsCodePropsHelper.getSupportedNvBlockNeedsAttributes;
            for i=1:length(nvBlockNeedAttributes)

                nvBlockNeedValue=mappingElement.MappedTo.getPerInstancePropertyValue(nvBlockNeedAttributes{i});
                if~isempty(nvBlockNeedValue)
                    nvBlockNeedValue=autosar.mm.util.NvBlockNeedsCodePropsHelper.convertNvBlockNeedFromStringToLogical(nvBlockNeedValue);
                    m3iNvBlockNeeds.(nvBlockNeedAttributes{i})=nvBlockNeedValue;
                end
            end
        end

        function nameValuePairs=updateNvBlockNeedCodeMappingArguments(nameValuePairs)




            if any(strcmp(nameValuePairs,'NeedsNVRAMAccess'))
                needsNVRAMAccessValueIdx=find(strcmp(nameValuePairs,'NeedsNVRAMAccess'));
                needsNVRAMAccess=nameValuePairs{needsNVRAMAccessValueIdx+1};
                if~needsNVRAMAccess
                    nvBlockNeeds=autosar.mm.util.NvBlockNeedsCodePropsHelper.getSupportedNvBlockNeedsAttributes;
                    for i=1:length(nvBlockNeeds)

                        nvBlockNeedValueIdx=find(strcmp(nameValuePairs,nvBlockNeeds{i}));
                        nameValuePairs(nvBlockNeedValueIdx:nvBlockNeedValueIdx+1)=[];
                    end
                end
            end
        end

        function nvBlockNeedValue=convertNvBlockNeedFromStringToLogical(nvBlockNeedValue)

            if strcmp(nvBlockNeedValue,'true')
                nvBlockNeedValue=true;
            elseif strcmp(nvBlockNeedValue,'false')
                nvBlockNeedValue=false;
            else
                assert(false,'Expected the input to be a char containing a boolean.');
            end
        end

        function nvBlockNeedsValue=convertNvBlockNeedFromLogicalToString(nvBlockNeedsValue)

            if nvBlockNeedsValue
                nvBlockNeedsValue='true';
            else
                nvBlockNeedsValue='false';
            end
        end

        function validAttributes=getSupportedNvBlockNeedsAttributes()

            metaclass=Simulink.metamodel.arplatform.behavior.NvBlockNeeds.MetaClass;
            ownedAttributes=metaclass.ownedAttribute;
            validAttributes=cell(ownedAttributes.size,1);
            for i=1:ownedAttributes.size
                attribute=ownedAttributes.at(i);
                if contains(attribute.qualifiedName,'Simulink.metamodel.arplatform.behavior.NvBlockNeeds')
                    validAttributes{i}=attribute.name;
                end
            end
            validAttributes=validAttributes(~cellfun('isempty',validAttributes));
        end
    end
end


