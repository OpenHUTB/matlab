function[allFullCov,covTxt,partialCovSFObjs]=installInformerText(this,blkEntry,cvstruct,metricNames,toMetricNames,options)






















































    tooComplex=0;















    fullCov.shallow.decision=-1;
    fullCov.shallow.condition=-1;
    fullCov.shallow.mcdc=-1;
    fullCov.shallow.tableExec=-1;
    fullCov.deep.decision=-1;
    fullCov.deep.condition=-1;
    fullCov.deep.mcdc=-1;
    fullCov.deep.tableExec=-1;

    metricNames=[metricNames,toMetricNames];

    blkEntry=fixEMLState(blkEntry,metricNames);
    [fullCov,tooComplex]=getDecision(fullCov,tooComplex,blkEntry);
    [fullCov,tooComplex]=getCondition(fullCov,tooComplex,blkEntry);
    [fullCov,tooComplex]=getMCDC(fullCov,tooComplex,blkEntry);
    [fullCov,tooComplex]=getTableExec(fullCov,tooComplex,blkEntry);

    for idx=1:numel(toMetricNames)
        metricName=toMetricNames{idx};
        if isfield(blkEntry,metricName)&&~isempty(blkEntry.(metricName))
            [fullCov,tooComplex]=buildFullCovStruct(fullCov,blkEntry,metricName);
        end
    end


    [hasDeepCoverage,hasShallowCoverage]=checkHasCoverage(fullCov,metricNames);
    [fullDeepCoverage,fullShallowCoverage]=checkFullCoverage(fullCov,metricNames);



    partialCovSFObjs=[];
    if(hasShallowCoverage&&...
        (fullShallowCoverage==0||fullShallowCoverage==1)&&...
        ~isempty(cv('find',blkEntry.cvId,'slsfobj.origin','STATEFLOW_OBJ')))

        objectId=cv('get',blkEntry.cvId,'.handle');
        if((~isempty(sf('get',objectId,'transition.id'))||...
            ~isempty(sf('get',objectId,'state.id'))))
            chartId=sf('get',objectId,'.chart');
            if(sf('get',chartId,'.actionLanguage')~=2)
                partialCovSFObjs.decisionCoverage=fullCov.shallow.decision;
                partialCovSFObjs.sfId=cv('get',blkEntry.cvId,'.handle');
                partialCovSFObjs.coveredConditions={};
                partialCovSFObjs.unCoveredConditions={};
                dataFromOldRelease=false;
                if(isfield(blkEntry,'condition')&&...
                    isfield(blkEntry.condition,'conditionIdx'))
                    for i=1:length(blkEntry.condition.conditionIdx)
                        conditionIdx=blkEntry.condition.conditionIdx(i);
                        condition=cvstruct.conditions(conditionIdx);
                        if(condition.length>0)
                            idx=[condition.startChar,condition.startChar+condition.length-1];
                            if(condition.covered)
                                partialCovSFObjs.coveredConditions{end+1}=idx;
                            else
                                partialCovSFObjs.unCoveredConditions{end+1}=idx;
                            end
                        else
                            dataFromOldRelease=true;
                            break;
                        end
                    end
                end
                if(~dataFromOldRelease)
                    partialCovSFObjs.coveredDecisions={};
                    partialCovSFObjs.unCoveredDecisions={};
                    if(isfield(blkEntry,'decision')&&...
                        isfield(blkEntry.decision,'decisionIdx'))
                        for i=1:length(blkEntry.decision.decisionIdx)
                            decisionIdx=blkEntry.decision.decisionIdx(i);
                            decision=cvstruct.decisions(decisionIdx);
                            if(decision.length>0)
                                idx=[decision.startChar,decision.startChar+decision.length-1];
                                if(decision.covered)
                                    partialCovSFObjs.coveredDecisions{end+1}=idx;
                                else
                                    partialCovSFObjs.unCoveredDecisions{end+1}=idx;
                                end
                            end
                        end
                    end
                else
                    partialCovSFObjs=[];
                end
            end
        end
    end
    [covTxt,allFullCov]=getText(this,cvstruct,...
    fullCov,hasDeepCoverage,hasShallowCoverage,fullShallowCoverage,fullDeepCoverage,...
    tooComplex,blkEntry,toMetricNames,options);



    function[covStr,allFullCov]=getText(this,cvstruct,...
        fullCov,hasDeepCoverage,hasShallowCoverage,fullShallowCoverage,fullDeepCoverage,...
        tooComplex,blkEntry,toMetricNames,options)
        insertBreak='<br>';
        if options.generatWebViewReportData==1

            commandType=2;
        else

            commandType=1;
        end
        covStr='';
        allFullCov=-1;





        if isfield(blkEntry,'mcdc')&&isfield(blkEntry.mcdc,'cascadeRoot')
            if isempty(blkEntry.mcdc.cascadeRoot)
                mcdcData=cvstruct.mcdcentries(blkEntry.mcdc.mcdcIndex);
                if(length(mcdcData)==1)&&(mcdcData.cascMCDC.isCascMCDC)
                    cascBlocks=mcdcData.cascMCDC.memberBlocks;
                    ssidText='';
                    for cascIdx=1:length(cascBlocks)
                        ssid=cvi.TopModelCov.getSID(cascBlocks(cascIdx));
                        ssidText=[ssidText,' ''',ssid,''''];%#ok<AGROW>
                    end
                    covStr=[covStr,insertBreak...
                    ,getString(message('Slvnv:simcoverage:cvmodelview:CascMcdcRoot',numel(cascBlocks)))...
                    ,insertBreak];
                end
            else
                covStr=[covStr,insertBreak...
                ,getString(message('Slvnv:simcoverage:cvmodelview:CascMcdcMember',...
                cvi.ReportScript.object_titleStr_and_link(...
                blkEntry.mcdc.cascadeRoot.cvId,[],commandType,false)))...
                ,insertBreak];
            end
        end

        if(hasShallowCoverage&&(fullShallowCoverage==0||fullShallowCoverage==2))||...
            (hasDeepCoverage&&(fullDeepCoverage==0||fullDeepCoverage==2))




            if cvstruct.sfcnCovRes.covId2InstanceInfo.isKey(blkEntry.cvId)
                tooComplex=true;
            end



            if(hasShallowCoverage&&(fullShallowCoverage==0||fullShallowCoverage==2)&&~tooComplex)
                if(fullCov.shallow.decision~=-1)
                    if(fullCov.shallow.decision==1)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:FullDecisionCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,1);
                    elseif(fullCov.shallow.decision==2)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:JustifiedFullDecisionCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,2);
                    else

                        decData=cvstruct.decisions(blkEntry.decision.decisionIdx);
                        missingDecData='';
                        missingDecData=missingDecision(missingDecData,decData,'',true);
                        if~isempty(missingDecData)
                            covStr=[covStr,insertBreak,missingDecData];
                        end
                        allFullCov=fullCoverageOrLogic(allFullCov,0);
                    end
                end
                if(fullCov.shallow.condition~=-1)
                    if(fullCov.shallow.condition==1)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:FullConditionCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,1);
                    elseif(fullCov.shallow.condition==2)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:JustifiedFullConditionCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,2);
                    else

                        condData=cvstruct.conditions(blkEntry.condition.conditionIdx);
                        missingCondData=missingCondition(condData);
                        if~isempty(missingCondData)
                            covStr=[covStr,insertBreak,missingCondData];
                        end
                        allFullCov=fullCoverageOrLogic(allFullCov,0);
                    end
                end
                if(fullCov.shallow.mcdc~=-1)
                    if(fullCov.shallow.mcdc==1)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:FullMcdcCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,1);
                    elseif(fullCov.shallow.mcdc==2)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:JustifiedFullMcdcCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,2);
                    else
                        mcdcData=cvstruct.mcdcentries(blkEntry.mcdc.mcdcIndex);
                        missingMCDCdata=missingMCDC(mcdcData);
                        if~isempty(missingMCDCdata)
                            covStr=[covStr,insertBreak,missingMCDCdata];
                        end
                        allFullCov=fullCoverageOrLogic(allFullCov,0);
                    end
                end
                if(fullCov.shallow.tableExec~=-1)
                    if(fullCov.shallow.tableExec==1)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:FullTableCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,1);
                    elseif(fullCov.shallow.tableExec==2)
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:JustifiedFullTableCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,2);
                    else
                        covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:MissingTableCoverage'))];
                        allFullCov=fullCoverageOrLogic(allFullCov,0);
                    end
                end

                for idx=1:numel(toMetricNames)
                    metricName=toMetricNames{idx};
                    if~isempty(blkEntry.(metricName))&&(fullCov.shallow.(metricName)~=-1)
                        metricTxt=cvi.MetricRegistry.getLongMetricTxt(metricName,options);
                        if(fullCov.shallow.(metricName)==1)
                            covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:FullTOCoverage',metricTxt))];%#ok<AGROW>
                            allFullCov=fullCoverageOrLogic(allFullCov,1);
                        elseif(fullCov.shallow.(metricName)==2)
                            covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:JustifiedFullTOCoverage',metricTxt))];%#ok<AGROW>
                            allFullCov=fullCoverageOrLogic(allFullCov,2);
                        else
                            data=cvstruct.(metricName)(blkEntry.(metricName).testobjectiveIdx);
                            missingTestObjectivesData=missingTestobjectives(data,metricName);
                            if~isempty(missingTestObjectivesData)
                                covStr=[covStr,insertBreak,missingTestObjectivesData];%#ok<AGROW>
                            end
                            allFullCov=fullCoverageOrLogic(allFullCov,0);
                        end
                    end
                end
            end

            if(tooComplex||(hasDeepCoverage&&(fullDeepCoverage==0||fullDeepCoverage==2)))


                if hasDeepCoverage&&(fullDeepCoverage==2)
                    allFullCov=fullCoverageOrLogic(allFullCov,2);
                    covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:JustifiedFullCoverage'))];
                else
                    allFullCov=fullCoverageOrLogic(allFullCov,0);
                    covStr=[covStr,coverage_summary(blkEntry,fullCov,toMetricNames)];
                end
            end

            if allFullCov==2&&...
                cv('get',blkEntry.cvId,'.isJustified')
                rationale=cvi.ReportUtils.getFilterRationale(blkEntry.cvId);
                rationale=cvi.ReportUtils.str_to_html(rationale);
                covStr=[covStr,insertBreak,'<b>',getString(message('Slvnv:simcoverage:cvmodelview:JustificationRationale')),'</b> ',rationale];
            end

        else

            covStr=[covStr,insertBreak,getString(message('Slvnv:simcoverage:cvmodelview:FullCoverage'))];
            allFullCov=1;

        end



        function[fullCov,tooComplex]=getDecision(fullCov,tooComplex,blkEntry)


            if(isfield(blkEntry,'decision')&&~isempty(blkEntry.decision)&&isfield(blkEntry.decision,'decisionIdx'))
                if isfield(blkEntry.decision,'outlocalCnts')

                    if~isempty(blkEntry.decision.outlocalCnts)
                        if(((blkEntry.decision.outlocalCnts(end)+blkEntry.decision.justifiedOutlocalCnts(end))~=...
                            blkEntry.decision.totalLocalCnts))
                            fullCov.shallow.decision=0;


                            if length(blkEntry.decision.decisionIdx)>3
                                tooComplex=1;
                            end
                        else
                            if blkEntry.decision.justifiedOutlocalCnts(end)>0
                                fullCov.shallow.decision=2;
                            else
                                fullCov.shallow.decision=1;
                            end
                        end
                    end


                    if((blkEntry.decision.outTotalCnts(end)+blkEntry.decision.justifiedOutTotalCnts(end))...
                        ==blkEntry.decision.totalTotalCnts)

                        if blkEntry.decision.justifiedOutTotalCnts(end)>0
                            fullCov.deep.decision=2;
                        else
                            fullCov.deep.decision=1;
                        end
                    else
                        fullCov.deep.decision=0;
                    end
                else

                    if((blkEntry.decision.outHitCnts(end)+blkEntry.decision.justifiedOutHitCnts(end))...
                        ~=blkEntry.decision.totalCnts)
                        fullCov.shallow.decision=0;



                        if length(blkEntry.decision.decisionIdx)>3
                            tooComplex=1;
                        end
                    else
                        if blkEntry.decision.justifiedOutHitCnts(end)>0
                            fullCov.shallow.decision=2;
                        else
                            fullCov.shallow.decision=1;
                        end

                    end
                end
            end

            function[fullCov,tooComplex]=getCondition(fullCov,tooComplex,blkEntry)


                if(isfield(blkEntry,'condition')&&isfield(blkEntry.condition,'conditionIdx'))
                    if(~isempty(blkEntry.condition.conditionIdx))
                        if(blkEntry.condition.localHits(end)+blkEntry.condition.justifiedLocalHits(end)...
                            ==blkEntry.condition.localCnt)
                            if blkEntry.condition.justifiedLocalHits(end)>0
                                fullCov.shallow.condition=2;
                            else
                                fullCov.shallow.condition=1;
                            end
                        else
                            fullCov.shallow.condition=0;


                            if length(blkEntry.condition.conditionIdx)>10
                                tooComplex=1;
                            end
                        end
                    end

                    if isfield(blkEntry.condition,'totalHits')

                        if(blkEntry.condition.totalHits(end)+blkEntry.condition.justifiedTotalHits(end)...
                            ==blkEntry.condition.totalCnt)
                            if blkEntry.condition.justifiedTotalHits(end)>0
                                fullCov.deep.condition=2;
                            else
                                fullCov.deep.condition=1;
                            end
                        else
                            fullCov.deep.condition=0;
                        end
                    else


                    end
                end

                function[fullCov,tooComplex]=getMCDC(fullCov,tooComplex,blkEntry)


                    if(isfield(blkEntry,'mcdc')&&~isempty(blkEntry.mcdc))&&...
                        (~isfield(blkEntry.mcdc,'cascadeRoot')||isempty(blkEntry.mcdc.cascadeRoot))

                        if~isempty(blkEntry.mcdc.localHits)
                            if(blkEntry.mcdc.localHits(end)+blkEntry.mcdc.justifiedLocalHits(end)...
                                ==blkEntry.mcdc.localCnt)
                                if blkEntry.mcdc.justifiedLocalHits(end)>0
                                    fullCov.shallow.mcdc=2;
                                else
                                    fullCov.shallow.mcdc=1;
                                end
                            else
                                fullCov.shallow.mcdc=0;
                            end
                        end
                        if isfield(blkEntry.mcdc,'totalHits')

                            if(blkEntry.mcdc.totalHits(end)+blkEntry.mcdc.justifiedTotalHits(end)...
                                ==blkEntry.mcdc.totalCnt)
                                if blkEntry.mcdc.justifiedTotalHits(end)>0
                                    fullCov.deep.mcdc=2;
                                else
                                    fullCov.deep.mcdc=1;
                                end
                            else
                                fullCov.deep.mcdc=0;
                            end
                        else


                        end
                    end


                    function[fullCov,tooComplex]=getTableExec(fullCov,tooComplex,blkEntry)


                        if(isfield(blkEntry,'tableExec')&&~isempty(blkEntry.tableExec))

                            if(isfield(blkEntry.tableExec,'totalHits'))

                                if(blkEntry.tableExec.totalHits(end)+blkEntry.tableExec.justifiedTotalHits(end)...
                                    ==blkEntry.tableExec.totalCnt)
                                    if blkEntry.tableExec.justifiedTotalHits(end)>0
                                        fullCov.shallow.tableExec=2;
                                    else
                                        fullCov.shallow.tableExec=1;
                                    end

                                else
                                    fullCov.shallow.tableExec=0;
                                end
                            end
                        end




                        function blkEntry=fixEMLState(blkEntry,metricNames)

                            if~isEMLState(blkEntry)
                                return;
                            end
                            for idx=1:numel(metricNames)
                                metricName=metricNames{idx};
                                if isfield(blkEntry,metricName)&&~isempty(blkEntry.(metricName))&&...
                                    isfield(blkEntry.(metricName),'outHitCnts')

                                    blkEntry.(metricName).outTotalCnts=blkEntry.(metricName).outHitCnts;
                                    blkEntry.(metricName).justifiedOutTotalCnts=blkEntry.(metricName).justifiedOutHitCnts;

                                    blkEntry.(metricName).totalTotalCnts=blkEntry.(metricName).totalCnts;
                                    blkEntry.(metricName).outlocalCnts=[];
                                    blkEntry.(metricName).justifiedOutlocalCnts=[];
                                    blkEntry.(metricName).totalLocalCnts=0;
                                    blkEntry.(metricName).outHitCnts;
                                    blkEntry.(metricName)=rmfield(blkEntry.(metricName),'outHitCnts');
                                    blkEntry.(metricName)=rmfield(blkEntry.(metricName),'totalCnts');
                                end
                            end


                            function res=isEMLState(blkEntry)
                                cvId=blkEntry.cvId;
                                res=false;
                                if cv('get',cvId,'.origin')==2
                                    sfid=cv('get',cvId,'.handle');
                                    r=sfroot;
                                    if isa(r.idToHandle(sfid),'Stateflow.EMFunction')
                                        res=true;
                                    end
                                end


                                function res=fullCoverageOrLogic(c1,c2)
                                    res=-1;
                                    if c1~=-1||c2~=-1
                                        if c1==0||c2==0
                                            res=0;
                                        elseif c1==2||c2==2
                                            res=2;
                                        else
                                            res=1;
                                        end

                                    end

                                    function[fullDeepCoverage,fullShallowCoverage]=checkFullCoverage(fullCov,metricNames)


                                        fullDeepCoverage=-1;
                                        fullShallowCoverage=-1;
                                        for idx=1:numel(metricNames)
                                            metricName=metricNames{idx};
                                            if isfield(fullCov.deep,metricName)
                                                fullDeepCoverage=fullCoverageOrLogic(fullDeepCoverage,fullCov.deep.(metricName));
                                            end
                                        end

                                        for idx=1:numel(metricNames)
                                            metricName=metricNames{idx};
                                            if isfield(fullCov.shallow,metricName)
                                                fullShallowCoverage=fullCoverageOrLogic(fullShallowCoverage,fullCov.shallow.(metricName));
                                            end
                                        end


                                        function[hasDeepCoverage,hasShallowCoverage]=checkHasCoverage(fullCov,metricNames)
                                            hasDeepCoverage=0;
                                            hasShallowCoverage=0;

                                            for idx=1:numel(metricNames)
                                                metricName=metricNames{idx};
                                                if isfield(fullCov.deep,metricName)
                                                    hasDeepCoverage=(fullCov.deep.(metricName)~=-1);
                                                    if hasDeepCoverage
                                                        break;
                                                    end
                                                end
                                            end

                                            for idx=1:numel(metricNames)
                                                metricName=metricNames{idx};
                                                if isfield(fullCov.shallow,metricName)
                                                    hasShallowCoverage=(fullCov.shallow.(metricName)~=-1);
                                                    if(hasShallowCoverage)
                                                        break;
                                                    end
                                                end
                                            end


                                            function[fullCov,tooComplex]=buildFullCovStruct(fullCov,blkEntry,metricName)
                                                tooComplex=0;
                                                fullCov.shallow.(metricName)=-1;
                                                fullCov.deep.(metricName)=-1;

                                                if isfield(blkEntry.(metricName),'outlocalCnts')

                                                    if~isempty(blkEntry.(metricName).outlocalCnts)
                                                        if(blkEntry.(metricName).outlocalCnts(end)+blkEntry.(metricName).justifiedOutlocalCnts(end)...
                                                            ~=blkEntry.(metricName).totalLocalCnts)
                                                            fullCov.shallow.(metricName)=0;


                                                            if length(blkEntry.(metricName).testobjectiveIdx)>3
                                                                tooComplex=1;
                                                            end
                                                        else
                                                            if blkEntry.(metricName).justifiedOutlocalCnts(end)>0
                                                                fullCov.shallow.(metricName)=2;
                                                            else
                                                                fullCov.shallow.(metricName)=1;
                                                            end
                                                        end
                                                    end


                                                    if(blkEntry.(metricName).outTotalCnts(end)+blkEntry.(metricName).justifiedOutTotalCnts(end)...
                                                        ==blkEntry.(metricName).totalTotalCnts)
                                                        if blkEntry.(metricName).justifiedOutTotalCnts(end)>0
                                                            fullCov.deep.(metricName)=2;
                                                        else
                                                            fullCov.deep.(metricName)=1;
                                                        end
                                                    else
                                                        fullCov.deep.(metricName)=0;
                                                    end
                                                else


                                                    if(blkEntry.(metricName).outHitCnts(end)+blkEntry.(metricName).justifiedOutHitCnts(end)...
                                                        ~=blkEntry.(metricName).totalCnts)
                                                        fullCov.shallow.(metricName)=0;
                                                    else
                                                        if blkEntry.(metricName).justifiedOutHitCnts(end)>0
                                                            fullCov.shallow.(metricName)=2;
                                                        else
                                                            fullCov.shallow.(metricName)=1;
                                                        end
                                                    end
                                                end



                                                function str=coverage_summary(blkEntry,fullCov,toMetricNames)

                                                    row=1;
                                                    col=1;
                                                    strTable=[];
                                                    if fullCov.shallow.decision~=-1||fullCov.deep.decision~=-1
                                                        justifiedHit=0;
                                                        if isfield(blkEntry.decision,'outTotalCnts')
                                                            if~isempty(blkEntry.decision.justifiedOutTotalCnts)
                                                                justifiedHit=blkEntry.decision.justifiedOutTotalCnts(end);
                                                            end
                                                            hit=blkEntry.decision.outTotalCnts(end);
                                                            count=blkEntry.decision.totalTotalCnts;
                                                        else
                                                            if~isempty(blkEntry.decision.justifiedOutHitCnts)
                                                                justifiedHit=blkEntry.decision.justifiedOutHitCnts(end);
                                                            end
                                                            hit=blkEntry.decision.outHitCnts(end);
                                                            count=blkEntry.decision.totalCnts;
                                                        end
                                                        mn=getString(message('Slvnv:simcoverage:cvmodelview:Decision'));
                                                        if justifiedHit>0
                                                            strTable{row,col}=sprintf('%s %2.0f%% ((%d+%d)/%d)',mn,...
                                                            100*(hit+justifiedHit)/count,hit,justifiedHit,count);
                                                        else
                                                            strTable{row,col}=sprintf('%s %2.0f%% (%d/%d)',mn,100*hit/count,hit,count);
                                                        end
                                                        [row,col]=next_cell(row,col);
                                                    end

                                                    if fullCov.shallow.condition~=-1||fullCov.deep.condition~=-1
                                                        if isfield(blkEntry.condition,'totalHits')
                                                            if~isempty(blkEntry.condition.justifiedTotalHits)
                                                                justifiedHit=blkEntry.condition.justifiedTotalHits(end);
                                                            end

                                                            hit=blkEntry.condition.totalHits(end);
                                                            count=blkEntry.condition.totalCnt;
                                                        else
                                                            if~isempty(blkEntry.condition.justifiedLocalHits)
                                                                justifiedHit=blkEntry.condition.justifiedLocalHits(end);
                                                            end

                                                            hit=blkEntry.condition.localHits(end);
                                                            count=blkEntry.condition.localCnt;
                                                        end
                                                        mn=getString(message('Slvnv:simcoverage:cvmodelview:Condition'));
                                                        if justifiedHit>0
                                                            strTable{row,col}=sprintf('%s %2.0f%% ((%d+%d)/%d)',mn,...
                                                            100*(hit+justifiedHit)/count,hit,justifiedHit,count);
                                                        else
                                                            strTable{row,col}=sprintf('%s %2.0f%% (%d/%d)',mn,100*hit/count,hit,count);
                                                        end
                                                        [row,col]=next_cell(row,col);
                                                    end

                                                    if fullCov.shallow.mcdc~=-1||fullCov.deep.mcdc~=-1
                                                        if isfield(blkEntry.mcdc,'totalHits')
                                                            if~isempty(blkEntry.mcdc.justifiedTotalHits)
                                                                justifiedHit=blkEntry.mcdc.justifiedTotalHits(end);
                                                            end

                                                            hit=blkEntry.mcdc.totalHits(end);
                                                            count=blkEntry.mcdc.totalCnt;
                                                        else
                                                            if~isempty(blkEntry.mcdc.justifiedLocalHits)
                                                                justifiedHit=blkEntry.mcdc.justifiedLocalHits(end);
                                                            end

                                                            hit=blkEntry.mcdc.localHits(end);
                                                            count=blkEntry.mcdc.localCnt;
                                                        end
                                                        mn=getString(message('Slvnv:simcoverage:cvmodelview:MCDC'));
                                                        if justifiedHit>0
                                                            strTable{row,col}=sprintf('%s %2.0f%% ((%d+%d)/%d)',mn,...
                                                            100*(hit+justifiedHit)/count,hit,justifiedHit,count);
                                                        else
                                                            strTable{row,col}=sprintf('%s  %2.0f%% (%d/%d)',mn,100*hit/count,hit,count);
                                                        end
                                                        [row,col]=next_cell(row,col);
                                                    end

                                                    [strTable,row,col]=buildStrTable(row,col,strTable,blkEntry,fullCov,toMetricNames);

                                                    if col==1
                                                        rowCnt=row-1;
                                                    else
                                                        rowCnt=row;
                                                        strTable{row,col}=' ';
                                                    end

                                                    if(row==1&&col==1)
                                                        str='';
                                                        return;
                                                    end

                                                    tableInfo.table='  CELLPADDING="2" CELLSPACING="1"';
                                                    tableInfo.cols=struct('align','"left"');

                                                    template={{'ForN',rowCnt,...
                                                    {'ForN',2,...
                                                    {'#.','@2','@1'},...
                                                    },...
'\n'...
                                                    }};

                                                    str=cvprivate('html_table',strTable,template,tableInfo);



                                                    function[strTable,row,col]=buildStrTable(row,col,strTable,blkEntry,fullCov,toMetricNames)
                                                        for idx=1:numel(toMetricNames)
                                                            metricName=toMetricNames{idx};
                                                            if~isfield(fullCov.shallow,metricName)
                                                                continue;
                                                            end
                                                            if fullCov.shallow.(metricName)~=-1||fullCov.deep.(metricName)~=-1
                                                                justifiedHit=0;
                                                                if isfield(blkEntry.(metricName),'outTotalCnts')
                                                                    if~isempty(blkEntry.(metricName).justifiedOutTotalCnts)
                                                                        justifiedHit=blkEntry.(metricName).justifiedOutTotalCnts(end);
                                                                    end
                                                                    hit=blkEntry.(metricName).outTotalCnts(end);
                                                                    count=blkEntry.(metricName).totalTotalCnts;
                                                                else
                                                                    if~isfield(blkEntry.(metricName),'outlocalCnts')
                                                                        continue;
                                                                    end
                                                                    if~isempty(blkEntry.(metricName).justifiedOutlocalCnts)
                                                                        justifiedHit=blkEntry.(metricName).justifiedOutlocalCnts(end);
                                                                    end

                                                                    hit=blkEntry.(metricName).outlocalCnts(end);
                                                                    count=blkEntry.(metricName).totalLocalCnts;
                                                                end
                                                                mn=cvi.MetricRegistry.getShortMetricTxt(metricName,[]);
                                                                if justifiedHit>0
                                                                    strTable{row,col}=sprintf('%s %2.0f%% ((%d+%d)/%d)',mn,...
                                                                    100*(hit+justifiedHit)/count,hit,justifiedHit,count);
                                                                else
                                                                    strTable{row,col}=sprintf('%s %2.0f%% (%d/%d)',mn,100*hit/count,hit,count);
                                                                end
                                                                [row,col]=next_cell(row,col);
                                                            end
                                                        end


                                                        function[row,col]=next_cell(row,col)
                                                            if col==2
                                                                col=1;
                                                                row=row+1;
                                                            else
                                                                col=2;
                                                            end


                                                            function htmlStr=out_i(decId,index)
                                                                htmlStr=cvi.ReportUtils.getTextOf(decId,index-1,[],1);

                                                                function htmlStr=decision_str(decId)
                                                                    htmlStr=cvi.ReportUtils.getTextOf(decId,-1,[],1);

                                                                    function htmlStr=condition_str(condId)
                                                                        htmlStr=cvi.ReportUtils.getTextOf(condId,-1,[],1);

                                                                        function htmlStr=testobj_str(cvId)%#ok
                                                                            htmlStr=cvi.ReportUtils.getTextOf(cvId,-1,[],2);

                                                                            function str=missingTO(data,metricTxt)

                                                                                decText='';
                                                                                missingOutTxt={};
                                                                                allMissing=true;
                                                                                for i=1:length(data)
                                                                                    if(data(i).hitTrueCount==0)
                                                                                        missingOutTxt=[missingOutTxt,data(i).text];%#ok<AGROW>
                                                                                        if data(i).showOnlyTrueOutcome&&data(i).execCount~=0
                                                                                            allMissing=false;
                                                                                        end
                                                                                    else
                                                                                        allMissing=false;
                                                                                    end
                                                                                end
                                                                                str='';
                                                                                str=missingDecOutcomes(str,allMissing,decText,metricTxt,missingOutTxt);


                                                                                function str=missingTestobjectives(data,metricName)
                                                                                    str='';
                                                                                    if isempty(data)
                                                                                        return;
                                                                                    end
                                                                                    showDecTxt=true;

                                                                                    if strcmpi(metricName,'cvmetric_Structural_saturate')&&...
                                                                                        cv('get',cv('get',data(1).cvId,'.slsf'),'.origin')==1
                                                                                        showDecTxt=false;
                                                                                    end
                                                                                    if strcmpi(metricName,'cvmetric_Structural_block')&&...
                                                                                        data(1).outcome.execCount==0
                                                                                        str=[getString(message('Slvnv:simcoverage:cvmodelview:NeverExecuted')),' '];
                                                                                    end

                                                                                    metricTxt=cvi.MetricRegistry.getLongMetricTxt(metricName,[]);

                                                                                    if data(1).showOnlyTrueOutcome
                                                                                        str=[str,missingTO(data,metricTxt)];
                                                                                    else
                                                                                        str=missingDecision(str,data,metricTxt,showDecTxt);
                                                                                    end

                                                                                    function str=missingDecision(str,data,metricTxt,showDecTxt)
                                                                                        outputStr='';
                                                                                        for i=1:length(data)
                                                                                            missingOutTxt={};
                                                                                            decId=data(i).cvId;
                                                                                            allMissing=1;
                                                                                            if~data(i).isActive
                                                                                                continue;
                                                                                            end
                                                                                            for j=1:numel(data(i).outcome)
                                                                                                if(data(i).outcome(j).execCount(end)==0)&&...
                                                                                                    (data(i).outcome(j).isJustified==0)
                                                                                                    missingOutTxt=[missingOutTxt,out_i(decId,j)];%#ok<AGROW>
                                                                                                else
                                                                                                    allMissing=0;
                                                                                                end
                                                                                            end
                                                                                            decText='';
                                                                                            if showDecTxt
                                                                                                decText=decision_str(decId);

                                                                                            end
                                                                                            outputStr=missingDecOutcomes(outputStr,allMissing,metricTxt,decText,missingOutTxt);
                                                                                        end
                                                                                        str=[str,outputStr];
                                                                                        if~isempty(outputStr)
                                                                                            str=[str,' '];
                                                                                        end


                                                                                        function str=missingDecOutcomes(str,allMissing,metricTxt,decText,missingOutTxt)
                                                                                            outputStr='';
                                                                                            if~isempty(missingOutTxt)
                                                                                                if allMissing
                                                                                                    outputStr=getString(message('Slvnv:simcoverage:cvmodelview:DecisionNeverEvaluated',metricTxt,decText));
                                                                                                else
                                                                                                    switch(length(missingOutTxt))
                                                                                                    case 1
                                                                                                        switch lower(missingOutTxt{1})
                                                                                                        case 'true'
                                                                                                            outputStr=getString(message('Slvnv:simcoverage:cvmodelview:DecisionWasNeverTrue',metricTxt,decText));
                                                                                                        case 'false'
                                                                                                            outputStr=getString(message('Slvnv:simcoverage:cvmodelview:DecisionWasNeverFalse',metricTxt,decText));
                                                                                                        otherwise
                                                                                                            outputStr=getString(message('Slvnv:simcoverage:cvmodelview:DecisionWasNeverSingle',metricTxt,decText,missingOutTxt{1}));
                                                                                                        end
                                                                                                    case 2
                                                                                                        outputStr=getString(message('Slvnv:simcoverage:cvmodelview:DecisionWasNeverMultiple',metricTxt,decText,missingOutTxt{1},missingOutTxt{2}));
                                                                                                    otherwise
                                                                                                        objectives='';
                                                                                                        for j=1:numel(missingOutTxt)-1
                                                                                                            objectives=[objectives,missingOutTxt{j},', '];%#ok<AGROW>
                                                                                                        end
                                                                                                        objectives=strtrim(objectives);
                                                                                                        outputStr=getString(message('Slvnv:simcoverage:cvmodelview:DecisionWasNeverMultiple',metricTxt,decText,objectives,missingOutTxt{end}));
                                                                                                    end
                                                                                                end
                                                                                            end
                                                                                            str=[str,outputStr];
                                                                                            if~isempty(outputStr)
                                                                                                str=[str,' '];
                                                                                            end



                                                                                            function str=missingCondition(data)
                                                                                                notTrue=[];
                                                                                                notFalse=[];
                                                                                                notTrueFalse=[];
                                                                                                str='';

                                                                                                for i=1:length(data)
                                                                                                    cd=data(i);
                                                                                                    if cd.isActive
                                                                                                        if(cd.trueCnts(end)==0)&&(cd.isJustifiedTrue==0)
                                                                                                            if(cd.falseCnts(end)==0)&&(cd.isJustifiedFalse==0)
                                                                                                                notTrueFalse=[notTrueFalse,i];%#ok<AGROW>
                                                                                                            else
                                                                                                                notTrue=[notTrue,i];%#ok<AGROW>
                                                                                                            end
                                                                                                        else
                                                                                                            if(cd.falseCnts(end)==0)&&(cd.isJustifiedFalse==0)
                                                                                                                notFalse=[notFalse,i];%#ok<AGROW>
                                                                                                            end
                                                                                                        end
                                                                                                    else
                                                                                                        str=[str,getString(message('Slvnv:simcoverage:cvmodelview:ConditionIsFiltered',condition_str(data(i).cvId)))];%#ok<AGROW>
                                                                                                    end
                                                                                                end

                                                                                                str=missingConditionStr(str,data,notTrue,'notTrue');
                                                                                                str=missingConditionStr(str,data,notFalse,'notFalse');
                                                                                                str=missingConditionStr(str,data,notTrueFalse,'notTrueFalse');



                                                                                                function str=missingConditionStr(str,condData,idx,type)

                                                                                                    outputStr='';
                                                                                                    if~isempty(idx)
                                                                                                        switch length(idx)
                                                                                                        case 1
                                                                                                            switch type
                                                                                                            case 'notTrue'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionWasNeverTrue',condition_str(condData(idx).cvId)));
                                                                                                            case 'notFalse'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionWasNeverFalse',condition_str(condData(idx).cvId)));
                                                                                                            case 'notTrueFalse'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionWasNeverEvaluated',condition_str(condData(idx).cvId)));
                                                                                                            end

                                                                                                        case 2
                                                                                                            switch type
                                                                                                            case 'notTrue'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionsWereNeverTrue',condition_str(condData(idx(1)).cvId),condition_str(condData(idx(2)).cvId)));
                                                                                                            case 'notFalse'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionsWereNeverFalse',condition_str(condData(idx(1)).cvId),condition_str(condData(idx(2)).cvId)));
                                                                                                            case 'notTrueFalse'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionsWereNeverEvaluated',condition_str(condData(idx(1)).cvId),condition_str(condData(idx(2)).cvId)));
                                                                                                            end


                                                                                                        otherwise
                                                                                                            objectives='';
                                                                                                            for objIdx=1:(length(idx)-1)
                                                                                                                objectives=[objectives,condition_str(condData(idx(objIdx)).cvId),', '];%#ok<AGROW>
                                                                                                            end
                                                                                                            objectives=strtrim(objectives);
                                                                                                            switch type
                                                                                                            case 'notTrue'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionsWereNeverTrue',objectives,condition_str(condData(idx(end)).cvId)));
                                                                                                            case 'notFalse'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionsWereNeverFalse',objectives,condition_str(condData(idx(end)).cvId)));
                                                                                                            case 'notTrueFalse'
                                                                                                                outputStr=getString(message('Slvnv:simcoverage:cvmodelview:ConditionsWereNeverEvaluated',objectives,condition_str(condData(idx(end)).cvId)));
                                                                                                            end

                                                                                                        end
                                                                                                        str=[str,outputStr];
                                                                                                        if~isempty(outputStr)
                                                                                                            str=[str,' '];
                                                                                                        end

                                                                                                    end



                                                                                                    function str=missingMCDC(data)

                                                                                                        if length(data)==1
                                                                                                            index=1;
                                                                                                            missingIdx=missingMCDCIdx(data,index);
                                                                                                            str=missingMCDCStr(data,index,missingIdx);
                                                                                                        else
                                                                                                            str='';
                                                                                                            for i=1:length(data)
                                                                                                                if data(i).isActive
                                                                                                                    missingIdx=missingMCDCIdx(data,i);
                                                                                                                    if~isempty(missingIdx)
                                                                                                                        str=[str,missingMCDCStr(data,i,missingIdx)];%#ok<AGROW>
                                                                                                                    end
                                                                                                                else
                                                                                                                    str=[str,getString(message('Slvnv:simcoverage:cvmodelview:MCDCIsFiltered',data(i).text))];%#ok<AGROW>
                                                                                                                end
                                                                                                            end
                                                                                                        end




                                                                                                        function missingIdx=missingMCDCIdx(mcdcData,index)

                                                                                                            numPreds=mcdcData(index).numPreds;
                                                                                                            missingIdx=[];
                                                                                                            for i=1:numPreds
                                                                                                                if mcdcData(index).predicate(i).isActive&&...
                                                                                                                    ~mcdcData(index).predicate(i).achieved(end)
                                                                                                                    missingIdx=[missingIdx,i];%#ok<AGROW>
                                                                                                                end
                                                                                                            end


                                                                                                            function mcdcStr=missingMCDCStr(mcdcData,index,missingIdx)

                                                                                                                switch length(missingIdx)
                                                                                                                case 0
                                                                                                                    mcdcStr='';
                                                                                                                case 1
                                                                                                                    mcdcStr=[getString(message('Slvnv:simcoverage:cvmodelview:ConditionHasNotDemonstratedMCDC',mcdcData(index).predicate(missingIdx).text)),' '];
                                                                                                                case 2
                                                                                                                    if(length(mcdcData)==1)
                                                                                                                        mcdcStr=[getString(message('Slvnv:simcoverage:cvmodelview:ConditionsHaveNotDemonstratedMCDC1',mcdcData(index).predicate(missingIdx(1)).text,mcdcData(index).predicate(missingIdx(2)).text)),' '];
                                                                                                                    else
                                                                                                                        mcdcStr=[getString(message('Slvnv:simcoverage:cvmodelview:ConditionsHaveNotDemonstratedMCDC2',mcdcData(index).predicate(missingIdx(1)).text,mcdcData(index).predicate(missingIdx(2)).text,mcdcData(index).text)),' '];
                                                                                                                    end
                                                                                                                otherwise
                                                                                                                    objectives='';
                                                                                                                    for objIdx=1:(length(missingIdx)-1)
                                                                                                                        objectives=[objectives,mcdcData(index).predicate(missingIdx(objIdx)).text,', '];%#ok<AGROW>
                                                                                                                    end
                                                                                                                    objectives=strtrim(objectives);
                                                                                                                    if(length(mcdcData)==1)
                                                                                                                        mcdcStr=[getString(message('Slvnv:simcoverage:cvmodelview:ConditionsHaveNotDemonstratedMCDC1',objectives,mcdcData(index).predicate(missingIdx(end)).text)),' '];
                                                                                                                    else
                                                                                                                        mcdcStr=[getString(message('Slvnv:simcoverage:cvmodelview:ConditionsHaveNotDemonstratedMCDC2',objectives,mcdcData(index).predicate(missingIdx(end)).text,mcdcData(index).text)),' '];
                                                                                                                    end
                                                                                                                end




                                                                                                                function out=bold(in)
                                                                                                                    out=sprintf('<B>%s</B>',in);
