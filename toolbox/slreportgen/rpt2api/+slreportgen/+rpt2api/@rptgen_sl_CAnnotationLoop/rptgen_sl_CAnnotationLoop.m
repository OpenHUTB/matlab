classdef rptgen_sl_CAnnotationLoop<mlreportgen.rpt2api.LoopComponentConverter



























    properties(Access=private)
        Context="";
    end

    properties(Access=private,Constant)
        SupportedContexts=["csl_mdl_loop",...
        "csl_sys_loop"];

        SkippedContexts=["rptgen_sl.csl_sig_loop",...
        "rptgen_sl.csl_blk_loop"];
    end

    methods

        function this=rptgen_sl_CAnnotationLoop(component,rptFileConverter)
            init(this,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import slreportgen.rpt2api.rptgen_sl_CAnnotationLoop



            this.Context=getContext(this,[this.SupportedContexts,this.SkippedContexts]);
            if ismember(this.Context,this.SkippedContexts)
                fprintf(this.FID,"% Annotation loop with %s parent skipped.\n\n",this.Context);
                return
            end

            writeStartBanner(this);
            writeSaveState(this);


            suffix=this.LoopVariableSuffix;

            writeAnnotationList(this);


            if~strcmp(this.Component.SortBy,"none")
                fwrite(this.FID,"% Sort annotations alphabetically."+newline);
                fprintf(this.FID,"rptAnnotationNames = [rptAnnotationList%s.Name];\n",suffix);
                fwrite(this.FID,"[~,rptSortIdx] = sort(rptAnnotationNames);"+newline);
                fprintf(this.FID,"rptAnnotationList%s = rptAnnotationList%s(rptSortIdx);\n\n",suffix,suffix);
            end

            fwrite(this.FID,"% Loop through list of annotations to be reported."+newline);
            fprintf(this.FID,"rptNAnnotations%s = numel(rptAnnotationList%s);\n",suffix,suffix);
            fprintf(this.FID,"for rptIAnnotation%s = 1:rptNAnnotations%s\n",suffix,suffix);
            fprintf(this.FID,"%s.CurrentAnnotation = rptAnnotationList%s(rptIAnnotation%s);\n",...
            this.RptStateVariable,suffix,suffix);

            writeObjectSectionCode(this);
        end

        function writeAnnotationList(this)
            switch this.Context
            case "rptgen_sl.csl_mdl_loop"
                fwrite(this.FID,"% Report on all annotations in reported systems of current model."+newline+newline);


                fwrite(this.FID,"% Create a finder to find annotations in each system."+newline);
                fprintf(this.FID,"rptAnnotationFinder = AnnotationFinder(%s.CurrentModelHandle);\n",this.RptStateVariable);

                fprintf(this.FID,"%% Loop through reported systems\n");
                fprintf(this.FID,"rptReportedSystems = %s.CurrentModelReportedSystems;\n",...
                this.RptStateVariable);
                fwrite(this.FID,"rptAnnotationNSystems = numel(rptReportedSystems);"+newline);
                fprintf(this.FID,"rptAnnotationList%s = [];\n",this.LoopVariableSuffix);
                fwrite(this.FID,"for rptI = 1:rptAnnotationNSystems"+newline);
                fwrite(this.FID,"rptSystemResult = rptReportedSystems(rptI);"+newline);
                fwrite(this.FID,"rptAnnotationFinder.Container = rptSystemResult;"+newline);
                fwrite(this.FID,"% Add annotations to annotation list."+newline);
                fprintf(this.FID,"rptAnnotationList%s = [rptAnnotationList%s, find(rptAnnotationFinder)]; %%#ok<AGROW> \n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);
                fwrite(this.FID,"end"+newline+newline);

            case "rptgen_sl.csl_sys_loop"

                fwrite(this.FID,"% Create a finder to find annotations in the current system."+newline);

                fprintf(this.FID,"rptAnnotationFinder = AnnotationFinder(%s.CurrentSystem);\n",this.RptStateVariable);

                fprintf(this.FID,"rptAnnotationList%s = find(rptAnnotationFinder);\n\n",this.LoopVariableSuffix);

            case "rptgen_sl.CAnnotationLoop"
                fwrite(this.FID,"% Report the current annotation."+newline);
                fprintf(this.FID,"rptAnnotationList%s = [rptState.CurrentAnnotation];\n\n",this.LoopVariableSuffix);
            otherwise

                fwrite(this.FID,"% Report on all annotations in all open models."+newline);
                fprintf(this.FID,"rptAnnotationList%s = [];\n",this.LoopVariableSuffix);
                fwrite(this.FID,"% Find all open models."+newline);
                fwrite(this.FID,"rptAnnotationLoopModelList = find_system( ..."+newline);
                fwrite(this.FID,"SearchDepth=0, ..."+newline);
                fwrite(this.FID,"type=""block_diagram"", ..."+newline);
                fwrite(this.FID,"BlockDiagramType=""model"");"+newline+newline);
                fwrite(this.FID,"% Loop through open models."+newline);
                fwrite(this.FID,"rptN = numel(rptAnnotationLoopModelList);"+newline);
                fwrite(this.FID,"for rptI = 1:rptN"+newline);

                fwrite(this.FID,"% Create an annotation finder to find annotations in each model."+newline);
                fprintf(this.FID,"rptAnnotationFinder = AnnotationFinder(Container=rptAnnotationLoopModelList{rptI}, ...\n");
                fprintf(this.FID,"SearchDepth=Inf);\n");
                fprintf(this.FID,"rptAnnotationList%s = [rptAnnotationList%s, find(rptAnnotationFinder)]; %%#ok<AGROW> \n",...
                this.LoopVariableSuffix,this.LoopVariableSuffix);

                fwrite(this.FID,"end"+newline+newline);
            end
        end

        function convertComponentChildren(this)


            if~ismember(this.Context,this.SkippedContexts)
                convertComponentChildren@mlreportgen.rpt2api.LoopComponentConverter(this);
            end
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(this,titleVarName,~)
            fprintf(this.FID,"rptAnnotationName = %s.CurrentAnnotation.Name;\n",this.RptStateVariable);
            if this.Component.ShowTypeInTitle
                fwrite(this.FID,titleVarName+" = sprintf(""Annotation - %s"",rptAnnotationName);"+newline);
            else
                fwrite(this.FID,titleVarName+" = rptAnnotationName;"+newline);
            end
        end


        function writeObjectIdCode(this,idVarName)
            fprintf(this.FID,"%s = getReporterLinkTargetID(%s.CurrentAnnotation);\n",idVarName,this.RptStateVariable);
        end


        function writeLoopEnd(this)
            fwrite(this.FID,"end % annotation loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_CAnnotationLoop
            templateFolder=fullfile(rptgen_sl_CAnnotationLoop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,'.txt'));
            template=fileread(templatePath);
        end

    end

end