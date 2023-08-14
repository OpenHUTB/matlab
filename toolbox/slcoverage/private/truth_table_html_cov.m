function[htmlTxt,condTable,actTable,processedLines]=truth_table_html_cov(cvStateId,ttEntry,covdata,cvstruct)




    persistent ccEnum dcEnum;

    if isempty(dcEnum)
        dcEnum=cvi.MetricRegistry.getEnum('decision');
        ccEnum=cvi.MetricRegistry.getEnum('condition');
    end




    processedLines=[];

    stateId=cv('get',cvStateId,'.handle');
    condData=covdata.metrics.condition;
    decData=covdata.metrics.decision;

    [condTable,actTable]=get_string_tables(stateId);

    if isempty(decData)

        htmlTxt='';
        return;
    end

    [rowCnt,colCnt]=size(condTable);
    cvIdMap=zeros(rowCnt,colCnt);
    isEmTruthTable=sf('Private','is_eml_truth_table_fcn',stateId);

    if isEmTruthTable

        map=sf('get',stateId,'state.autogen.mapping');
        codeBlock=cv('get',cvStateId,'.code');

        if codeBlock>0&&~isempty(map)
            if isfield(ttEntry,'decision')&&~isempty(ttEntry.decision)
                decIdx=ttEntry.decision.decisionIdx;
                decIds=[cvstruct.decisions.cvId];
                decIds=decIds(decIdx);
                decLines=cv('CodeBloc','objLines',codeBlock,decIds);
            else
                decIds=[];
                decLines=[];
            end

            if isfield(ttEntry,'condition')&&~isempty(ttEntry.condition)
                condIdx=ttEntry.condition.conditionIdx;
                condIds=[cvstruct.conditions.cvId];
                condIds=condIds(condIdx);
                condLines=cv('CodeBloc','objLines',codeBlock,condIds);
            else
                condIds=[];
                condLines=[];
            end

            for i=1:length(decLines)
                ttItem=get_script_to_truth_table_map(map,decLines(i));

                if isempty(ttItem)


                    processedLines=[processedLines,decLines(i)];%#ok
                elseif ttItem.type==2

                    colIdx=2+ttItem.index;
                    cvIdMap(end,colIdx)=decIds(i);

                    if~isempty(condData)&&~isempty(condIds)
                        lineCondIds=condIds(condLines==decLines(i));
                        cvIdMap=fill_condition_id_map(cvIdMap,condTable,lineCondIds,decIds(i),colIdx);
                    end

                    processedLines=[processedLines,decLines(i)];%#ok
                end
            end

            actRegions=get_script_action_regions(map);
            numAct=size(actRegions,1);
            for i=1:numAct
                actHtml=cv('CodeBloc','html',codeBlock,0,1,actRegions(i,2),actRegions(i,3));
                actTable{actRegions(i,1),2}=actHtml;
            end
        end
    else


        transVect=sf('TransitionsOf',stateId);
        transCvIds=cv('DecendentsOf',cvStateId);
        cvSfIdList=cv('get',transCvIds,'.handle');
        [sortedTransIdx,sfIntIdx,cvIntIdx]=intersect(transVect,cvSfIdList);

        for idx=1:length(sortedTransIdx)
            transId=transVect(sfIntIdx(idx));
            transCvId=transCvIds(cvIntIdx(idx));

            if transCvId>0
                decId=cv('MetricGet',transCvId,dcEnum,'.baseObjs');
                transMap=sf('get',transId,'.autogen.mapping');

                if~isempty(transMap)&&~isempty(decId)
                    decId=decId(1);
                    colIdx=transMap.index+2;
                    cvIdMap(end,colIdx)=decId;

                    if~isempty(condData)
                        conditions=cv('MetricGet',transCvId,ccEnum,'.baseObjs');
                        cvIdMap=fill_condition_id_map(cvIdMap,condTable,conditions,decId,colIdx);
                    end
                end
            end
        end
    end

    condTable=append_table_coverage_info(condTable,cvIdMap,decData,condData);

    if isEmTruthTable
        htmlTxt=construct_html_truth_table(condTable,actTable);
    else

        htmlTxt=construct_html_truth_table(condTable,[]);
    end

    return;


    function[condTable,actTable]=get_string_tables(stateId)

        condTable=sf('get',stateId,'state.truthTable.predicateArray');
        if~isempty(condTable)
            condTable=replace_html_reserved_chars(condTable);
        end

        actTable=sf('get',stateId,'state.truthTable.actionArray');
        if~isempty(actTable)
            actTable=replace_html_reserved_chars(actTable);

            tokens=regexp(actTable(:,2),'^\s*([a-zA-Z]\w*)\s*:(?!=)\s*(.*)','tokens','once');
            numAct=size(actTable,1);
            for i=1:numAct
                if~isempty(tokens{i})
                    actTable{i,1}=sprintf('<b>%d</b> [%s]<br/>%s',i,tokens{i}{1},actTable{i,1});
                    actTable{i,2}=tokens{i}{2};
                else
                    actTable{i,1}=sprintf('<b>%d</b><br/>%s',i,actTable{i,1});
                end
            end
        end

        return;


        function strTable=replace_html_reserved_chars(strTable)


            strTable=cvi.ReportUtils.str_to_html(strTable);
            strTable=strrep(strTable,newline,'<br/>');
            [nr,nc]=size(strTable);
            for idxr=1:nr
                for idxc=1:nc
                    if isempty(strTable{idxr,idxc})
                        strTable{idxr,idxc}='&#160;';
                    end
                end
            end
            return;


            function truthtable=append_table_coverage_info(truthtable,cvIdMap,decData,condData)

                [rowCnt,colCnt]=size(truthtable);
                aDecision=cv('get','default','decision.isa');
                aCondition=cv('get','default','condition.isa');

                for r=1:rowCnt
                    for c=3:colCnt
                        cvId=cvIdMap(r,c);
                        if cvId>0
                            switch cv('get',cvId,'.isa')
                            case aDecision


                                decIdx=cv('get',cvId,'.dc.baseIdx')+1;
                                falseCnt=decData(decIdx);
                                trueCnt=decData(decIdx+1);
                                truthtable{r,c}=append_coverage_string(truthtable{r,c},trueCnt,falseCnt);
                            case aCondition


                                [trueCountIdx,falseCountIdx]=cv('get',cvId,...
                                '.coverage.trueCountIdx','.coverage.falseCountIdx');
                                trueCnt=condData(trueCountIdx+1);
                                falseCnt=condData(falseCountIdx+1);
                                truthtable{r,c}=append_coverage_string(truthtable{r,c},trueCnt,falseCnt);
                            end
                        end
                    end
                end

                return;


                function str=append_coverage_string(str,trueCnt,falseCnt)

                    if trueCnt==0||falseCnt==0
                        cvStr='<br/>(<b><font color="red">';
                        if trueCnt==0
                            cvStr=[cvStr,'T'];
                        end
                        if falseCnt==0
                            cvStr=[cvStr,'F'];
                        end
                        cvStr=[cvStr,'</font></b>)'];
                    else
                        cvStr=['<br/>(<b><font color="green">',getString(message('Slvnv:simcoverage:private:Ok')),'</font></b>)'];
                    end


                    str=[str,cvStr];
                    return;


                    function htmlTxt=consruct_html_table(table)

                        [rowCnt,colCnt]=size(table);

                        tableInfo.table='border="1" cellpadding="10" ';
                        tableInfo.cols(1:2)=struct('align','"left"');
                        tableInfo.cols(3)=struct('align','"center"');

                        template={{'ForN',rowCnt,...
                        {'ForN',colCnt,...
                        {'#.','@2','@1'},...
                        },...
'\n'...
                        }};



                        htmlTxt=html_table(table,template,tableInfo);

                        return;


                        function htmlTxt=construct_html_truth_table(condTable,actTable)

                            htmlTxt='';

                            if~isempty(condTable)
                                htmlTxt=['<table> <tr> <td width="25"> </td> <td>',10,10...
                                ,'<br/> &#160; <b> ',getString(message('Slvnv:simcoverage:private:ConditionTableAnalysisMissingValues')),' </b> <br/>',10...
                                ,consruct_html_table(condTable),10...
                                ,'</td> </tr> </table>',10...
                                ,'<br/>',10];
                            end

                            if~isempty(actTable)
                                htmlTxt=[htmlTxt...
                                ,'<table> <tr> <td width="25"> </td> <td>',10,10...
                                ,'<br/> &#160; <b> ',getString(message('Slvnv:simcoverage:private:ActionTableAnalysisMissingValues')),' </b> <br/>',10...
                                ,consruct_html_table(actTable),10...
                                ,'</td> </tr> </table>',10...
                                ,'<br/>',10];
                            end

                            return;


                            function cvIdMap=fill_condition_id_map(cvIdMap,truthtable,condIds,decId,colIdx)




                                predIdx=1;
                                conditionCnt=size(cvIdMap,1)-1;
                                numConds=length(condIds);

                                for rowIdx=1:conditionCnt
                                    thisCell=truthtable{rowIdx,colIdx};

                                    if~isempty(thisCell)&&~strcmp(thisCell,'-')
                                        if isempty(condIds)
                                            if predIdx>1
                                                error(message('Slvnv:simcoverage:truth_table_html_cov:PoorCondition'));
                                            else

                                                cvIdMap(rowIdx,colIdx)=decId;
                                            end
                                        else
                                            if predIdx>numConds
                                                error(message('Slvnv:simcoverage:truth_table_html_cov:MissingData'));
                                            else
                                                cvIdMap(rowIdx,colIdx)=condIds(predIdx);
                                            end
                                        end

                                        predIdx=predIdx+1;
                                    end
                                end

                                if numConds>0&&predIdx~=numConds+1
                                    error(message('Slvnv:simcoverage:truth_table_html_cov:IncorrectConditionNumber'));
                                end

                                return;


                                function item=get_script_to_truth_table_map(map,line)

                                    len=size(map,1);
                                    sectionIdx=0;
                                    item=[];

                                    for i=1:len
                                        startLineNo=map{i,1};
                                        if line>=startLineNo
                                            sectionIdx=sectionIdx+1;
                                        else
                                            break;
                                        end
                                    end

                                    if sectionIdx>0
                                        item=map{sectionIdx,2};
                                    end

                                    return;


                                    function actRegions=get_script_action_regions(map)

                                        actRegions=zeros(0,3);

                                        numItems=size(map,1)-1;
                                        for i=1:numItems
                                            startLine=map{i,1};
                                            endLine=map{i+1,1}-1;

                                            mapping=map{i,2};
                                            if~isempty(mapping)&&mapping.type==1
                                                actRow=mapping.index;
                                                actRegions(actRow,:)=[actRow,startLine,endLine];
                                            end
                                        end

                                        return;

