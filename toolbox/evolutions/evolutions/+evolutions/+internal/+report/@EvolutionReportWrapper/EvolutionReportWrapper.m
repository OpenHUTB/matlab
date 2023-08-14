classdef EvolutionReportWrapper<handle




    properties
        Content;
        OutputFile='';

        ReportTitle='Report Generated by Design Evolutions';
        AuthorName='';


        GenerateEvolutionTreeReport=true;
        GenerateEvolutionReport=true;
        GenerateArtifactFileReport=true;

        IncludeEvolutionTreeNameHeading=true;
        IncludeEvolutionTreeTopInfoTable=true;
        IncludeEvolutionTreePlot=true;
        IncludeEvolutionTreeEvolutionHyperlinks=true;
        IncludeEvolutionTreeDetailsTable=true;

        IncludeEvolutionNameHeading=true;
        IncludeEvolutionFileTable=true;
        IncludeEvolutionParent=true;
        IncludeEvolutionChildren=true;
        IncludeEvolutionDetailsTable=true;
        IncludeEvolutionArtifactHyperlinks=true;
        IncludeEvolutionBackToEvolutionTreeHyperlink=true;

        IncludeArtifactFileNameHeading=true;
        IncludeArtifactFileWebView=true;
        IncludeArtifactFileBackToEvolutionHyperlinks=true;
        IncludeArtifactFileBackToEvolutionTreeHyperlink=true;

        LaunchReport=true;

        EvolutionReporterTemplate='';

        WorkingPath='';
        WorkingName='';
        ReportType='';
        OutputFileType='';
        Report;

    end

    methods


        function setReportGenerationEnvironment(obj)

            osTempDir=tempdir();
            obj.WorkingPath=tempname(osTempDir);
            mkdir(obj.WorkingPath);

            tmpStr=tempname(obj.WorkingPath);
            [~,tmpName,~]=fileparts(tmpStr);
            obj.WorkingName=tmpName;

            [~,~,outputExt]=fileparts(obj.OutputFile);

            if(strcmp(outputExt,'.zip'))
                obj.ReportType='html';
                obj.OutputFileType='html';
            elseif(strcmp(outputExt,'.pdf'))
                obj.ReportType='pdf';
                obj.OutputFileType='pdf';
            elseif(strcmp(outputExt,'.docx'))
                obj.ReportType='docx';
                obj.OutputFileType='docx';
            end
            tmpOutputFile=fullfile(obj.WorkingPath,obj.WorkingName);


            obj.Report=evolutions.internal.report.EvolutionSpecReport(tmpOutputFile,obj.ReportType);

            obj.Report.Locale='en';

            open(obj.Report);
        end

        function createReport(obj)
            obj.setReportGenerationEnvironment();


            obj.layoutReport();


            obj.addReportBody();

            obj.finalizeReport();


            if obj.LaunchReport
                obj.viewReport();
            end
        end


        function viewReport(obj)
            if(strcmp(obj.OutputFileType,'html'))
                rptgen.rptview(obj.OutputFile,obj.OutputFileType);
            elseif(strcmp(obj.OutputFileType,'pdf'))
                [outputFilePath,outputFileName,~]=fileparts(obj.OutputFile);
                rptgen.rptview(fullfile(outputFilePath,outputFileName,obj.OutputFile),obj.OutputFileType);
            elseif(strcmp(obj.OutputFileType,'docx'))
                [outputFilePath,outputFileName,~]=fileparts(obj.OutputFile);
                rptgen.rptview(fullfile(outputFilePath,outputFileName,obj.OutputFile),obj.OutputFileType);
            end
        end


        function finalizeReport(obj)
            close(obj.Report);


            if(strcmp(obj.OutputFileType,'html'))
                tmpFile=fullfile(obj.WorkingPath,[obj.WorkingName,'.htmx']);
                assert(isfile(tmpFile));

                unzip(tmpFile,fullfile(obj.WorkingPath,obj.WorkingName));

                externalLinksFolder=fullfile(obj.WorkingPath,'ExternalLinks');

                if isfolder(externalLinksFolder)

                    movefile([externalLinksFolder,'*'],fullfile(obj.WorkingPath,obj.WorkingName));
                end

                zip(obj.OutputFile,fullfile(obj.WorkingPath,obj.WorkingName,'*'));

            elseif(strcmp(obj.OutputFileType,'pdf'))
                copyReportFileToFilePath(obj);

            elseif(strcmp(obj.OutputFileType,'docx'))
                copyReportFileToFilePath(obj);
            end

        end


        function copyReportFileToFilePath(obj)
            tmpFile=fullfile(obj.WorkingPath,sprintf('%s%s%s',obj.WorkingName,'.',obj.OutputFileType));
            assert(isfile(tmpFile));

            mkdir(fullfile(obj.WorkingPath,obj.WorkingName));

            movefile(tmpFile,fullfile(obj.WorkingPath,obj.WorkingName));

            externalLinksFolder=fullfile(obj.WorkingPath,'ExternalLinks');
            if isfolder(externalLinksFolder)

                movefile([externalLinksFolder,'*'],fullfile(obj.WorkingPath,obj.WorkingName));
            end
            [~,outputFileName,~]=fileparts(obj.OutputFile);

            movefile(fullfile(obj.WorkingPath,obj.WorkingName,sprintf('%s%s%s',obj.WorkingName,'.',obj.OutputFileType)),...
            fullfile(obj.WorkingPath,obj.WorkingName,sprintf('%s%s%s',outputFileName,'.',obj.OutputFileType)));

            copyfile(fullfile(obj.WorkingPath,obj.WorkingName,'*'),outputFileName);
        end

    end

end


