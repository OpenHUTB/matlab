classdef RptFileConverter<mlreportgen.rpt2api.RptFileConverter





















    properties(Access=private)
        SimulinkHelperFunctions=[];
    end

    methods
        function obj=RptFileConverter(varargin)


            obj@mlreportgen.rpt2api.RptFileConverter(varargin{:});
        end

        function registerSimulinkHelperFunction(this,functionName)








            helperFile=strcat("t",functionName,".txt");
            if isempty(this.HelperFunctions)||~any(endsWith(this.HelperFunctions,filesep+helperFile))
                classFolder=fileparts(mfilename('fullpath'));
                templateFolder=fullfile(classFolder,...
                'templates');
                templatePath=fullfile(templateFolder,helperFile);
                this.HelperFunctions=[this.HelperFunctions,templatePath];
            end
        end
    end

    methods(Access=protected)
        function setConverterFactory(obj)
            import slreportgen.rpt2api.*
            obj.ConverterFactory=ComponentConverterFactory;
        end
    end

end

