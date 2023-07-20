classdef(Hidden)DesignEvolutionReporter<mlreportgen.report.Reporter





    properties
    end

    methods
        function obj=DesignEvolutionReporter(varargin)
            obj=obj@mlreportgen.report.Reporter(varargin{:});
        end

        function table=customizeTableWidthsForTable(~,table,widthPercents)
            grps(1)=mlreportgen.dom.TableColSpecGroup;
            specs=mlreportgen.dom.TableColSpec.empty(length(widthPercents),0);
            for columnIdx=1:length(widthPercents)
                specs(columnIdx)=mlreportgen.dom.TableColSpec;
                width=append(num2str(widthPercents(columnIdx)),'%');
                specs(columnIdx).Style={mlreportgen.dom.Width(width)};
            end

            grps(1).ColSpecs=specs;
            table.ColSpecGroups=grps;
        end

    end



    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function createTemplate(templatePath,type)
            path=DesignEvolutionReporter.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"DesignEvolutionReporter");
        end

    end
end


