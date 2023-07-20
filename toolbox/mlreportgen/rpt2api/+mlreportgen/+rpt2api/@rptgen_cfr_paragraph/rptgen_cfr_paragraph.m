classdef rptgen_cfr_paragraph<mlreportgen.rpt2api.ComponentConverter





























    methods

        function obj=rptgen_cfr_paragraph(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.*
            import mlreportgen.rpt2api.exprstr.Parser

            writeStartBanner(obj);

            paraVarName=getVariableName(obj);
            fprintf(obj.FID,"%s = Paragraph;\n",paraVarName);

            paraStyleName=obj.Component.StyleName;
            if~isempty(paraStyleName)
                if strcmp(obj.Component.StyleNameType,'custom')
                    Parser.writeExprStr(obj.FID,...
                    paraStyleName,'rptParaStyleName');
                    fprintf(obj.FID,'%s.StyleName = rptParaStyleName;\n',...
                    paraVarName);
                else
                    fprintf(obj.FID,'%s.StyleName = "%s";\n\n',paraVarName,...
                    paraStyleName);
                end
            end

            switch obj.Component.TitleType
            case 'specify'
                paraTitle=obj.Component.ParaTitle;
                if~isempty(paraTitle)
                    Parser.writeExprStr(obj.FID,...
                    paraTitle,'rptParaTitleContent');
                    fprintf(obj.FID,'rptParaTitleObj = Text(rptParaTitleContent + ". ");\n');
                    fprintf(obj.FID,'append(%s, rptParaTitleObj);\n\n',...
                    paraVarName);
                end
            case 'subcomp'
                cmpn=down(obj.Component);
                if~isempty(cmpn)
                    push(obj.RptFileConverter.VariableNameStack,paraVarName);
                    c=getConverter(obj.RptFileConverter.ConverterFactory,...
                    cmpn,obj.RptFileConverter);
                    c.VariableName='rptParaTitleObj';
                    convert(c);
                    pop(obj.RptFileConverter.VariableNameStack);
                    fprintf(obj.FID,"rptParaTitleObj.Content = rptParaTitleObj.Content + "". "";\n");
                    nextCmpn=right(cmpn);
                    parentCmpn=up(cmpn);
                    disconnect(cmpn);
                    connect(nextCmpn,parentCmpn,'up');
                end
            case 'none'
            end

            if obj.Component.ParaTextComp.isWhiteSpace
                objName=getVariableName(obj);
                fprintf(obj.FID,'%s.WhiteSpace = "preserve";\n',objName);
            end

            if~strcmp(obj.Component.TitleType,'none')
                if strcmp(obj.Component.TitleStyleNameType,'custom')
                    Parser.writeExprStr(obj.FID,...
                    obj.Component.TitleStyleName,'rptParaTitleStyleName');
                    fprintf(obj.FID,"rptParaTitleObj.StyleName = rptParaTitleStyleName;\n");
                else
                    fprintf(obj.FID,'rptParaTitleObj.StyleName = "%s";\n',...
                    obj.Component.TitleStyleName);
                end
                fprintf(obj.FID,"rptParaTitleObj.Bold = true;\n\n");
            end

            cmpn=obj.Component.ParaTextComp;
            if~isempty(cmpn)&&~isempty(cmpn.Content)
                push(obj.RptFileConverter.VariableNameStack,paraVarName);
                c=getConverter(obj.RptFileConverter.ConverterFactory,...
                cmpn,obj.RptFileConverter);
                c.VariableName=sprintf("%sContent",paraVarName);
                convert(c);
                pop(obj.RptFileConverter.VariableNameStack);
            end

        end

        function convertComponentChildren(obj)
            import mlreportgen.rpt2api.*

            objName=getVariableName(obj);
            push(obj.RptFileConverter.VariableNameStack,objName);

            children=getComponentChildren(obj);
            n=numel(children);
            for i=1:n
                cmpn=children{i};
                if strcmpi(cmpn.getContentType(),"text")||isa(cmpn,"rptgen.cfr_text")||isa(cmpn,"rptgen.cfr_line_break")
                    c=getConverter(obj.RptFileConverter.ConverterFactory,...
                    cmpn,obj.RptFileConverter);
                    convert(c);
                else
                    fprintf(obj.FID,'%% A component of type %s was not converted because\n',class(cmpn));
                    fprintf(obj.FID,'%% it is the child of a paragraph component. Only text component \n');
                    fprintf(obj.FID,'%% children of a paragraph can be converted. \n\n');
                end
            end
            pop(obj.RptFileConverter.VariableNameStack);

            parentName=obj.RptFileConverter.VariableNameStack.top;
            fprintf(obj.FID,'append(%s,%s);\n\n',parentName,getVariableName(obj));
            writeEndBanner(obj);
        end

        function name=getVariableRootName(~)
            name="rptPara";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=mlreportgen.rpt2api.rptgen_cfr_paragraph.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_paragraph
            templateFolder=fullfile(rptgen_cfr_paragraph.getClassFolder,...
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

