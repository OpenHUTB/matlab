classdef Report<mlreportgen.report.ReportBase&...
    slreportgen.report.internal.Report
































































    properties







        CompileModelBeforeReporting=true;
    end

    methods
        function rpt=Report(varargin)
            rpt=rpt@mlreportgen.report.ReportBase(varargin{:});
        end
    end

    methods(Hidden)
        function compileModel(rpt,objH)
            if~rpt.CompileModelBeforeReporting
                return;
            end

            modelName='';
            objH=slreportgen.utils.getSlSfHandle(objH);
            if~isa(objH,'Stateflow.Object')||~objH.Machine.IsLibrary
                modelH=slreportgen.utils.getModelHandle(objH);
                modelName=get_param(modelH,'Name');
            end






            if~isempty(modelName)&&~slreportgen.utils.isModelCompiled(modelName)
                compiledModel=getContext(rpt,'CompiledModel');

                if~strcmp(compiledModel,modelName)
                    r=slroot;





                    if r.isValidSlObject(compiledModel)
                        slreportgen.utils.uncompileModel(compiledModel);
                    end
                end

                try
                    slreportgen.utils.compileModel(modelName);
                catch me
                    error(message("slreportgen:report:error:modelCompileError",modelName,getReport(me,"basic")));
                end
                setContext(rpt,'CompiledModel',modelName);
            end
        end
    end

    methods(Access=protected)
        function releaseResources(rpt)

            r=slroot;
            compiledModel=getContext(rpt,'CompiledModel');
            if r.isValidSlObject(compiledModel)
                slreportgen.utils.uncompileModel(compiledModel);
            end
            setContext(rpt,'CompiledModel',[])

            figureHandles=getContext(rpt,'figureHandles');
            if~isempty(figureHandles)
                figHandlesLength=length(figureHandles);
                for i=1:figHandlesLength
                    delete(figureHandles{i});
                end
            end
            setContext(rpt,'figureHandles',[])

            setContext(rpt,"ScheduleMap",[]);


            releaseResources@mlreportgen.report.ReportBase(rpt);
        end
    end

    methods(Static)
        function path=getClassFolder()

            path=mlreportgen.report.Report.getClassFolder();
        end

        function template=createTemplate(templatePath,type)








            path=mlreportgen.report.Report.getClassFolder();

            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReport(toClasspath)
















            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.Report","mlreportgen.report.Report");
        end

    end

end