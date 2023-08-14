classdef rptgen_cfr_link<mlreportgen.rpt2api.ComponentConverter

















































    methods

        function obj=rptgen_cfr_link(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.exprstr.Parser

            if isempty(obj.Component.LinkID)
                return;
            end

            varName=getVariableName(obj);
            linkType=obj.Component.LinkType;
            fprintf(obj.FID,"%% LinkType = %s \n",linkType);

            switch linkType
            case "anchor"
                fprintf(obj.FID,'%s = LinkTarget("%s");\n',...
                varName,obj.Component.LinkID);

                if~isempty(obj.Component.LinkText)
                    fprintf(obj.FID,'append(%s,"%s");\n',...
                    varName,obj.Component.LinkText);
                end

            case "link"
                fprintf(obj.FID,'%s = InternalLink("%s","%s");\n',...
                varName,obj.Component.LinkID,obj.Component.LinkText);

            case "ulink"
                fprintf(obj.FID,'%s = ExternalLink("%s","%s");\n',...
                varName,obj.Component.LinkID,obj.Component.LinkText);
            end

            if obj.Component.isEmphasizeText
                fprintf(obj.FID,'%s.Style = [%s.Style, {Italic(true)}];\n',...
                varName,varName);
            end

        end

        function convertComponentChildren(obj)
            parentName=obj.RptFileConverter.VariableNameStack.top;
            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(obj);
            fprintf(obj.FID,"append(%s,%s);\n\n",parentName,getVariableName(obj));

        end

        function name=getVariableRootName(obj)





            if strcmp(obj.Component.LinkType,"anchor")
                name="rptLinkTarget";
            else
                name="rptLink";
            end
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_link.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_link
            templateFolder=fullfile(rptgen_cfr_link.getClassFolder,...
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

