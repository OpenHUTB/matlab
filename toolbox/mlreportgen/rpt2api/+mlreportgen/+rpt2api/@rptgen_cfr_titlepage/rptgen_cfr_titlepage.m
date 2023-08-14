classdef rptgen_cfr_titlepage<mlreportgen.rpt2api.ComponentConverter












































    methods

        function obj=rptgen_cfr_titlepage(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(obj);


            titlePageVarName=getVariableName(obj);
            fprintf(obj.FID,"%s = TitlePage;\n",titlePageVarName);


            title=obj.Component.Title;
            if~isempty(title)
                Parser.writeExprStr(obj.FID,...
                title,sprintf("%s.Title",titlePageVarName));
            end


            subtitle=obj.Component.Subtitle;
            if~isempty(subtitle)
                Parser.writeExprStr(obj.FID,...
                subtitle,sprintf("%s.Subtitle",titlePageVarName));
            end


            authorPropName=sprintf("%s.Author",titlePageVarName);
            switch obj.Component.AuthorMode
            case "none"
                fprintf(obj.FID,"%s = [];\n",authorPropName);
            case "auto"
                fprintf(obj.FID,'%s = "%s";\n',...
                authorPropName,getenv("username"));
            case "manual"
                author=obj.Component.Author;
                if~isempty(author)
                    Parser.writeExprStr(obj.FID,...
                    author,authorPropName);
                end
            end


            if obj.Component.Include_Date
                fprintf(obj.FID,'%s = datestr(now,"%s"); %%#ok<TNOW1,DATST>\n',...
                sprintf("%s.PubDate",titlePageVarName),...
                obj.Component.DateFormat);
            end


            if~isempty(obj.Component.Image)





                imageComp=obj.Component.ImageComp;
                imageConverter=getConverter(obj.RptFileConverter.ConverterFactory,...
                imageComp,obj.RptFileConverter);
                imageConverter.MakeInline=true;
                imageConverter.AssignTo=sprintf("%s.Image",titlePageVarName);
                convert(imageConverter);
            end


            parentName=obj.RptFileConverter.VariableNameStack.top;
            fprintf(obj.FID,"append(%s,%s);\n\n",...
            parentName,titlePageVarName);






            writeEndBanner(obj);
        end

        function convertComponentChildren(~)

        end

        function name=getVariableName(obj)
            name=obj.VariableName;
            if isempty(name)
                name="rptTitlePage";
            end
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_titlepage
            templateFolder=fullfile(rptgen_cfr_titlepage.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
