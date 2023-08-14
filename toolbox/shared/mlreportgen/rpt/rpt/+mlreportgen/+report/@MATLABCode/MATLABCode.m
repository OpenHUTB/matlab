classdef MATLABCode<mlreportgen.report.Reporter



























































    properties(Dependent)






        FileName{mlreportgen.report.validators.mustBeString};






        Content{mlreportgen.report.validators.mustBeString};
    end

    properties



        SmartIndent{mlreportgen.report.validators.mustBeLogical}=false;







        IncludeComplexity{mlreportgen.report.validators.mustBeLogical}=false;














ComplexityReporter
    end

    properties(Access=private)

        MCode=[];


        MCodeFilePath=[];



        IsMLX=false;


        ShouldNumberTableHierarchically=[];
    end

    methods

        function this=MATLABCode(varargin)
            if(nargin==1)
                varargin=[{"FileName"},varargin];
            end
            this=this@mlreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","MATLABCode");

            complexityTable=mlreportgen.report.BaseTable();
            complexityTable.TableStyleName="MATLABCodeTable";
            addParameter(p,"ComplexityReporter",complexityTable);


            parse(p,varargin{:});



            results=p.Results;
            this.ComplexityReporter=results.ComplexityReporter;
            this.TemplateName=results.TemplateName;
        end

        function value=get.Content(this)


            value=this.MCode;
        end

        function set.Content(this,value)


            if ischar(value)
                value=string(value);
            end

            if isempty(value)||(value=="")

                this.MCode=[];
            else


                this.MCode=value;
            end



            this.MCodeFilePath=[];
        end

        function value=get.FileName(this)


            value=this.MCodeFilePath;
        end

        function set.FileName(this,value)


            if ischar(value)
                value=string(value);
            end

            if isempty(value)||(value=="")

                this.MCodeFilePath=[];
            else
                filePath=mlreportgen.utils.findFile(value,"FileExtensions",["m","mlx"]);
                if isempty(filePath)

                    error(message("mlreportgen:report:error:MATLABFileNotFound",...
                    value));
                else
                    [~,~,ext]=fileparts(filePath);
                    if~(strcmpi(ext,".m")||strcmpi(ext,".mlx"))


                        error(message("mlreportgen:report:error:invalidMATLABFile",...
                        value));
                    else

                        this.MCodeFilePath=filePath;





                        m_file=this.MCodeFilePath;
                        if strcmpi(ext,".mlx")
                            this.IsMLX=true;
                            m_file=strcat(tempname(),".m");
                            cleanup=onCleanup(@()delete(m_file));
                            doc=matlab.desktop.editor.openDocument(this.MCodeFilePath,"Visible",false);
                            doc.saveAs(m_file);
                            doc.closeNoPrompt();
                        end

                        fileContent=fileread(m_file);
                        if isempty(fileContent)

                            error(message("mlreportgen:report:error:emptyMATLABFile",...
                            value));
                        else


                            this.MCode=string(fileContent);
                        end
                    end
                end
            end
        end

        function set.ComplexityReporter(this,value)

            mustBeNonempty(value);


            mlreportgen.report.validators.mustBeInstanceOf("mlreportgen.report.BaseTable",value);

            this.ComplexityReporter=value;
        end

        function impl=getImpl(this,rpt)
            if isempty(this.MCode)&&isempty(this.MCodeFilePath)
                error(message("mlreportgen:report:error:noMATLABCodeSpecified"));
            end

            this.ShouldNumberTableHierarchically=isChapterNumberHierarchical(this,rpt);


            impl=getImpl@mlreportgen.report.Reporter(this,rpt);
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreportgen.report.MATLABCode})

        function content=getContent(this,rpt)


            if this.IsMLX




                if this.SmartIndent






                    tempFile=generateFileName(rpt,"mlx");
                    copyfile(this.MCodeFilePath,tempFile);
                    fileattrib(tempFile,'+w');


                    indentCodeFile(tempFile);


                    fileToExport=tempFile;
                else

                    fileToExport=this.MCodeFilePath;
                end

                if strcmpi(rpt.Type,"html")||strcmpi(rpt.Type,"html-file")



                    exportedFile=exportMLX(fileToExport,"html",rpt);
                    content=mlreportgen.dom.RawText(fileread(exportedFile));
                elseif strcmpi(rpt.Type,"docx")



                    exportedFile=exportMLX(fileToExport,"docx",rpt);
                    content=mlreportgen.dom.EmbeddedObject(exportedFile,this.MCodeFilePath);
                else



                    exportedFile=exportMLX(fileToExport,"html",rpt);





                    preppedHTMLStr=mlreportgen.utils.html2dom.prepHTMLFile(exportedFile,"Tidy",false);






                    classNamePattern=caseInsensitivePattern("class=")+...
                    ("'"|'"')+wildcardPattern+("'"|'"');
                    htmlStr=erase(preppedHTMLStr,classNamePattern);

                    content=mlreportgen.dom.HTML(htmlStr);
                end
            else



                if this.SmartIndent






                    tempFile=getCodeContentFile(this,rpt);


                    indentCodeFile(tempFile);


                    contentToReport=fileread(tempFile);
                else

                    contentToReport=this.MCode;
                end

                content=...
                mlreportgen.utils.internal.MATLABCode(contentToReport);
            end
        end

        function content=getComplexity(this,rpt)


            content=[];

            if this.IncludeComplexity

                codeComplexityData=getCodeComplexityData(this,rpt);

                if~isempty(codeComplexityData)

                    complexityTableReporter=copy(this.ComplexityReporter);


                    appendTitle(complexityTableReporter,...
                    getString(message("mlreportgen:report:MATLABCode:complexityTableTitle")));


                    if mlreportgen.report.Reporter.isInlineContent(complexityTableReporter.Title)
                        titleReporter=getTitleReporter(complexityTableReporter);
                        titleReporter.TemplateSrc=this;

                        if this.ShouldNumberTableHierarchically
                            titleReporter.TemplateName="MATLABCodeHierNumberedTitle";
                        else
                            titleReporter.TemplateName="MATLABCodeNumberedTitle";
                        end
                        complexityTableReporter.Title=titleReporter;
                    end


                    headerRowData={...
                    getString(message("mlreportgen:report:MATLABCode:functionName")),...
                    getString(message("mlreportgen:report:MATLABCode:complexity"))...
                    };



                    formalTable=mlreportgen.dom.FormalTable(headerRowData,codeComplexityData);



                    complexityTableReporter.Content=formalTable;


                    content=complexityTableReporter;
                end
            end
        end
    end

    methods(Access=private)

        function codeContentFile=getCodeContentFile(this,rpt)


            codeContentFile=generateFileName(rpt,"m");
            fId=fopen(codeContentFile,"w+");
            fwrite(fId,this.MCode);
            fclose(fId);
        end

        function complexityData=getCodeComplexityData(this,rpt)


            complexityData={};

            if~isempty(this.MCodeFilePath)
                codeFile=this.MCodeFilePath;
            else

                codeFile=getCodeContentFile(this,rpt);
            end

            codeInfo=checkcode(codeFile,"-cyc");
            nCodeInfo=length(codeInfo);
            for i=1:nCodeInfo
                message=codeInfo(i).message;

                if contains(message,"McCabe")

                    fcnName=extractBetween(message,("'"|'"'),("'"|'"'));



                    message=erase(message,fcnName);
                    fcnComplexity=extract(message,digitsPattern);

                    complexityData=[complexityData;...
                    {fcnName{1},str2double(fcnComplexity{1})}];%#ok<AGROW>
                end
            end
        end

    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()



            path=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)







            path=mlreportgen.report.MATLABCode.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)










            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"mlreportgen.report.MATLABCode");
        end

    end
end

function exportedFile=exportMLX(mlxFilePath,exportType,rpt)

    exportedFile=generateFileName(rpt,exportType);

    doc=matlab.desktop.editor.openDocument(mlxFilePath,"Visible",false);
    doc.saveAs(exportedFile);
    doc.closeNoPrompt();
end

function indentCodeFile(file)

    doc=matlab.desktop.editor.openDocument(file,"Visible",false);
    doc.smartIndentContents;
    doc.save;
    doc.close;
end