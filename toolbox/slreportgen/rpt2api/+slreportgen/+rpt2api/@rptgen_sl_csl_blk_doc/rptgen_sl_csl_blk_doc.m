classdef rptgen_sl_csl_blk_doc<mlreportgen.rpt2api.ComponentConverter




























    methods

        function this=rptgen_sl_csl_blk_doc(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);

            allowedContextList=["rptgen_sl.csl_mdl_loop","rptgen_sl.csl_sys_loop","rptgen_sl.csl_blk_loop"];
            stateVariable=this.RptStateVariable;
            docBlockContext=getContext(this,allowedContextList);

            if strcmp(docBlockContext,"rptgen_sl.csl_blk_loop")

                fprintf(this.FID,"rptCurrentBlockObject = %s.CurrentBlock.Object;\n",stateVariable);

                fwrite(this.FID,"if isDocBlock(rptCurrentBlockObject)"+newline);


                writeDocBlock(this);

                fwrite(this.FID,"end"+newline);
            else

                if strcmp(docBlockContext,"rptgen_sl.csl_sys_loop")
                    fwrite(this.FID,"% Report on all docblock blocks in the current system."+newline);
                    fprintf(this.FID,"rptDocBlockFinder = BlockFinder(Container=%s.CurrentSystem, ...\n",stateVariable);
                    fprintf(this.FID,"Properties={""MaskType"",""DocBlock""});%%#ok<CLARRSTR>\n");
                    fprintf(this.FID,"rptDocBlockList = find(rptDocBlockFinder);\n\n");
                else
                    fwrite(this.FID,"% Report on all docblock blocks in the current model."+newline);
                    fprintf(this.FID,"rptDocBlockList = [];\n");
                    fprintf(this.FID,"rptN = numel(%s.CurrentModelReportedSystems);\n",stateVariable);
                    fprintf(this.FID,"for rptI = 1:rptN\n");
                    fprintf(this.FID,"rptDocBlockFinder = BlockFinder(Container=%s.CurrentModelReportedSystems(rptI), ...\n",stateVariable);
                    fprintf(this.FID,"Properties={""MaskType"",""DocBlock""});%%#ok<CLARRSTR>\n");
                    fprintf(this.FID,"rptDocBlockList = [rptDocBlockList, find(rptDocBlockFinder)]; %%#ok<AGROW> \n\n");
                    fprintf(this.FID,"end\n\n");
                end

                fwrite(this.FID,"% Loop through list of blocks to be reported."+newline);
                fwrite(this.FID,"rptNDocBlocks = numel(rptDocBlockList);"+newline);
                fwrite(this.FID,"for rptIDocBlock = 1:rptNDocBlocks"+newline);
                fwrite(this.FID,"rptCurrentBlockObject = rptDocBlockList(rptIDocBlock).Object;"+newline);

                fprintf(this.FID,"%s.CurrentBlock = rptDocBlockList(rptIDocBlock);\n\n",stateVariable);


                writeDocBlock(this);

                fwrite(this.FID,"end"+newline);
            end



            writeEndBanner(this);

        end

        function name=getVariableRootName(~)





            name="rptDocBlock";
        end

        function counter=getVariableNameCounter(this)















            if isempty(this.VariableNameCounter)


                this.VariableNameCounter=...
                slreportgen.rpt2api.rptgen_sl_csl_blk_doc.getCurrentCounter();
            end
            counter=this.VariableNameCounter;
        end
    end

    methods(Access=private)

        function writeDocBlock(this)


            varName=getVariableName(this);
            fprintf(this.FID,"%s = DocBlock(rptCurrentBlockObject);\n",varName);


            if~this.Component.ConvertHTML
                fprintf(this.FID,"%s.ConvertHTML = false;\n",varName);
            end


            if this.Component.EmbedFile
                fprintf(this.FID,"%s.EmbedFile = true;\n",varName);
            end


            if~this.Component.LinkingAnchor
                fprintf(this.FID,'%s.LinkTarget = "";\n',varName);
            end


            type=this.Component.ImportType;
            parentName=this.RptFileConverter.VariableNameStack.top;

            contentType=getContentType(this.Component);
            if strcmp(contentType,"text")



                fwrite(this.FID,"docBlockType = get_param(rptCurrentBlockObject,""DocumentType"");"+newline);










                fwrite(this.FID,"isInvalidCase = strcmpi(docBlockType,""HTML"");"+newline);
                fwrite(this.FID,"if isInvalidCase"+newline);
                fwrite(this.FID,"blockPath = rptState.CurrentBlock.BlockPath;"+newline);
                fwrite(this.FID,"warning(strcat(""The "",blockPath,"" is of type "",docBlockType, "" and is currently not supported.""));"+newline);
                fwrite(this.FID,"else"+newline);
                fwrite(this.FID,"if strcmpi(docBlockType,""text"")"+newline);

                fprintf(this.FID,"%s.ImportTextInline = true;\n",varName);

                fwrite(this.FID,"end"+newline);

                if strcmp(type,"honorspaces")
                    fprintf(this.FID,'%s.TextFormatter.StyleName = "rgLiteralLayout";\n',varName);
                elseif strcmp(type,"fixedwidth")
                    fprintf(this.FID,'%s.TextFormatter.StyleName = "rgProgramListing";\n',varName);
                end






                fwrite(this.FID,"% Get the list of DOM objects used to create the DocBlock Reporter."+newline);
                fprintf(this.FID,"rptDocBlockImpl = getImpl(%s,rptObj);\n",varName);
                fwrite(this.FID,"% Loop through list of children present in the rptDocBlockImpl."+newline);
                fwrite(this.FID,"rptDocBlockImplChildren = rptDocBlockImpl.Children;"+newline);
                fwrite(this.FID,"rptNDocBlockImplChildren = numel(rptDocBlockImplChildren);"+newline);
                fwrite(this.FID,"for rptDocBlockChild = 1:rptNDocBlockImplChildren"+newline);




                fwrite(this.FID,"if ~isa(rptDocBlockImplChildren(rptDocBlockChild),""mlreportgen.dom.TemplateText"")"+newline);
                fwrite(this.FID,"rptDocBlockClone = clone(rptDocBlockImplChildren(rptDocBlockChild));"+newline);
                fprintf(this.FID,"append(%s,rptDocBlockClone);\n",parentName);

                fwrite(this.FID,"end"+newline);
                fwrite(this.FID,"end"+newline);
                fwrite(this.FID,"end"+newline);
            else

                switch type
                case "para-lb"
                    importType="LineFeed";
                case "para-emptyrow"
                    importType="BlankLine";
                end
                fprintf(this.FID,'%s.TextSep = "%s";\n',varName,importType);
                fprintf(this.FID,"append(%s,%s);\n\n",parentName,varName);

            end

        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_blk_doc
            templateFolder=fullfile(rptgen_sl_csl_blk_doc.getClassFolder,...
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