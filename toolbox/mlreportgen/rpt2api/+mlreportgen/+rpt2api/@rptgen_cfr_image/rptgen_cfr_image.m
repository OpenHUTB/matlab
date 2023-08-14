classdef rptgen_cfr_image<mlreportgen.rpt2api.ComponentConverter












































    properties






        MakeInline=false;
    end

    methods

        function this=rptgen_cfr_image(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser


            imgFileName=this.Component.FileName;
            parser=Parser(imgFileName);
            parse(parser);
            if~isempty(parser.Expressions)




                imgFileName=evalin("base",parser.Expressions{1});
            end

            if isempty(imgFileName)

                template=mlreportgen.rpt2api.rptgen_cfr_image.getTemplate('noImageName');
                fprintf(this.FID,"%s",template);
                return;
            else
                imgFilePath=mlreportgen.utils.findFile(imgFileName);
                if isempty(imgFilePath)

                    template=mlreportgen.rpt2api.rptgen_cfr_image.getTemplate('imageNotFound');
                    fprintf(this.FID,template,imgFileName);
                    return;
                end
            end



            writeStartBanner(this);


            if this.Component.isCopyFile


                [scriptPath,~,~]=fileparts(this.RptFileConverter.ScriptPath);
                [~,sourceImgFileName,sourceImgFileExt]=fileparts(imgFilePath);
                copiedImgFilePath=fullfile(scriptPath,...
                strcat(sourceImgFileName,sourceImgFileExt));
                copyfile(imgFilePath,copiedImgFilePath);
                fprintf(this.FID,'rptImageFilePath = "%s";\n',copiedImgFilePath);
            else

                fprintf(this.FID,'rptImageFilePath = "%s";\n',imgFilePath);
            end


            imageVarName=getVariableName(this);
            parentName=this.RptFileConverter.VariableNameStack.top;
            if this.Component.isInline||this.MakeInline

                fprintf(this.FID,"%s = Image(rptImageFilePath);\n",imageVarName);



                hAlign=this.Component.DocHorizAlign;
                if~strcmp(hAlign,"auto")
                    fprintf(this.FID,'%s.Style = [%s.Style {HAlign("%s")}];\n',...
                    imageVarName,imageVarName,hAlign);
                end
            else


                fprintf(this.FID,"%s = FormalImage(rptImageFilePath);\n",imageVarName);


                if~strcmp(this.Component.isTitle,"none")
                    if strcmp(this.Component.isTitle,"filename")
                        [~,name,ext]=fileparts(imgFileName);
                        titleContent=strcat(name,ext);
                    else
                        titleContent=this.Component.Title;
                        parser=Parser(titleContent);
                        parse(parser);
                    end



                    fprintf(this.FID,'rptImageTitle = Paragraph("%s");\n',...
                    titleContent);
                    fprintf(this.FID,"append(%s,rptImageTitle);\n",...
                    parentName);
                end


                caption=this.Component.Caption;
                if~isempty(caption)
                    Parser.writeExprStr(this.FID,...
                    caption,sprintf("%s.Caption",imageVarName));
                end
            end






            if strcmp(this.Component.ViewportType,"fixed")
                units=mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.ViewportUnits);
                fprintf(this.FID,'%s.Width = "%s";\n',imageVarName,...
                strcat(num2str(this.Component.ViewportSize(1)),units));
                fprintf(this.FID,'%s.Height = "%s";\n',imageVarName,...
                strcat(num2str(this.Component.ViewportSize(2)),units));
            end

            if~isempty(this.AssignTo)
                fprintf(this.FID,"%s = %s;\n\n",this.AssignTo,imageVarName);
            else

                fprintf(this.FID,"append(%s,%s);\n\n",...
                parentName,imageVarName);
            end



            writeEndBanner(this);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptImage";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_image.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_image
            templateFolder=fullfile(rptgen_cfr_image.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

    methods(Access=private,Static)
        function count=getCurrentCounter()


            persistent counter;
            if isempty(counter)


                counter=1;




                mlreportgen.rpt2api.ComponentConverter.classesToClearAfterConversion(mfilename);
            else

                counter=counter+1;
            end
            count=counter;
        end
    end

end
