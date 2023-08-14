classdef rptgen_hg_chg_fig_loop<mlreportgen.rpt2api.LoopComponentConverter




























    methods

        function obj=rptgen_hg_chg_fig_loop(component,rptFileConverter)
            init(obj,component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.rptgen_hg_chg_fig_loop

            writeStartBanner(this);
            writeSaveState(this);
            suffix=this.LoopVariableSuffix;
            figuresVarName=rptgen_hg_chg_fig_loop.getListVariableName()+suffix;


            fprintf(this.FID,"rptPreRunCurrentFigure%s = get(0,'CurrentFigure');"+newline,suffix);

            switch upper(this.Component.LoopType)
            case 'ALL'

                if this.Component.isDataFigureOnly
                    fprintf(this.FID,"rptFindTerms = {'HandleVisibility','on'};"+newline);
                else
                    fprintf(this.FID,"rptFindTerms = {};"+newline);
                end

                fprintf(this.FID,"%s = findall(0,'-depth',1, ..."+newline,figuresVarName);
                fprintf(this.FID,"'type','figure', ..."+newline);
                fprintf(this.FID,"'visible','on', ..."+newline);
                fprintf(this.FID,"rptFindTerms{:}, ..."+newline);
                fprintf(this.FID,"'-not',{'tag'},mlreportgen.rpt2api.rptgen_hg_chg_fig_loop.getSafeTags());"+newline+newline);

            case 'CURRENT'
                fprintf(this.FID,"%s = get(0,'CurrentFigure');"+newline+newline,figuresVarName);

            case 'TAG'
                if isempty(this.Component.TagList)
                    fprintf(this.FID,"rptTagTerms={'tag',''};"+newline);
                    fprintf(this.FID,"rptRegexpTerms = {};"+newline);
                else
                    parsedTagList=cellfun(@rptgen.parseExpressionText,this.Component.TagList,'UniformOutput',false);
                    fprintf(this.FID,"rptParsedTagList={"+newline);
                    numParsedTagList=length(parsedTagList);
                    for idx=1:numParsedTagList
                        fprintf(this.FID,"'%s', ..."+newline,parsedTagList{idx});
                    end
                    fprintf(this.FID,"};"+newline);
                    fprintf(this.FID,"rptTagTerms={{'tag'},rptParsedTagList'};"+newline);
                    if this.Component.UseRegexp
                        fprintf(this.FID,"rptRegexpTerms = {'-regexp'};"+newline);
                    else
                        fprintf(this.FID,"rptRegexpTerms = {};"+newline);
                    end
                end

                fprintf(this.FID,"%s = findall(0,'-depth',1, ..."+newline,figuresVarName);
                fprintf(this.FID,"'type','figure', ..."+newline);
                fprintf(this.FID,"rptRegexpTerms{:}, ..."+newline);
                fprintf(this.FID,"rptTagTerms{:}); ..."+newline+newline);

            otherwise
                fprintf(this.FID,"%s = []"+newline+newline,figuresVarName);
            end

            fprintf(this.FID,"%s = sort(%s);\n"+newline+newline,figuresVarName,figuresVarName);

            fwrite(this.FID,"% Loop through list of figures to be reported."+newline);
            fprintf(this.FID,"rptNFigure%s = numel(%s);\n",suffix,figuresVarName);
            fprintf(this.FID,"for rptIFigure%s=1:rptNFigure%s\n",suffix,suffix);
            fprintf(this.FID,"rptState.CurrentFigure = %s(rptIFigure%s);"+newline,figuresVarName,suffix);

            fprintf(this.FID,"set(0, 'CurrentFigure', rptState.CurrentFigure);"+newline);
            writeObjectSectionCode(this);
        end

        function name=getVariableName(~)
            name=[];
        end
    end


    methods(Access=protected)

        function writeSectionTitleCode(obj,titleVarName,~)
            fprintf(obj.FID,"rptFigureName = 'Figure';\n");
            if obj.Component.ShowTypeInTitle
                fwrite(obj.FID,titleVarName+" = sprintf('Figure - %s', rptFigureName);"+newline);
            else
                fwrite(obj.FID,titleVarName+" = rptFigureName;"+newline);
            end
        end


        function writeObjectIdCode(obj,idVarName)
            fprintf(obj.FID,"%s = mlreportgen.report.Figure.getLinkTargetID(%s.CurrentFigure);\n",idVarName,obj.RptStateVariable);
        end


        function writeLoopEnd(obj)
            fwrite(obj.FID,"end % figure loop"+newline+newline);

            fprintf(obj.FID,"set(0, 'CurrentFigure', rptPreRunCurrentFigure%s);"+newline+newline,obj.LoopVariableSuffix);
        end
    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function name=getListVariableName()
            name="rptFigureList";
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_hg_chg_fig_loop
            templateFolder=fullfile(rptgen_hg_chg_fig_loop.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

        function t=getSafeTags(~)




            t={
'Setup File Editor'
'rptlistFigure'
'rptconvert_Figure'
'rptgen_compwiz_Figure'
'RPTGEN_SETFILE_FIGURE'
'RPTGEN_COMPONENT_CLIPBOARD'
'RPTGEN_TEMP_CANVAS'
'RPTGEN_PDF_VIEWER'
'SFCHART'
'DEFAULT_SFCHART'
'SFEXPLR'
'SF_DEBUGGER'
'SF_SAFEHOUSE'
'SF_VIEWER'
'SF_RG_Viewer'
'SIMULINK_XYGRAPH_FIGURE'
'SIMULINK_SIMSCOPE_FIGURE'
'SIMULINK_SLCHANGELOG'
            };
        end
    end
end

