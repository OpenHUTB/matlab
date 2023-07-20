



classdef(Sealed)MATLABCoderProbeComponentRegistry<codeinstrum.internal.codecov.ProbeComponentRegistry

    properties(GetAccess=public,SetAccess=private)
        DbFilePath=''
    end

    methods



        function this=MATLABCoderProbeComponentRegistry(moduleName,...
            instrumOptions,...
            targetWordSize,...
            maxIdLength,...
            dbFilePath)

            this=this@codeinstrum.internal.codecov.ProbeComponentRegistry(...
            moduleName,...
            instrumOptions,...
            targetWordSize,...
            maxIdLength);

            if nargin==5&&~isempty(dbFilePath)
                this.DbFilePath=dbFilePath;
            end
        end
    end
end
