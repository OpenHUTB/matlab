classdef ParameterWriterBase<handle





    methods(Static,Access=protected)
        function writer=getWriter(fileName)

            writer=rtw.connectivity.CodeWriter.create(...
            'language','C',...
            'filename',fileName,...
            'callCBeautifier',true);
        end

        function namespaceScopeGuard=writeNamespace(writer,namespace)
            writer.wLine('namespace %s {',namespace);
            namespaceScopeGuard=onCleanup(@()writer.wLine('} // %s',namespace));
        end

        function headerGuardScopeGuard=writeHeaderGuard(writer,fileName)
            upperFileName=upper(fileName);
            headerGuardMacro=regexprep(upperFileName,'[^a-zA-Z]','_');
            writer.wLine('#ifndef _%s',headerGuardMacro);
            writer.wLine('#define _%s',headerGuardMacro);
            headerGuardScopeGuard=onCleanup(@()writer.wLine('#endif'));
        end

        function writeIncludes(writer,includes)
            for kIncl=1:numel(includes)

                writer.wLine('#include %s',includes{kIncl});
            end
        end
    end
end
