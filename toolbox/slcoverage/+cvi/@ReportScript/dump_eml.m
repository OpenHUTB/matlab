function dump_eml(this,blkEntry,inReport,options)




    if~hasAnyMetrics(blkEntry)
        return;
    end

    isEmTruthtable=false;
    if cv('get',blkEntry.cvId,'.origin')==2
        sfId=cv('get',blkEntry.cvId,'.handle');
        if sf('Private','is_eml_truth_table_fcn',sfId)
            isEmTruthtable=true;
        end
    end
    codeBlock=cv('get',blkEntry.cvId,'.code');
    lineStart=cv('get',codeBlock,'.lineStartInd');

    if~isfield(blkEntry,'decision')||isempty(blkEntry.decision)
        decIdx=[];
        decInBlockIdx=[];
        decCovered=[];
        decJustified=[];
        decIds=[];
        decLines=[];
    else
        decIdx=blkEntry.decision.decisionIdx;
        decInBlockIdx=blkEntry.decision.inBlockIdx;
        decCovered=logical([this.cvstruct.decisions.covered]);
        decCovered=decCovered(decIdx);
        decJustified=logical([this.cvstruct.decisions.isJustified]);
        decJustified=decJustified(decIdx);
        decIds=[this.cvstruct.decisions.cvId];
        decIds=decIds(decIdx);
        decLines=cv('CodeBloc','objLines',codeBlock,decIds);
    end

    if~isfield(blkEntry,'condition')||isempty(blkEntry.condition)
        condIdx=[];
        condCovered=[];
        condJustified=[];
        condIds=[];
        condLines=[];
        condInBlockIdx=[];
    else
        condIdx=blkEntry.condition.conditionIdx;
        condInBlockIdx=blkEntry.condition.inBlockIdx;
        condCovered=logical([this.cvstruct.conditions.covered]);
        condCovered=condCovered(condIdx);
        condJustified=logical([this.cvstruct.conditions.isJustified]);
        condJustified=condJustified(condIdx);
        condIds=[this.cvstruct.conditions.cvId];
        condIds=condIds(condIdx);
        condLines=cv('CodeBloc','objLines',codeBlock,condIds);
    end

    if~isfield(blkEntry,'mcdc')||isempty(blkEntry.mcdc)
        mcdcIdx=[];
        mcdcInBlockIdx=[];
        mcdcLines=[];
    else
        mcdcIdx=blkEntry.mcdc.mcdcIndex;
        mcdcInBlockIdx=blkEntry.mcdc.inBlockIdx;
        mcdcIds=[this.cvstruct.mcdcentries.cvId];
        mcdcIds=mcdcIds(mcdcIdx);
        mcdcLines=cv('CodeBloc','objLines',codeBlock,mcdcIds);
    end

    allLines=unique([decLines,condLines,mcdcLines]);
    coveredDecisions=decIds(decCovered);
    uncoveredDecisions=decIds(~decCovered);
    allCoveredConditions=condIds(condCovered);
    allJustified=[decIds(decJustified),condIds(condJustified)];
    allUncoveredConditions=[condIds(~(condCovered+condJustified))];

    if this.hasTestobjectiveInfo
        for mIdx=1:numel(this.toMetricNames)
            metricName=this.toMetricNames{mIdx};
            if~isempty(blkEntry.(metricName))
                toData.(metricName)=[];
                toIdx=blkEntry.(metricName).testobjectiveIdx;
                toData.(metricName).inBlockIdx=blkEntry.(metricName).inBlockIdx;
                toData.(metricName).toIdx=toIdx;
                toCovered=logical([this.cvstruct.(metricName).covered]);
                toCovered=toCovered(toIdx);
                toJustified=logical([this.cvstruct.(metricName).isJustified]);
                toJustified=toJustified(toIdx);

                toData.(metricName).toCovered=toCovered;
                toIds=[this.cvstruct.(metricName).cvId];
                toIds=toIds(toIdx);
                toData.(metricName).toIds=toIds;
                toLines=[];
                for idx=1:numel(toIds)
                    toLines=[toLines,cv('CodeBloc','objLines',codeBlock,toIds(idx))];%#ok<AGROW>
                end
                toData.(metricName).toLines=toLines;
                allLines=unique([allLines,toLines]);
                allCoveredConditions=[allCoveredConditions,toIds(toCovered)];%#ok<AGROW>
                allJustified=[allJustified,toIds(toJustified)];%#ok<AGROW>
                allUncoveredConditions=[allUncoveredConditions,toIds(~(toCovered+toJustified))];%#ok<AGROW>
            end
        end

    end



    cv('CodeBloc','refresh',codeBlock);
    if~isempty(decIdx)


        cv('CodeBloc','missingStatementHighlight',codeBlock,this.allTests{this.totalIdx}.metrics.decision);
    end


    fudge_triggered_transition_decision_end_index([coveredDecisions,uncoveredDecisions]);
    cv('CodeBloc','covered',codeBlock,coveredDecisions);
    cv('CodeBloc','uncovered',codeBlock,uncoveredDecisions);
    cv('CodeBloc','covered',codeBlock,allCoveredConditions);
    cv('CodeBloc','uncovered',codeBlock,allUncoveredConditions);
    cv('CodeBloc','justified',codeBlock,allJustified);



    if inReport
        linkTemplate=['#refobj',num2str(blkEntry.cvId),'_%d'];
        cv('set',codeBlock,'.hyperlink.line',allLines,'.hyperlink.sTemplate',linkTemplate);
    end

    if isEmTruthtable
        [tableStr,~,~,processedLines]=cvprivate('truth_table_html_cov',blkEntry.cvId,blkEntry,this.allTests{this.totalIdx},this.cvstruct);
        allLines=setdiff(allLines,processedLines);
        printIt(this,'%s\n',tableStr);
    else
        scriptHtml=cv('CodeBloc','html',codeBlock,1,1,0,0);
        printIt(this,'%s\n',scriptHtml);
    end
    shortSumm=[];
    for idx=1:numel(allLines)
        lineNum=allLines(idx);
        subBlkEntry=blkEntry;
        decFindIdx=decLines==lineNum;
        subBlkEntry.decision.decisionIdx=decIdx(decFindIdx);
        subBlkEntry.decision.inBlockIdx=decInBlockIdx(decFindIdx);
        subBlkEntry.decision.flags.fullCoverage=decCovered(decFindIdx);

        condFindIdx=condLines==lineNum;
        subBlkEntry.condition.conditionIdx=condIdx(condFindIdx);
        subBlkEntry.condition.inBlockIdx=condInBlockIdx(condFindIdx);
        subBlkEntry.condition.flags.fullCoverage=condCovered(condFindIdx);

        mcdcFindIdx=mcdcLines==lineNum;
        subBlkEntry.mcdc.mcdcIndex=mcdcIdx(mcdcFindIdx);
        subBlkEntry.mcdc.inBlockIdx=mcdcInBlockIdx(mcdcFindIdx);

        for mIdx=1:numel(this.toMetricNames)
            metricName=this.toMetricNames{mIdx};
            if~isempty(subBlkEntry.(metricName))
                toFindIdx=toData.(metricName).toLines==lineNum;
                subBlkEntry.(metricName).testobjectiveIdx=toData.(metricName).toIdx(toFindIdx);
                subBlkEntry.(metricName).inBlockIdx=toData.(metricName).inBlockIdx(toFindIdx);
                subBlkEntry.(metricName).flags.fullCoverage=toData.(metricName).toCovered(toFindIdx);
            else
                subBlkEntry.(metricName).testobjectiveIdx=[];
            end
        end

        if lineNum==1
            charStart=0;
        else
            charStart=lineStart(lineNum)+1;
        end

        if(lineNum==length(lineStart))
            script=cv('GetScript',codeBlock);
            charEnd=length(script);
        else
            charEnd=lineStart(lineNum+1);
        end


        lineTxt=['#',num2str(lineNum),': ',cv('CodeBloc','getLine',codeBlock,lineNum)];

        if isEmTruthtable
            map=sf('get',sfId,'state.autogen.mapping');
            ttItem=cvi.ReportUtils.get_script_to_truth_table_map(map,lineNum);
            if~isempty(ttItem)
                title=cvi.ReportScript.object_titleStr_and_link([blkEntry.cvId,ttItem.type,ttItem.index],lineTxt);
            else

                title='';
            end
        else
            if inReport
                title=cvi.ReportScript.object_titleStr_and_link([blkEntry.cvId,charStart,charEnd],lineTxt);
            else
                title=cvi.ReportScript.object_titleStr_and_link([blkEntry.cvId,charStart,charEnd],lineTxt,1,inReport);
            end
        end
        isShortSumm=false;
        if options.elimFullCovDetails
            [isShortSumm,summ,resMetricNames]=isShortSummary(this,subBlkEntry,options);
        end
        oldElimFullCovDetails=options.elimFullCovDetails;
        if options.elimFullCovDetails&&~isShortSumm
            options.elimFullCovDetails=false;
        end
        anchor=cvi.ReportUtils.obj_anchor([blkEntry.cvId,lineNum],'');
        if isShortSumm

            if any(strcmp(resMetricNames,'cvmetric_Structural_block'))

                tinfo.namedlink=this.cvstruct.cvmetric_Structural_block(subBlkEntry.cvmetric_Structural_block.testobjectiveIdx).text;
            else
                tinfo.namedlink=title;
            end


            tinfo.namedlink=[anchor,tinfo.namedlink];

            tinfo.rationale=summ;
            if isempty(shortSumm)
                shortSumm=tinfo;
            else
                shortSumm(end+1)=tinfo;%#ok<AGROW>
            end
        else
            printIt(this,'%s<h4>%s</h4>',...
            anchor,...
            title);

            if~isempty(subBlkEntry.decision.decisionIdx)
                decision_details(this,subBlkEntry,this.cvstruct,options,subBlkEntry.decision.inBlockIdx);
            end

            if~isempty(subBlkEntry.condition.conditionIdx)
                condition_details(this,subBlkEntry,this.cvstruct,options,subBlkEntry.condition.inBlockIdx);
            end

            if~isempty(subBlkEntry.mcdc.mcdcIndex)
                mcdc_details(this,subBlkEntry,this.cvstruct,options,subBlkEntry.mcdc.inBlockIdx);
            end

            for mIdx=1:numel(this.toMetricNames)
                metricName=this.toMetricNames{mIdx};
                if~isempty(subBlkEntry.(metricName).testobjectiveIdx)
                    if strcmp(metricName,'cvmetric_Structural_block')
                        options.alternativeMetricNameIdx=2;
                    end
                    testobjective_details(this,subBlkEntry,this.cvstruct,metricName,options,subBlkEntry.(metricName).inBlockIdx);
                end
            end
            printIt(this,'<br/>\n');
        end
        options.elimFullCovDetails=oldElimFullCovDetails;
    end
    dumpShortSummary(this,shortSumm,options);
