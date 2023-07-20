classdef(Hidden)RptFileBase<handle




    properties



        SetupFile{mlreportgen.report.validators.mustBeString}=[];
    end

    properties(Access=public,Hidden)



        CReport=[];



        Content=[];
    end

    methods
        function set.SetupFile(this,value)
            if ischar(value)
                this.SetupFile=string(value);
            else
                this.SetupFile=value;
            end
        end
    end

    methods(Access=protected)

        function content=getHoleContent(this,rpt)



            templatePath=getDefaultTemplatePath(this,rpt);
            docPart=mlreportgen.dom.DocumentPart(rpt.Type,templatePath);


            xmlFile=rpt.generateFileName("xml");
            try
                rptgen.report(...
                this.CReport,...
                "-fdb",...
                strcat("-o",xmlFile),...
                "-noview",...
"-quiet"...
                );
            catch ME
                rethrow(ME);
            end


            docBook=mlreportgen.db2dom.DocBook(...
            rpt.generateFileName(),...
            rpt.Type,...
templatePath...
            );






            docBook.appendDocBookXMLFileToDocPart(xmlFile,docPart);



            this.Content=docPart;


            content=this.Content;
        end

        function loadSetupFile(this)


            if isempty(this.SetupFile)

                error(message("mlreportgen:report:error:noRptFileNameSpecified"));
            else

                filePath=mlreportgen.utils.findFile(this.SetupFile,...
                "FileExtensions","rpt");
                if isempty(filePath)

                    error(message("mlreportgen:report:error:RptFileNotFound",...
                    this.SetupFile));
                else

                    rpt=rptgen.loadRpt(this.SetupFile);


                    rptClass=class(rpt);
                    if~(strcmp(rptClass,"RptgenML.CReport")||...
                        strcmp(rptClass,"rptgen.coutline"))

                        error(message("mlreportgen:report:error:invalidRptType",...
                        class(rpt)));
                    else


                        this.CReport=rpt;
                    end
                end
            end
        end

    end

end