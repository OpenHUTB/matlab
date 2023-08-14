classdef ProfileTimer<coder.profile.HostTimer









    methods

        function this=ProfileTimer()
            headerFile=fullfile(matlabroot,...
            'toolbox',...
            'slrealtime',...
            'target',...
            'kernel',...
            'dist',...
            'include',...
            'tracing.h');
            this.setHeaderFile(headerFile);
        end
    end
end

