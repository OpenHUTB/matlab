classdef SharedDictionaryCodeMappingCopier<coder.mapping.internal.CodeMappingCopier


    methods(Access=public)
        function this=SharedDictionaryCodeMappingCopier(srcSS,copyAllMappings)

            this@coder.mapping.internal.CodeMappingCopier(srcSS,copyAllMappings);
            this.localDictionary=false;

        end
        function dstUUID=DstStorageClassUUID(~,~,~,uuid)
            dstUUID=uuid;
        end

        function dstUUID=DstMemorySectionUUID(~,~,~,uuid)
            dstUUID=uuid;
        end

        function dstUUID=DstFunctionClassUUID(~,~,~,uuid)
            dstUUID=uuid;
        end

    end

end


