classdef rptgen_sl_csl_mdl_loop<mlreportgen.rpt2api.LoopComponentConverter





























    methods

        function obj=rptgen_sl_csl_mdl_loop(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(obj)
            import slreportgen.rpt2api.rptgen_sl_csl_mdl_loop

            writeStartBanner(obj);

            writeSaveState(obj);


            suffix=obj.LoopVariableSuffix;

            fwrite(obj.FID,"% List of models to be reported"+newline);
            fprintf(obj.FID,"rptModelList%s = {};\n\n",suffix);

            fwrite(obj.FID,"% Map of models to report options for that model"+newline);
            fprintf(obj.FID,"rptMROMap%s = containers.Map;\n\n",suffix);

            loopList=obj.Component.LoopList;
            nLoopList=numel(loopList);
            for i=1:nLoopList

                if loopList(i).Active
                    fprintf(obj.FID,'%% SPECIFY REPORT OPTIONS FOR MODEL GROUP %d\n\n',...
                    i);
                    writeModelList(obj,loopList(i));
                end
            end

            fwrite(obj.FID,"% END OF MODEL GROUP SETUP"+newline+newline);

            template=rptgen_sl_csl_mdl_loop.getTemplate('tModelLoop');
            template=strrep(template,"<LOOP_VARIABLE_SUFFIX>",suffix);
            fwrite(obj.FID,template);

            writeObjectSectionCode(obj);
        end

        function writeModelReportOptions(obj,options)
            import mlreportgen.rpt2api.exprstr.Parser


            if strcmp(options.MdlCurrSys{1},'$top')
                fwrite(obj.FID,"% Start reporting from model root"+newline);
                fwrite(obj.FID,"rptMRO.IsStartSystemRoot = true;"+newline+newline);
            else
                fwrite(obj.FID,"% Start reporting from currently selected system"+newline);
                fwrite(obj.FID,"rptMRO.IsStartSystemRoot = false;"+newline+newline);
            end

            switch options.SysLoopType
            case 'all'
                fwrite(obj.FID,"% Report all model subsystems."+newline);
                fwrite(obj.FID,"rptMRO.ReportStartingSystemOnly = false;");
            case 'current'
                fwrite(obj.FID,"% Report only the starting system."+newline);
                fwrite(obj.FID,"rptMRO.ReportStartingSystemOnly = true;");
            case 'currentBelow'
                fwrite(obj.FID,"% Report on the starting system and its descendants."+newline);
                fwrite(obj.FID,"rptMRO.ReportStartingSystemOnly = false;");
            case 'currentAbove'
                fwrite(obj.FID,"% Reporting on ancestors of starting system is not supported."+newline);
                fwrite(obj.FID,"rptMRO.ReportStartingSystemOnly = false;");
            otherwise
                fwrite(obj.FID,"% Unknown model traversal option."+newline);
                fwrite(obj.FID,"rptMRO.ReportStartingSystemOnly = false;");
            end
            fwrite(obj.FID,""+newline+newline);

            if strcmp(options.isMask,'none')
                fwrite(obj.FID,"% Report masked subsystems as blocks."+newline);
                fwrite(obj.FID,"rptMRO.IncludeMaskedSubsystems = false;"+newline+newline);
            else
                fwrite(obj.FID,"% Report masked subsystems as subsystems rather than as blocks."+newline);
                fwrite(obj.FID,"rptMRO.IncludeMaskedSubsystems = true;"+newline+newline);
            end

            if strcmp(options.isLibrary,'on')
                fwrite(obj.FID,"% Report on user library blocks referenced by model."+newline);
                fwrite(obj.FID,"rptMRO.IncludeUserLibraryLinks = true;"+newline+newline);
            else
                fwrite(obj.FID,"% Do not report on user library blocks referenced by model."+newline);
                fwrite(obj.FID,"rptMRO.IncludeUserLibraryLinks = false;"+newline+newline);
            end

            if options.ModelReferenceDepth>0
                fwrite(obj.FID,"% Report on models referenced by model being reported."+newline);
                fprintf(obj.FID,"rptMRO.IncludeReferencedModels = true;"+newline+newline);
            else
                fwrite(obj.FID,"% Do not report on models referenced by model being reported."+newline);
                fprintf(obj.FID,"rptMRO.IncludeReferencedModels = false;"+newline+newline);
            end

            if options.IncludeAllVariants
                fwrite(obj.FID,"% Report on variants of subsystems included in model."+newline);
                fprintf(obj.FID,"rptMRO.IncludeVariants = true;"+newline+newline);
            else
                fwrite(obj.FID,"% Do not report on variants of subsystems included in model."+newline);
                fprintf(obj.FID,"rptMRO.IncludeVariants = false;"+newline+newline);
            end

        end

        function writeModelList(obj,options)
            import slreportgen.rpt2api.rptgen_sl_csl_mdl_loop
            import mlreportgen.rpt2api.exprstr.Parser

            writeModelReportOptions(obj,options);

            switch options.MdlName
            case '$current'
                fwrite(obj.FID,"% $current: Report model containing currently selected system."+newline);
                fwrite(obj.FID,"rptCurrOptionsModelList = {bdroot(gcs)};"+newline+newline);
            case '$all'
                fwrite(obj.FID,"% $all: Report on all open systems"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelList = find_system( ..."+newline);
                fwrite(obj.FID,"SearchDepth=0, ..."+newline);
                fwrite(obj.FID,"type=""block_diagram"", ..."+newline);
                fwrite(obj.FID,"BlockDiagramType=""model"");"+newline+newline);
            case '$alllib'
                fwrite(obj.FID,"% $alllib: Report all open libraries"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelList = find_system( ..."+newline);
                fwrite(obj.FID,"SearchDepth=0, ..."+newline);
                fwrite(obj.FID,"type=""block_diagram"", ..."+newline);
                fwrite(obj.FID,"BlockDiagramType=""library"");"+newline+newline);
            case '$pwd'
                fwrite(obj.FID,"% Report all models in the current directory($pwd)."+newline);
                fwrite(obj.FID,"rptDirModels = [dir(fullfile(pwd,""*.mdl"")) ; dir(fullfile(pwd,""*.slx""))];"+newline);
                fwrite(obj.FID,"rptN = numel(rptDirModels);"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelList = cell(rptN, 1);"+newline);
                fwrite(obj.FID,"for rptI = 1:rptN"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelList{rptI} = rptDirModels(rptI).name(1:end-4); %strip extension"+newline);
                fwrite(obj.FID,"end"+newline+newline);
            case '$custom'
                fwrite(obj.FID,"% ""$custom"" not a valid model name"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelList = {};"+newline+newline);
            otherwise
                if regexp(options.MdlName,'.*%<.+>')
                    fprintf(obj.FID,'%% Report on models specified by a MATLAB expression: "%s"\n',options.MdlName);
                    Parser.writeExprStr(obj.FID,options.MdlName,'rptCurrOptionsModelList');
                    fwrite(obj.FID,"rptCurrOptionsModelList = textscan(rptCurrOptionsModelList,""%s"",""delimiter"",""\n"");"+newline);
                    fwrite(obj.FID,"rptCurrOptionsModelList = rptCurrOptionsModelList{1};"+newline+newline);
                else
                    if~isempty(options.MdlName)
                        fprintf(obj.FID,"% Report on specified model"+newline);
                        fprintf(obj.FID,'rptCurrOptionsModelList = "%s";\n\n',...
                        options.MdlName);
                    else
                        fwrite(obj.FID,"rptCurrOptionsModelList = {}"+newline+newline);
                    end
                end
            end


            findMdlRefs=str2double(options.ModelReferenceDepth)>0&&~strcmp(options.SysLoopType,"current");
            if findMdlRefs
                fwrite(obj.FID,"% Create options for finding model references"+newline);
                fwrite(obj.FID,"rptMdlRefOptions = {""ReturnTopModelAsLastElement"", false, ..."+newline);
                fwrite(obj.FID,"""FollowLinks"", rptMRO.IncludeUserLibraryLinks, ..."+newline);
                if strcmp(options.isMask,'none')
                    fwrite(obj.FID,"""LookUnderMasks"",""none"", ..."+newline);
                end
                if options.IncludeAllVariants
                    fwrite(obj.FID,"""MatchFilter"", @Simulink.match.codeCompileVariants, ..."+newline);
                else
                    fwrite(obj.FID,"""MatchFilter"", @Simulink.match.activeVariants, ..."+newline);
                end
                fwrite(obj.FID,"};"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelRefList = {};"+newline+newline);
            end

            fwrite(obj.FID,"% Add model group to main model list"+newline);
            fwrite(obj.FID,"rptN = numel(rptCurrOptionsModelList);"+newline);
            fwrite(obj.FID,"for rptI = 1:rptN"+newline);
            fwrite(obj.FID,"rptModelName = rptCurrOptionsModelList{rptI};"+newline);
            fwrite(obj.FID,"% Map model to current options set"+newline);
            fprintf(obj.FID,"rptMROMap%s(rptModelName) = rptMRO;\n",obj.LoopVariableSuffix);
            fwrite(obj.FID,"% Add model to main model list"+newline);
            fprintf(obj.FID,"rptModelList%s{end+1} = rptModelName; %%#ok<SAGROW> \n",obj.LoopVariableSuffix);
            if findMdlRefs
                fwrite(obj.FID,newline+"% Find model references to include in the model list"+newline);

                fwrite(obj.FID,"rptModelLoaded = slreportgen.utils.isModelLoaded(rptModelName);"+newline);
                fwrite(obj.FID,"if ~rptModelLoaded"+newline);
                fwrite(obj.FID,"% Temporarily load model if necessary"+newline);
                fwrite(obj.FID,"load_system(rptModelName);"+newline);
                fwrite(obj.FID,"end"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelRefList = [rptCurrOptionsModelRefList; ..."+newline);
                fwrite(obj.FID,"find_mdlrefs(rptModelName, rptMdlRefOptions{:})]; %#ok<AGROW> "+newline);
                fwrite(obj.FID,"if ~rptModelLoaded"+newline);
                fwrite(obj.FID,"% Unload model"+newline);
                fwrite(obj.FID,"load_system(rptModelName);"+newline);
                fwrite(obj.FID,"end"+newline);
            end
            fwrite(obj.FID,"end"+newline+newline);

            if findMdlRefs
                fwrite(obj.FID,"% Add model references to main model list"+newline);
                fwrite(obj.FID,"rptCurrOptionsModelRefList = unique(rptCurrOptionsModelRefList);"+newline);
                fwrite(obj.FID,"rptN = numel(rptCurrOptionsModelRefList);"+newline);
                fwrite(obj.FID,"for rptI = 1:rptN"+newline);
                fwrite(obj.FID,"rptModelName = rptCurrOptionsModelRefList{rptI};"+newline);
                fwrite(obj.FID,"% Map model to current options set"+newline);
                fwrite(obj.FID,"rptMROMap"+obj.LoopVariableSuffix+"(rptModelName) = rptMRO;"+newline);
                fwrite(obj.FID,"% Add model to main model list"+newline);
                fwrite(obj.FID,"rptModelList"+obj.LoopVariableSuffix+"{end+1} = rptModelName; %#ok<SAGROW>"+newline);
                fwrite(obj.FID,"end"+newline+newline);
            end

        end

        function child=getFirstChildComponent(obj)



            existingValues=find(obj.Component,...
            '-depth',1,...
            '-isa','rptgen_sl.rpt_mdl_loop_options');

            for i=1:length(existingValues)
                disconnect(existingValues(i));
            end
            child=down(obj.Component);
        end

        function name=getVariableName(~)
            name=[];
        end

    end


    methods(Access=protected)

        function writeSectionTitleCode(obj,titleVarName,~)
            fprintf(obj.FID,"rptModelName = get_param(%s.CurrentModelHandle,""Name"");\n",obj.RptStateVariable);
            if obj.Component.ShowTypeInTitle
                fwrite(obj.FID,titleVarName+" = sprintf(""Model - %s"",rptModelName);"+newline);
            else
                fwrite(obj.FID,titleVarName+" = rptModelName;"+newline);
            end
        end


        function writeObjectIdCode(obj,idVarName)
            fprintf(obj.FID,"%s = slreportgen.utils.getObjectID(%s.CurrentModelHandle);\n",idVarName,obj.RptStateVariable);
        end



        function writeLoopEnd(obj)
            fwrite(obj.FID,"% Unload any models loaded during this loop iteration"+newline);
            fwrite(obj.FID,"if isempty(find(rptState.PreRunOpenModels == get_param(rptModelName,""Handle""),1))"+newline);
            fwrite(obj.FID,"close_system(rptModelName);"+newline);
            fwrite(obj.FID,"end"+newline+newline);

            fwrite(obj.FID,"end % model loop"+newline+newline);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end


        function template=getTemplate(templateName)
            import slreportgen.rpt2api.rptgen_sl_csl_mdl_loop
            templateFolder=fullfile(rptgen_sl_csl_mdl_loop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,strcat(templateName,'.txt'));
            template=fileread(templatePath);
        end

    end

end

