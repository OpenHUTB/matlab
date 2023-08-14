classdef Rptgen_CReport<mlreportgen.rpt2api.ComponentConverter




































































    properties(Constant,Access=private)
        DefaultTemplates=["default-rg-docx",...
        "default-rg-docx-numbered",...
        "default-rg-pdf",...
        "default-rg-pdf-numbered",...
        "default-rg-html-file",...
        "default-rg-html-file-numbered",...
        "default-rg-html",...
        "default-rg-html-numbered"];
    end

    methods

        function this=Rptgen_CReport(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end


    methods(Access=protected)

        function write(this)



            import mlreportgen.rpt2api.Rptgen_CReport

            parentName="rptObj";
            this.RptFileConverter.VariableNameStack.push(parentName);


            template=Rptgen_CReport.getTemplate('header');
            fprintf(this.FID,template,...
            this.RptFileConverter.RptFilePath,datestr(now));

            writeStartBanner(this);

            writeImportStatements(this);

            writeReportOutputType(this);

            writeReportPath(this);

            writeCreateReport(this);

            writeReportTemplatePath(this);

            if(this.Component.isDebug)
                fprintf(this.FID,"%s.Debug = true;\n",parentName);
            end

            fprintf(this.FID,"%% Open report container\n");
            fprintf(this.FID,"open(rptObj);\n\n");

            template=Rptgen_CReport.getTemplate('createSectStack');
            fprintf(this.FID,"%s",template);

            if~isempty(this.Component.PostGenerateFcn)
                postGenerateFcn=sprintf("%% PostGenerateFcn = \n%s\n\n",...
                this.Component.PostGenerateFcn);
                this.RptFileConverter.addCleanupCode(postGenerateFcn);
            end

        end

        function writeReportPath(this)
            import mlreportgen.rpt2api.Rptgen_CReport
            import mlreportgen.rpt2api.exprstr.Parser

            sPath=this.RptFileConverter.RptFilePath;
            [sDir,sName,~]=fileparts(sPath);

            switch this.Component.DirectoryType
            case 'setfile'
                fprintf(this.FID,"%% Directory = Same as setup file.\n");
                fprintf(this.FID,'rptDir = "%s";\n\n',sDir);
            case 'pwd'
                fprintf(this.FID,"%% Directory = Present working directory.\n");
                fprintf(this.FID,"rptDir = pwd;\n\n");
            case 'tempdir'
                fprintf(this.FID,"%% Directory = Temporary Directory.\n");
                fprintf(this.FID,"rptDir = tempdir;\n\n");
            otherwise
                fprintf(this.FID,"%% Directory = Custom.\n");
                Parser.writeExprStr(this.FID,...
                this.Component.DirectoryName,'rptDir');
            end

            if this.Component.isIncrementFilename
                if(strcmpi(this.RptFileConverter.OutputType,"html"))
                    ext="htmx";
                elseif(strcmpi(this.RptFileConverter.OutputType,"html-file"))
                    ext="html";
                else
                    ext=this.RptFileConverter.OutputType;
                end
                fprintf(this.FID,'ext = "%s";\n\n',ext);
            end

            switch this.Component.FilenameType
            case 'setfile'
                fprintf(this.FID,"%% Filename = Same as setup file\n");
                fprintf(this.FID,'rptName = "%s";\n\n',sName);
            otherwise
                fprintf(this.FID,"%% Filename = Custom\n");
                Parser.writeExprStr(this.FID,...
                this.Component.FilenameName,'rptName');
            end

            if this.Component.isIncrementFilename
                fprintf(this.FID,"%% If report already exists, increment to prevent overwriting\n");
                fprintf(this.FID,'rptNumSameNames = length(dir(fullfile(rptDir,rptName) + "*." + ext));\n');
                fprintf(this.FID,"rptName = rptName + num2str(rptNumSameNames);\n\n");
            end

            template=Rptgen_CReport.getTemplate('rpath');
            fprintf(this.FID,"%s",template);
        end


        function writeReportOutputType(this)
            if isempty(this.RptFileConverter.OutputType)
                switch this.Component.Format
                case 'dom-pdf-direct'
                    fprintf(this.FID,"%% Report Output Type = Direct PDF (from template)\n");
                    this.RptFileConverter.OutputType="pdf";
                case 'dom-htmx'
                    fprintf(this.FID,"%% Report Output Type = HTML (from template)\n");
                    this.RptFileConverter.OutputType="html";
                case 'dom-pdf'
                    fprintf(this.FID,"%% Report Output Type = PDF (from Word Template)\n");
                    this.RptFileConverter.OutputType="docx";
                case 'dom-html-file'
                    fprintf(this.FID,"%% Report Output Type = Single-File HTML (from template)\n");
                    this.RptFileConverter.OutputType="html-file";
                case 'dom-docx'
                    fprintf(this.FID,"%% Report Output Type = Word (from template)\n");
                    this.RptFileConverter.OutputType="docx";
                case 'pdf-fop'
                    fprintf(this.FID,"%% Report Output Type = Acrobat (PDF)\n");
                    this.RptFileConverter.OutputType="pdf";
                case 'rtf97'
                    fprintf(this.FID,"%% Report Output Type = Rich Text Format\n");
                    this.RptFileConverter.OutputType="docx";
                case 'html'
                    fprintf(this.FID,"%% Report Output Type = web (HTML)\n");
                    this.RptFileConverter.OutputType="html";
                case 'doc-rtf'
                    fprintf(this.FID,"%% Report Output Type = Word Document (RTF)\n");
                    this.RptFileConverter.OutputType="docx";
                case 'db'
                    fprintf(this.FID,"%% Report Output Type = DocBook (no transform)\n");
                    this.RptFileConverter.OutputType="pdf";
                otherwise
                    fprintf(this.FID,"%% Report Output Type = unknown\n");
                    this.RptFileConverter.OutputType="pdf";
                end
            end
            fprintf(this.FID,"rptOutputType = ""%s"";",this.RptFileConverter.OutputType);
            fprintf(this.FID,"\n\n");

        end

        function writeReportTemplatePath(this)

            templatePath=[];
            tID=this.Component.Stylesheet;


            if~ismember(tID,this.DefaultTemplates)
                templateCache=rptgen.db2dom.TemplateCache.getTheCache();
                switch this.RptFileConverter.OutputType
                case "docx"
                    templatePath=getDOCXTemplate(templateCache,tID);
                case "html-file"
                    templatePath=getHTMLFileTemplate(templateCache,tID);
                case "html"
                    templatePath=getHTMLTemplate(templateCache,tID);
                case "pdf"
                    templatePath=getPDFTemplate(templateCache,tID);
                end
            end

            fprintf(this.FID,"%% Report Template Path\n");
            if~isempty(templatePath)
                fprintf(this.FID,'rptObj.TemplatePath = "%s";\n\n',templatePath);
            else


                fprintf(this.FID,'rptObj.TemplatePath = getDefaultReportTemplate(rptOutputType);\n\n');
            end

        end

        function name=getVariableName(~)




            name=[];
        end


        function convertComponentChildren(this)





            writeConvertedChildren(this);

            fprintf(this.FID,"%% Close report container.\n");
            fprintf(this.FID,'%s\n\n','close(rptObj);');

            if strcmp(this.Component.Format,'dom-pdf')
                if this.Component.isView
                    cmd='showdocxaspdf';
                else
                    cmd='convertdocxtopdf';
                end
                fprintf(this.FID,"%% Convert docx report to pdf.\n");
                fprintf(this.FID,"if ispc\n");
                fprintf(this.FID,"docview(rptObj.OutputPath,'%s');\n",...
                cmd);
                fprintf(this.FID,"end"+newline+newline);
            else
                if this.Component.isView
                    fprintf(this.FID,"%% Display report.\n");
                    fprintf(this.FID,'%s\n','rptview(rptObj);');
                end
            end

            writeCleanupCode(this);

            if(this.RptFileConverter.ClearWorkspace)
                fprintf(this.FID,"%% Clear workspace variables created by report generation.\n");
                fprintf(this.FID,"rptState.clearWorkspaceVariables();\n");
            end

            writeEndBanner(this);
        end

        function writeConvertedChildren(this)

            import mlreportgen.rpt2api.*

            children=getComponentChildren(this);
            nChild=numel(children);
            for iChild=1:nChild
                cmpn=children{iChild};
                c=getConverter(this.RptFileConverter.ConverterFactory,...
                cmpn,this.RptFileConverter);
                convert(c);
            end
        end

        function writeCleanupCode(this)
            fprintf(this.FID,"%s",this.RptFileConverter.getCleanupCode());
            fprintf(this.FID,"%% Clean up open figures, models after report execution.\n");
            fprintf(this.FID,"rptState.cleanup();\n");
            if~isempty(this.Component.PostGenerateFcn)
                fprintf(this.FID,"%s",this.Component.PostGenerateFcn);
            end
        end

    end

    methods(Abstract,Access=protected)
        writeImportStatements(this)
        writeCreateReport(this)
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.Rptgen_CReport
            templateFolder=fullfile(Rptgen_CReport.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end
end



