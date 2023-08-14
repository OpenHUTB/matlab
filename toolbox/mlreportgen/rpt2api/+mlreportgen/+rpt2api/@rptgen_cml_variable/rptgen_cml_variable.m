classdef rptgen_cml_variable<mlreportgen.rpt2api.ComponentConverter
















































    methods

        function this=rptgen_cml_variable(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser

            source=this.Component.Source;
            mlVar=this.Component.Variable;
            if~strcmp(source,"direct")&&isempty(mlVar)
                fprintf(this.FID,"%% Variable name is empty for the InsertVariable Component.\n");
                return;
            end



            writeStartBanner(this);

            varName=getVariableName(this);
            fprintf(this.FID,"%s = MATLABVariable();\n",varName);
            fprintf(this.FID,"%s.TableReporter.TableStyleName = ""rgRuledTable"";\n",...
            varName);


            if strcmp(source,"direct")
                sourceDirect=this.Component.SourceDirect;
                fprintf(this.FID,'%s.Variable = "%s";\n',varName,...
                class(sourceDirect));


                fprintf(this.FID,'%s.setVariableValue("%s");\n',...
                varName,sourceDirect);
            else
                Parser.writeExprStr(this.FID,mlVar,"rptMATLABVariableName");
                fprintf(this.FID,"%s.Variable = rptMATLABVariableName;\n",varName);


                switch upper(source)
                case "G"
                    type="Global";
                case "M"
                    type="MAT-File";
                    fprintf(this.FID,'%s.FileName = "%s";\n',...
                    varName,this.Component.Filename);
                otherwise

                    type="MATLAB";
                end
                fprintf(this.FID,'%s.Location = "%s";\n',varName,type);
            end


            displayTable=this.Component.DisplayTable;
            if~strcmp(displayTable,"auto")
                switch lower(displayTable)
                case "table"
                    formatPolicy="Table";
                case "para"
                    formatPolicy="Paragraph";
                otherwise
                    formatPolicy="Inline Text";
                end
                fprintf(this.FID,'%s.FormatPolicy = "%s";\n',...
                varName,formatPolicy);
            end

            mode=this.Component.TitleMode;
            if strcmp(mode,"none")
                fprintf(this.FID,"%s.IncludeTitle = false;\n",...
                varName);
            end

            if strcmp(mode,"manual")
                Parser.writeExprStr(this.FID,...
                this.Component.CustomTitle,"rptMATLABVariableTitle");
                fprintf(this.FID,"%s.Title = rptMATLABVariableTitle;\n",...
                varName);
            end


            if this.Component.ShowTypeInHeading
                fprintf(this.FID,"%s.ShowDataType = true;\n",varName);
            end


            if this.Component.IgnoreIfEmpty
                fprintf(this.FID,"%s.ShowEmptyValues = false;\n",varName);
            end


            if this.Component.IgnoreIfDefault
                fprintf(this.FID,"%s.ShowDefaultValues = false;\n",varName);
            end



            sizeLimit=this.Component.SizeLimit;
            if isequal(sizeLimit,0)


                fprintf(this.FID,"%s.MaxCols = Inf;\n",varName);
            else
                fprintf(this.FID,"%s.MaxCols = %d;\n",...
                varName,sizeLimit);
            end


            depthLimit=this.Component.DepthLimit;
            if~isequal(depthLimit,10)
                fprintf(this.FID,"%s.DepthLimit = %d;\n",...
                varName,depthLimit);
            end


            objectLimit=this.Component.ObjectLimit;
            if~isequal(objectLimit,200)
                fprintf(this.FID,"%s.ObjectLimit = %d;\n",...
                varName,objectLimit);
            end


            if~this.Component.ShowTableGrids









                [filepath,~,~]=fileparts(this.RptFileConverter.ScriptPath);
                template=mlreportgen.rpt2api.rptgen_cml_variable.getTemplate('removeTableGrids');
                path=fullfile(filepath,"removeTableGrids.m");

                fileID=fopen(path,"w","n","UTF-8");
                fprintf(fileID,"%s",template);
                fclose(fileID);
                doc=matlab.desktop.editor.openDocument(path,"Visible",false);
                doc.smartIndentContents;
                doc.save;
                doc.close;
                fprintf(this.FID,"%s.TableReporter.TableEntryUpdateFcn = @removeTableGrids;\n",...
                varName);
            end


            if this.Component.MakeTablePageWide
                fprintf(this.FID,'%s.TableReporter.TableWidth = "%s";\n',...
                varName,"100%");
            end


            propFilter=this.Component.PropertyFilterCode;
            if~startsWith(propFilter,"%")
                fprintf(this.FID,'%s.PropertyFilterFcn = "%s";\n',...
                varName,propFilter);
            end

            parentName=this.RptFileConverter.VariableNameStack.top;
            comp_parent=getParent(this.Component);
            while~isempty(comp_parent)
                switch class(comp_parent)
                case "rptgen.cfr_section"
                    break;
                otherwise

                    if isempty(comp_parent.getContentType)
                        comp_parent=getParent(comp_parent);
                    else
                        break;
                    end
                end
            end

            if strcmp(displayTable,"text")







                fprintf(this.FID,"rptMATLABVariableImpl = getImpl(%s,rptObj);\n",varName);
                if isa(comp_parent,'rptgen.cfr_section')&&comp_parent.isTitleFromSubComponent






                    if~isempty(this.AssignTo)
                        fprintf(this.FID,'%s = rptMATLABVariableImpl{1};\n\n',this.AssignTo);
                    end
                else
                    fprintf(this.FID,"append(%s,rptMATLABVariableImpl{1});\n\n",parentName);

                end

            else
                fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);
            end



            writeEndBanner(this);

        end

        function convertComponentChildren(~)

        end

        function name=getVariableRootName(~)





            name="rptMATLABVariable";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                mlreportgen.rpt2api.rptgen_cml_variable.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end


    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cml_variable
            templateFolder=fullfile(rptgen_cml_variable.getClassFolder,...
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