end


function res=hasAnyMetrics(blkEntry)
    TOmetricFields={'cvmetric_Structural_saturate','cvmetric_Structural_relationalop','cvmetric_Structural_block'};
    TOindexField='testobjectiveIdx';
    res=checkMetric(blkEntry,{'decision'},'decisionIdx')||...
    checkMetric(blkEntry,{'condition'},'conditionIdx')||...
    checkMetric(blkEntry,TOmetricFields,TOindexField);
end

function res=checkMetric(blkEntry,metricFields,indexField)
    res=false;
    for idx=1:numel(metricFields)
        cm=metricFields{idx};
        if isfield(blkEntry,cm)&&...
            ~isempty(blkEntry.(cm))&&...
            ~isempty(blkEntry.(cm).(indexField))
            res=res||true;
        end
    end
end

function isTriggered=is_triggered_transition(sfId)

    isTriggered=false;
    if(~isempty(sf('get',sfId,'transition.id')))
        ast=Stateflow.Ast.getContainer(idToHandle(sfroot,sfId));
        if(~isempty(ast.conditionSection))
            sec=ast.conditionSection{1};
            if(~isempty(sec.roots{1}))
                isTriggered=isa(sec.roots{1},'Stateflow.Ast.PreProcessedTrigger');
            end
        end
    end
end

function fudge_triggered_transition_decision_end_index(decisionIdArray)



    for i=1:length(decisionIdArray)
        decisionId=decisionIdArray(i);
        sfId=cv('get',cv('get',decisionId,'.slsfobj'),'.handle');
        if(is_triggered_transition(sfId))
            descriptor=cv('get',decisionId,'.descriptor');
            [startChar,len]=cv('get',descriptor,'.startChar','.length');
            labelString=sf('get',sfId,'.labelString');
            if(len>0&&length(labelString)>=(startChar+len)&&labelString(startChar+len)==']')
                cv('set',descriptor,'.length',len+1);
            end
        end
    end
end


