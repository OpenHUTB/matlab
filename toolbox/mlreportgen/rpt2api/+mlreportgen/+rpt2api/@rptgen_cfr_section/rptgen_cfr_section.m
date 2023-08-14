classdef rptgen_cfr_section<mlreportgen.rpt2api.ComponentConverter




























    methods

        function obj=rptgen_cfr_section(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end
    methods(Access=protected)

        function write(obj)
            import mlreportgen.rpt2api.rptgen_cfr_section
            import mlreportgen.rpt2api.exprstr.Parser

            if obj.RptFileConverter.IncludeTOC&&~obj.RptFileConverter.TOCAdded

                parentName=obj.RptFileConverter.VariableNameStack.top;
                fprintf(obj.FID,"append(%s,TableOfContents);\n\n",parentName);
                obj.RptFileConverter.TOCAdded=true;
            end

            writeStartBanner(obj);

            obj.RptFileConverter.CurrentSectionLevel=...
            obj.RptFileConverter.CurrentSectionLevel+1;

            sectName=getVariableName(obj);

            if obj.Component.isTitleFromSubComponent
                cmpn=down(obj.Component);
                if~isempty(cmpn)
                    push(obj.RptFileConverter.VariableNameStack,...
                    sectName);
                    c=getConverter(obj.RptFileConverter.ConverterFactory,...
                    cmpn,obj.RptFileConverter);
                    c.AssignTo="rptSectTitle";
                    convert(c);
                    pop(obj.RptFileConverter.VariableNameStack);
                end
            else
                Parser.writeExprStr(obj.FID,obj.Component.SectionTitle,...
                'rptSectTitle');
            end

            if obj.RptFileConverter.CurrentSectionLevel==1
                fprintf(obj.FID,'%s = Chapter();\n',sectName);
                if~isempty(obj.RptFileConverter.CurrentLayoutObject)
                    fprintf(obj.FID,"%% Set the chapter's layout to the overall document's layout\n");
                    fprintf(obj.FID,"append(%s,clone(%s));\n\n",...
                    sectName,obj.RptFileConverter.CurrentLayoutObject);
                end
            else
                fprintf(obj.FID,'%s = Section();\n',sectName);
            end



            if strcmp(obj.Component.NumberMode,'manual')
                fprintf(obj.FID,'%s.Numbered = false;\n',sectName);
                if obj.RptFileConverter.CurrentSectionLevel==1
                    fprintf(obj.FID,...
                    'rptSectTitle = "Chapter %s. " + rptSectTitle;\n',...
                    obj.Component.Number);
                else
                    fprintf(obj.FID,...
                    'rptSectTitle = "%s. " + rptSectTitle;\n',...
                    obj.Component.Number);
                end
            end

            fprintf(obj.FID,'%s.Title = rptSectTitle;\n\n',...
            sectName);

        end

        function name=getVariableRootName(obj)





            level=obj.RptFileConverter.CurrentSectionLevel;
            if level==1
                name="rptChapterRptr";
            else
                name=sprintf("rptSubsectLev%dRptr",level-1);
            end
        end

        function counter=getVariableNameCounter(obj)















            if isempty(obj.VariableNameCounter)


                obj.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cfr_section.getCurrentCounter();
            end
            counter=obj.VariableNameCounter;
        end

        function convertComponentChildren(obj)
            parentName=obj.RptFileConverter.VariableNameStack.top;
            convertComponentChildren@mlreportgen.rpt2api.ComponentConverter(obj);
            fprintf(obj.FID,'append(%s,%s);\n\n',parentName,getVariableName(obj));
            obj.RptFileConverter.CurrentSectionLevel=...
            obj.RptFileConverter.CurrentSectionLevel-1;
            writeEndBanner(obj);
        end

        function child=getFirstChildComponent(obj)




            child=down(obj.Component);
            if obj.Component.isTitleFromSubComponent
                child=right(child);
            end

        end


    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cfr_section
            templateFolder=fullfile(rptgen_cfr_section.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

        function index=getNameIndex()

            persistent currIndex

            if isempty(currIndex)
                currIndex=1;
            else
                currIndex=currIndex+1;
            end

            index=currIndex;
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

