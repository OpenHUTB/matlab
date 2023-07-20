


classdef(Sealed)InferenceReportContributor<coder.report.Contributor

    properties(Constant)
        ID='coder-inference'
        DATA_GROUP_INFERENCE='inference'
        DATA_GROUP_SCRIPTS='scripts'
    end

    properties(Constant,Access=private)
        PP_DEFER=0
        PP_CONSERVATIVE=1
        PP_AGGRESSIVE=2
    end

    properties(SetAccess=private)
MatlabCodeInfo
Data
    end

    methods
        function supported=isSupportsVirtualMode(~,~)
            supported=true;
        end

        function contribute(this,reportContext,contribContext)
            [this.Data,this.MatlabCodeInfo]=this.processInferenceReport(reportContext,...
            contribContext.IncludedFunctionIds,contribContext.IncludedScriptIds);

            if isempty(this.Data)
                return;
            end


            dataFields=fieldnames(this.Data);
            dataFields=dataFields(~strcmp(dataFields,'Scripts'));
            contribContext.addData(this.DATA_GROUP_SCRIPTS,'Scripts',this.Data.Scripts);
            for i=1:length(dataFields)
                contribContext.addData(this.DATA_GROUP_INFERENCE,dataFields{i},this.Data.(dataFields{i}));
            end


            switch determinePartitionPolicy()
            case this.PP_AGGRESSIVE

                infFile='inference';
                scriptsFile='scripts';
            case this.PP_CONSERVATIVE

                infFile='inference';
                scriptsFile=infFile;
            otherwise

                infFile='';
                scriptsFile='';
            end

            if~isempty(infFile)
                contribContext.setFileForData(this.DATA_GROUP_INFERENCE,infFile);
            end
            if~isempty(scriptsFile)
                contribContext.setFileForData(this.DATA_GROUP_SCRIPTS,scriptsFile);
            end

            if isfield(reportContext.Report,'inference')&&~isempty(reportContext.Report.inference)
                this.saveExportedValues(reportContext,contribContext);
            end


            function partitionPolicy=determinePartitionPolicy()
                partitionPolicy=[];
                diskSize=0;
                monoCell=iscell(this.Data.Scripts);

                for j=1:numel(this.Data.Scripts)
                    if monoCell
                        script=this.Data.Scripts{j};
                    else
                        script=this.Data.Scripts(j);
                    end

                    scriptFile=script.Path;
                    if isfile(scriptFile)
                        fileInfo=dir(scriptFile);
                        diskSize=diskSize+fileInfo.bytes;
                    else

                        diskSize=diskSize+1.1*length(script.Text);
                    end
                    if diskSize>=600e3
                        partitionPolicy=this.PP_AGGRESSIVE;
                        break;
                    end
                end

                if isempty(partitionPolicy)
                    if diskSize>=100e3
                        partitionPolicy=this.PP_CONSERVATIVE;
                    else
                        partitionPolicy=this.PP_DEFER;
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function saveExportedValues(reportContext,contribContext)

            if~contribContext.DryRun
                exportable=[];

                dataSets=contribContext.DataSets;
                if isKey(dataSets,'inference')
                    inferenceData=dataSets('inference');
                    if isKey(inferenceData,'MxArrays')
                        mxArrayData=inferenceData('MxArrays');
                        exportable=[mxArrayData.Exportable];
                    end
                end
                report=contribContext.Report;
                if isfield(report,'inference')&&isprop(report.inference,'MxArrays')
                    values=report.inference.MxArrays;
                    if~isempty(exportable)

                        values(~exportable)=cell(1,sum(~exportable));
                        save(fullfile(reportContext.ReportDirectory,'exported_values.mat'),'values');
                    end
                end
            end
        end

        function devMode=isDeveloperMode(reportContext)
            devMode=~isempty(reportContext.FeatureControl)&&reportContext.FeatureControl.Developer;
        end
    end

    methods(Static,Hidden)
        function[data,matlabCodeInfo]=processInferenceReport(reportContext,includedFunctionIds,includedScriptIds)
            [data,matlabCodeInfo]=codergui.evalprivate('transformInferenceReport',reportContext.Report,...
            'Inclusion',struct('functionIds',includedFunctionIds,'scriptIds',includedScriptIds),...
            'DoDeadCodeAnalysis',coder.internal.gui.globalconfig('ReportDeadCode'));
            fixptSummary=coder.report.contrib.Float2FixedContributor.getFixedPointSummary(reportContext);

            if~isempty(data)&&~isempty(fixptSummary)&&isfield(fixptSummary.data,'report')


                data=codergui.evalprivate('transformInferenceReport',fixptSummary.data.report,...
                'ParentReportData',struct('processed',data,'report',reportContext.Report));
            end
        end
    end
end
