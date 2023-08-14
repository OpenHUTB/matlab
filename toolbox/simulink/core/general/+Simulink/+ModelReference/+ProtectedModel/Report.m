




classdef Report<rtw.report.ReportInfo
    properties(Transient)
        ProtectedMdl=[];
CodeInterface
    end
    properties
        CodeGen=true;
    end
    methods(Hidden)
        function lics=getLicenseRequirements(~)

            lics={};
        end
    end
    methods
        function obj=Report(modelName)
            obj=obj@rtw.report.ReportInfo(modelName);


            obj.Summary=Simulink.ModelReference.ProtectedModel.Summary(modelName);
            obj.AddSource=false;



            if Simulink.ModelReference.ProtectedModel.protectingModel(modelName)
                protectedModelCreator=Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(modelName);

                if strcmp(protectedModelCreator.currentMode,'SIM')

                    obj.AddCode=false;
                else
                    assert(any(strcmp(protectedModelCreator.currentMode,{'RTW','NONE'})));

                    obj.AddCode=true;



                    obj.AddSource=obj.AddCode&&protectedModelCreator.packageSourceCode();
                end
            end
        end

        function registerPages(obj)

            if~isempty(obj.Pages)&&isa(obj.Pages{1},'Simulink.ModelReference.ProtectedModel.Summary')
                return;
            end

            model=obj.ModelName;
            pages=obj.Pages;
            obj.Pages={};


            obj.addPage(obj.Summary);


            obj.CodeInterface=Simulink.ModelReference.ProtectedModel.CodeInterface(model,obj.BuildDirectory);
            obj.addPage(obj.CodeInterface);

            obj.Pages=[obj.Pages(:);pages(:)];
        end

        function out=getGenFilesTitle(obj)
            out=DAStudio.message('RTW:report:ProtectedMdlReportGeneratedFiles',upper(obj.ProtectedMdl.Target));
        end

        function initProtectedModelReport(obj,protModel)
            obj.ProtectedMdl=protModel;
            obj.Summary.ProtectedMdl=obj.ProtectedMdl;
            obj.initCodeInterfaceReport(protModel);


            obj.AddSource=protModel.supportsCodeGen()&&protModel.packageSourceCode();




            obj.ModelReferences={};





            if isa(protModel,'Simulink.ModelReference.ProtectedModel.Editor')&&...
                ~protModel.rebuilt

                for i=1:length(obj.Pages)
                    if isa(obj.Pages{i},'Simulink.ModelReference.ProtectedModel.CodeInterface')
                        obj.Pages{i}.generateHTML=false;
                    end
                end
            end
        end

        function initCodeInterfaceReport(obj,protectedModel)

            if protectedModel.areAllParametersTunable
                tunableParameters=protectedModel.getSimulationTunableParams;
            elseif protectedModel.isAllParametersProtected
                tunableParameters={};
            else
                tunableParameters=protectedModel.TunableVarNames;
            end
            obj.CodeInterface.TunableParameters=tunableParameters;

            obj.CodeInterface.ReportCodeIdentifier=false;
        end

        function title=getTitle(~)
            title=DAStudio.message('Simulink:protectedModel:ProtectedModelReportTitle','');
        end

        function out=getGeneratedFilesPanel(obj)
            if obj.CodeGen
                out=getGeneratedFilesPanel@rtw.report.ReportInfo(obj);
            else
                out='';
            end
        end


        function updateConfig(obj)

            obj.LastConfig=obj.Config;
            obj.Config=Simulink.ModelReference.ProtectedModel.Config();

            obj.Config.LaunchReport='off';
            obj.Config.IncludeHyperlinkInReport='off';
            obj.Config.GenerateTraceInfo='off';
            obj.Config.GenerateTraceReport='off';
            obj.Config.GenerateTraceReportSl='off';
            obj.Config.GenerateTraceReportSf='off';
            obj.Config.GenerateTraceReportEml='off';
            obj.Config.GenerateCodeMetricsReport='off';
            obj.Config.GenerateCodeReplacementReport='off';
            obj.Config.GenerateWebview='off';
        end

        function out=getHelpMethod(~)
            out='helpview([docroot ''/rtw/helptargets.map''],''protected_model_report'')';
        end

        function link(obj,model,~)





            rtw.report.ReportInfo.setInstance(model,obj);
        end
    end

    methods(Static=true)
        function obj=newInstance(model)
            rtw.report.ReportInfo.clearInstance(model)
            obj=Simulink.ModelReference.ProtectedModel.Report(model);
            set_param(model,'CoderReportInfo',obj);
            ssH=rtwprivate('getSourceSubsystemHandle',model);
            if~isempty(ssH)
                set_param(bdroot(ssH),'CoderReportInfo',obj);
            end
        end
    end
end


