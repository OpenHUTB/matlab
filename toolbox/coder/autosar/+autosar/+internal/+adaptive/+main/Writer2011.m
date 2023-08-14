classdef Writer2011<autosar.internal.adaptive.main.Writer1911









    methods(Access=public)

        function includeLogHeaders(this)
            this.CodeWriterObj.wLine('#include <ara/log/logger.h>');
            this.CodeWriterObj.wLine('#include <ara/log/log_stream.h>');
        end
    end
end
