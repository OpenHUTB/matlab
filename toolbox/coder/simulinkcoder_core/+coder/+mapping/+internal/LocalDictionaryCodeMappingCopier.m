classdef LocalDictionaryCodeMappingCopier<coder.mapping.internal.CodeMappingCopier




    methods(Access=public)
        function this=LocalDictionaryCodeMappingCopier(srcSS,copyAllMappings)

            this@coder.mapping.internal.CodeMappingCopier(srcSS,copyAllMappings);
            this.localDictionary=true;

        end

        function dstUUID=DstStorageClassUUID(~,srcMdlMapping,dstMdlMapping,uuid)
            dstUUID='';
            name=srcMdlMapping.DefaultsMapping.getGroupNameFromUuid(uuid);
            if~strcmp(name,DAStudio.message('coderdictionary:mapping:UnresolvedCell'))
                dstUUID=dstMdlMapping.DefaultsMapping.getGroupUuidFromName(name);
            end
        end

        function dstUUID=DstMemorySectionUUID(~,srcMdlMapping,dstMdlMapping,uuid)
            dstUUID='';
            name=srcMdlMapping.DefaultsMapping.getMemorySectionNameFromUuid(uuid);
            if~strcmp(name,DAStudio.message('coderdictionary:mapping:UnresolvedCell'))
                dstUUID=dstMdlMapping.DefaultsMapping.getMemorySectionUuidFromName(name);
            end
        end

        function dstUUID=DstFunctionClassUUID(this,~,~,uuid)
            dstUUID='';


            meCategory='InitializeTerminate';
            name=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateNameFromUuid(...
            this.srcMdl,uuid,meCategory);
            if~strcmp(name,DAStudio.message('coderdictionary:mapping:UnresolvedCell'))
                dstUUID=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateUuidFromName(...
                this.dstMdl,name,meCategory);
            end
        end

    end

end


