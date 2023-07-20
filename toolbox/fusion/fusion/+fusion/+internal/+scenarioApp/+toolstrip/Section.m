classdef Section<matlab.ui.internal.toolstrip.Section

    properties(SetAccess=protected,Hidden)
Application
Toolstrip
    end

    properties(Constant,Hidden)
        IconDirectory=fullfile(matlabroot,'toolbox','fusion','fusion',...
        '+fusion','+internal','+scenarioApp','icons');
    end

    methods
        function this=Section(hApplication,hToolstrip)
            this.Application=hApplication;
            this.Toolstrip=hToolstrip;
        end

        function str=msgString(this,varargin)
            str=msgString(this.Toolstrip,varargin{:});
        end
    end
end