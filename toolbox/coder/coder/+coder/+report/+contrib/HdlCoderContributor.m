classdef(Sealed)HdlCoderContributor<coder.report.Contributor





    properties(Constant)
        ID='coder-hdlcoder'
        SOURCE_ARTIFACT_GROUP='hdlFiles'
        AUX_ARTIFACT_GROUP='hdlSupplemental'
        DATA_GROUP='hdl'
        MANIFEST_PROP='hasHdlFiles'
        HDL_SUBFOLDER='hdl'
    end

    methods
        function relevant=isRelevant(this,reportContext)
            relevant=reportContext.IsHdl&&~isempty(this.getDriver());
        end

        function contribute(this,reportContext,contribContext)
            this.contributeHdlFiles(reportContext,contribContext);
            this.contributeAuxReports(reportContext,contribContext);
        end
    end

    methods(Access=private)
        function contributeHdlFiles(this,reportContext,contribContext)
            [~,rtlInfo]=this.getDriver().getCodeGenInfo;
            if isempty(rtlInfo)
                return;
            end

            folder=fullfile(reportContext.ReportDirectory,this.HDL_SUBFOLDER);
            if~contribContext.DryRun&&~isfolder(folder)
                mkdir(folder);
            end

            hdlFiles=rtlInfo.hdlFileNamesWithPaths;

            for i=1:numel(hdlFiles)
                file=hdlFiles{i};
                [~,filename,ext]=fileparts(file);
                if~contribContext.DryRun
                    copyfile(file,fullfile(folder,[filename,ext]));
                end
                switch lower(ext)
                case '.vhd'
                    contentTypeArg={'ContentType','vhdl'};
                case '.v'
                    contentTypeArg={'ContentType','verilog'};
                otherwise
                    contentTypeArg={};
                end
                relFile=fullfile(this.HDL_SUBFOLDER,[filename,ext]);
                contribContext.linkArtifact(this.SOURCE_ARTIFACT_GROUP,file,...
                'File',relFile,contentTypeArg{:});
            end

            contribContext.setManifestProperty(this.MANIFEST_PROP,numel(hdlFiles)>0);
        end

        function contributeAuxReports(this,reportContext,contribContext)
            [conformanceFile,resourceFile,complianceReport]=this.findAuxReports(reportContext.BuildDirectory);
            if~isempty(conformanceFile)
                copyAuxReport(conformanceFile,'hdlConformanceReport');
            end
            if~isempty(resourceFile)
                copyAuxReport(resourceFile,'hdlResourceReport');
            end
            if~isempty(complianceReport)
                copyAuxReport(complianceReport,'hdlComplianceReport');
            end

            function copyAuxReport(auxFile,shortId)
                folder=fullfile(reportContext.ReportDirectory,this.HDL_SUBFOLDER);
                if~contribContext.DryRun&&~isfolder(folder)
                    mkdir(folder);
                end
                [~,filename,ext]=fileparts(auxFile);
                relFile=fullfile(this.HDL_SUBFOLDER,[filename,ext]);
                if~contribContext.DryRun
                    copyfile(auxFile,fullfile(folder,[filename,ext]));
                end
                contribContext.linkArtifact(this.AUX_ARTIFACT_GROUP,shortId,...
                'File',relFile,'Encoding','UTF-8');
            end
        end
    end

    methods(Static,Access=private)
        function driver=getDriver()
            driver=[];
            if~isempty(which('hdlcurrentdriver'))
                try
                    driver=hdlcurrentdriver();
                catch
                end
            end
        end

        function[conformanceReport,resourceReport,complianceReport]=findAuxReports(folder)
            files=dir(folder);
            names={files.name};
            conformanceReport=toReportPath('_hdl_conformance_report');
            resourceReport=toReportPath('resource_report');
            complianceReport=toReportPath('_industry_report');

            function reportPath=toReportPath(suffix)
                reportFile=files(endsWith(names,[suffix,'.html']));
                if~isempty(reportFile)
                    reportPath=fullfile(folder,reportFile(1).name);
                else
                    reportPath=[];
                end
            end
        end
    end
end
