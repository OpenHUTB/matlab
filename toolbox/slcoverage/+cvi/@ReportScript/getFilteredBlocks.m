



function info=getFilteredBlocks(this,options,topSlsf,includeDescendants)
    try
        isLinked=~isfield(this,'callFromCvmodelview');
        allIds=cv('DecendentsOf',topSlsf);
        info=[];
        disabledBlocks=cv('find',allIds,'.isDisabled',1);
        info=collectBlocksLinks(this,options,info,0,disabledBlocks,allIds,includeDescendants,isLinked,true);
        if SlCov.CoverageAPI.feature('sldvfilter')
            justifieddBlocks=cv('find',allIds,'.isJustified',1);
            info=collectBlocksLinks(this,options,info,1,justifieddBlocks,allIds,includeDescendants,isLinked,true);
        end
    catch MEx
        rethrow(MEx);
    end

    function[info,found]=findFilteredMetrics(this,options,info,cvid,isLinked)
        mn={'condition','decision'};
        found=false;


        isSFcn=isSFcnCvId(this,cvid);


        if isSFcn

            if~this.cvstruct.sfcnCovRes.covId2InstanceInfo.isKey(cvid)
                return
            end
            sfcnInstInfo=this.cvstruct.sfcnCovRes.covId2InstanceInfo(cvid);
            sfcnRes=this.cvstruct.sfcnCovRes.allResults{1}(sfcnInstInfo.name);
            instanceIdx=sfcnInstInfo.instanceIdx;

            if~cv('get',cvid,'.isDisabled')
                fieldName={'file','function'};
                for j=1:numel(fieldName)
                    [~,text,rat]=getSFunCodeFilterOrJustifInfo(sfcnRes,instanceIdx,cvid,fieldName{j},[],true);
                    if~isempty(text)
                        for ii=1:numel(text)
                            namedlink=getString(message('Slvnv:simcoverage:filterEditor:InTxt',text{ii},cvi.ReportScript.object_titleStr_and_link(cvid,[],false,isLinked)));
                            info=addInfo(this,options,info,0,namedlink,cvid,cvid,rat{ii},'',false,[],[],'');
                        end
                        found=true;
                        return
                    end
                end
            end
        end

        for j=1:numel(mn)
            metricEnum=cvi.MetricRegistry.getEnum(mn{j});
            objs=cv('MetricGet',cvid,metricEnum,'.baseObjs');
            if~isempty(objs)
                disbObjs=cv('find',objs,'.isDisabled',1);
                if~isempty(disbObjs)
                    if isSFcn
                        covPts=getSFcnCoveragePoints(sfcnRes,mn{j});
                        assert(numel(covPts)==numel(objs));
                    end

                    text='';
                    sep='';
                    for k=1:numel(disbObjs)
                        if isSFcn
                            objIdx=find(disbObjs(k)==objs,1);
                            [~,subText]=getSFunCodeFilterOrJustifInfo(sfcnRes,instanceIdx,cvid,mn{j},covPts(objIdx),true);
                            if isempty(subText)
                                continue
                            end
                        else
                            subText=cvi.ReportUtils.getTextOf(disbObjs(k),-1,[],2);
                        end
                        text=sprintf('%s%s%s',text,sep,subText);
                        sep=' and ';

                        namedlink=getString(message('Slvnv:simcoverage:filterEditor:InTxt',text,cvi.ReportScript.object_titleStr_and_link(cvid,[],false,isLinked)));
                        [rat,uuid]=cvi.ReportUtils.getFilterRationale(disbObjs(k));
                        found=true;
                    end
                    if found
                        if isLinked
                            rat=cvi.ReportUtils.str_to_html(rat);
                        end
                        info=addInfo(this,options,info,0,namedlink,cvid,disbObjs,rat,uuid,false,[],[],'');
                    end
                end
            end
        end


        function[info,found]=findJustifiedMetrics(this,options,info,cvid,isLinked,linkRationale)
            found=false;
            if cv('get',cvid,'.isJustified')
                return
            end
            mn=SlCov.FilterEditor.getSupportedMetricNames;

            isSFcn=isSFcnCvId(this,cvid);


            if isSFcn

                if~this.cvstruct.sfcnCovRes.covId2InstanceInfo.isKey(cvid)
                    return
                end
                sfcnInstInfo=this.cvstruct.sfcnCovRes.covId2InstanceInfo(cvid);
                sfcnRes=this.cvstruct.sfcnCovRes.allResults{1}(sfcnInstInfo.name);
                instanceIdx=sfcnInstInfo.instanceIdx;

                fieldName={'file','function'};
                for j=1:numel(fieldName)
                    [codeLinkInfo,text,rat]=getSFunCodeFilterOrJustifInfo(sfcnRes,instanceIdx,cvid,fieldName{j},[],false);
                    if~isempty(codeLinkInfo)
                        for ii=1:numel(codeLinkInfo)
                            namedlink=getString(message('Slvnv:simcoverage:filterEditor:InTxt',text{ii},cvi.ReportScript.object_titleStr_and_link(cvid,[],false,isLinked)));
                            info=addInfo(this,options,info,1,namedlink,cvid,cvid,rat{ii},'',linkRationale,[],[],'',codeLinkInfo{ii});
                        end
                        found=true;
                        return
                    end
                end
            end

            allMetricNames=[this.metricNames,this.toMetricNames];
            if isempty(allMetricNames)
                return;
            end
            for j=1:numel(mn)
                metricName=mn{j};
                if isLinked&&~any(contains(allMetricNames,metricName))
                    continue;
                end
                metricEnum=cvi.MetricRegistry.getEnum(metricName);
                objs=cv('MetricGet',cvid,metricEnum,'.baseObjs');
                numOfObjs=numel(objs);

                if isSFcn
                    covPts=getSFcnCoveragePoints(sfcnRes,metricName);
                    assert(numel(covPts)==numel(objs));
                end

                for objIdx=1:numOfObjs
                    co=objs(objIdx);
                    if cv('get',co,'.isJustified')
                        if isSFcn
                            [codeLinkInfo,text]=getSFunCodeFilterOrJustifInfo(sfcnRes,instanceIdx,cvid,mn{j},covPts(objIdx),false);
                            if isempty(codeLinkInfo)
                                continue
                            end
                        else
                            text=cvi.ReportUtils.getTextOf(co,-1,[],2);
                            codeLinkInfo='[]';
                        end
                        namedlink=getString(message('Slvnv:simcoverage:filterEditor:InTxt',text,cvi.ReportScript.object_titleStr_and_link(cvid,[],false,isLinked)));
                        [rat,uuid]=cvi.ReportUtils.getFilterRationale(co);
                        if isLinked
                            rat=cvi.ReportUtils.str_to_html(rat);
                        end
                        info=addInfo(this,options,info,1,namedlink,cvid,co,rat,uuid,linkRationale,objIdx,[],metricName,codeLinkInfo);
                        found=true;
                    else
                        fo=cv('get',co,'.filteredOutcomes');
                        if~isempty(fo)
                            [rats,uuids]=cvi.ReportUtils.getFilterRationale(co,true);
                            if isempty(rats)
                                rats=repmat({''},1,numel(fo));
                            end
                            if isempty(uuids)
                                uuids=repmat({''},1,numel(fo));
                            end

                            for k=1:numel(fo)
                                if checkMetricOutcomeCovered(this,co,metricName,fo(k))
                                    continue;
                                end
                                if isSFcn
                                    [codeLinkInfo,text]=getSFunCodeFilterOrJustifInfo(sfcnRes,instanceIdx,cvid,metricName,covPts(objIdx),false,fo(k));
                                    namedlink=getString(message('Slvnv:simcoverage:filterEditor:InTxt',text,cvi.ReportScript.object_titleStr_and_link(cvid,[],false,isLinked)));
                                else
                                    namedlink=SlCov.FilterEditor.getMetricFilterValueDescr(metricName,co,fo(k),isLinked);
                                    codeLinkInfo='[]';
                                end
                                if isLinked
                                    rats{k}=cvi.ReportUtils.str_to_html(rats{k});
                                end
                                info=addInfo(this,options,info,1,namedlink,cvid,co,rats{k},uuids{k},linkRationale,objIdx,fo(k),metricName,codeLinkInfo);
                                found=true;
                            end
                        end
                    end
                end
            end

            function res=checkMetricOutcomeCovered(this,cvId,metricName,outcomeIdx)
                res=false;
                if isempty(this)||~isfield(this.cvstruct,metricName)
                    return;
                end
                allS=this.cvstruct.(metricName);
                for idx=1:numel(allS)
                    if allS(idx).cvId==cvId

                        res=outcomeIdx>numel(allS(idx).outcome)||...
                        allS(idx).outcome(outcomeIdx).execCount>0;
                        return;
                    end
                end


                function info=addInfo(this,options,info,mode,namedlink,cvId,metricCvIds,rationale,uuid,linkRationale,objectiveIdx,outcomeIdx,metricName,codeLinkInfo)

                    if nargin<14||isempty(codeLinkInfo)
                        codeLinkInfo='[]';
                    end

                    [isInternal,rationale]=cvi.ReportUtils.checkInternalRationale(rationale);
                    if isInternal

                        return;
                    end
                    tinfo.namedlink=namedlink;

                    tinfo.cvId=cvId;
                    tinfo.metricCvIds=metricCvIds;
                    tinfo.refIdStr='';
                    tinfo.idx='%s';
                    tinfo.mode=mode;
                    tinfo.uuid=uuid;

                    tinfo.isInternal=isInternal;

                    if isempty(rationale)
                        rationale='none';
                    end
                    if linkRationale&&~isempty(this)

                        if isempty(objectiveIdx)
                            objectiveIdxStr='[]';
                        else
                            objectiveIdxStr=num2str(objectiveIdx);
                        end

                        if isempty(outcomeIdx)
                            outcomeIdxStr='[]';
                        else
                            outcomeIdxStr=num2str(outcomeIdx);
                        end

                        if~isempty(metricCvIds)
                            tinfo.refIdStr=sprintf('%d_%d_%s',cvId,metricCvIds,outcomeIdxStr);
                        else
                            tinfo.refIdStr=num2str(cvId);
                        end

                        ssid=getSIDFromCvIdSafe(cvId);



                        if~isfield(this,'callFromCvmodelview')&&~isInternal

                            fileNames=join({this.appliedFilters.fileName},',');
                            filterFileName=fileNames{1};
                            [ctxId,reportViewCmd]=options.getFilterCtxId();
                            cvd=this.allTests{1};
                            cvdId=cvd.id;

                            rationale=sprintf('<a href="matlab: cvi.FilterExplorer.FilterExplorer.reportRuleCallback(''%s'', ''%s'', %d, ''%s'',  ''%s'', ''%s'', ''showRule'', ''%s'', %s, %s, %s, ''%s'', []);"><div title="%s"/>%s</a>',...
                            ctxId,...
                            uuid,...
                            cvdId,...
                            reportViewCmd,...
                            options.topModelName,...
                            filterFileName,...
                            ssid,...
                            codeLinkInfo,...
                            objectiveIdxStr,...
                            outcomeIdxStr,...
                            metricName,...
                            getString(message('Slvnv:simcoverage:cvhtml:ShowRuleInEditor')),...
                            rationale);
                        end
                    end

                    tinfo.rationale=rationale;
                    if isempty(info)
                        info=tinfo;
                    else
                        info(end+1)=tinfo;
                    end



                    function[info,disabledBlocks]=collectBlocksLinks(this,options,info,mode,disabledBlocks,allIds,includeDescendants,isLinked,linkRationale)
                        containerIds=cv('find',disabledBlocks,'.allChildrenFiltered',1);
                        if~includeDescendants
                            for idx=1:numel(containerIds)
                                disabledBlocks=setdiff(disabledBlocks,cv('DecendentsOf',containerIds(idx)));
                            end
                        end
                        for idx=1:numel(disabledBlocks)
                            cvId=disabledBlocks(idx);
                            found=false;
                            if mode==1
                                info=findJustifiedMetrics(this,options,info,cvId,isLinked,linkRationale);
                            else
                                [info,found]=findFilteredMetrics(this,options,info,cvId,isLinked);
                            end


                            if~found
                                namedlink=cvi.ReportScript.object_titleStr_and_link(cvId,[],false,isLinked);
                                if~isempty(namedlink)
                                    [rat,uuid]=cvi.ReportUtils.getFilterRationale(cvId);
                                    if isLinked
                                        rat=cvi.ReportUtils.str_to_html(rat);
                                    end
                                    info=addInfo(this,options,info,mode,namedlink,cvId,'',rat,uuid,linkRationale,[],[],'');
                                end
                            end
                        end
                        if isempty(disabledBlocks)
                            ids=allIds;
                        else
                            ids=setdiff(allIds,disabledBlocks);
                        end
                        for idx=1:numel(ids)
                            cvId=ids(idx);
                            if mode==1
                                info=findJustifiedMetrics(this,options,info,cvId,isLinked,linkRationale);
                            else
                                info=findFilteredMetrics(this,options,info,cvId,isLinked);
                            end
                        end


                        function[codeLinkInfo,text,rat]=getSFunCodeFilterOrJustifInfo(sfcnRes,instanceIdx,cvId,metricName,covPt,isFilter,outcomeIdx)

                            if nargin<7
                                outcomeIdx=0;
                            end


                            codeLinkInfo=[];
                            text='';
                            rat='';

                            res=sfcnRes.getInstanceResults(instanceIdx);

                            if isempty(covPt)

                                if metricName=="file"

                                    files=sfcnRes.CodeTr.getFilesInResults();
                                    rat=cell(numel(files),1);
                                    text=cell(numel(files),1);
                                    idx=false(size(files));
                                    for ii=1:numel(files)
                                        file=files(ii);
                                        filterDef=res.getEffectiveFilter(file);
                                        if isempty(filterDef)
                                            idx(ii)=true;
                                            continue
                                        end

                                        if isFilter
                                            isMatch=(filterDef.mode==internal.codecov.FilterMode.EXCLUDED);
                                        else
                                            isMatch=(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                                        end

                                        if isMatch

                                            rat{ii}=filterDef.filterRationale;
                                            text{ii}=getString(message('Slvnv:simcoverage:cvhtml:SFcnExcludedOrJustifiedFile',...
                                            file.shortPath));
                                        else
                                            idx(ii)=true;
                                        end
                                    end
                                    files(idx)=[];
                                    rat(idx)=[];
                                    text(idx)=[];

                                    if~isFilter&&~isempty(files)

                                        ssid=getSIDFromCvIdSafe(cvId);
                                        codeLinkInfo=cell(numel(files),1);
                                        for ii=1:numel(files)
                                            file=files(ii);
                                            codeLinkInfo{ii}=sprintf('struct(''ssid'', ''%s'', ''codeCovInfo'', {{''%s''}})',...
                                            ssid,file.shortPath);
                                        end
                                    end
                                else
                                    functions=sfcnRes.CodeTr.getFunctions();
                                    rat=cell(numel(functions),1);
                                    text=cell(numel(functions),1);
                                    idx=false(size(functions));
                                    for ii=1:numel(functions)
                                        fcn=functions(ii);
                                        filterDef=res.getEffectiveFilter(fcn);
                                        if isempty(filterDef)
                                            idx(ii)=true;
                                            continue
                                        end

                                        if isFilter
                                            isMatch=(filterDef.mode==internal.codecov.FilterMode.EXCLUDED);
                                        else
                                            isMatch=(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                                        end

                                        if isMatch

                                            fileFilterDef=res.getEffectiveFilter(fcn.location.file);
                                            if~isempty(fileFilterDef)
                                                idx(ii)=true;
                                                continue
                                            end


                                            rat{ii}=filterDef.filterRationale;
                                            text{ii}=getString(message('Slvnv:simcoverage:cvhtml:SFcnExcludedOrJustifiedFun',...
                                            fcn.name));
                                        else
                                            idx(ii)=true;
                                        end
                                    end
                                    functions(idx)=[];
                                    rat(idx)=[];
                                    text(idx)=[];


                                    if~isempty(functions)
                                        ssid=getSIDFromCvIdSafe(cvId);
                                        codeLinkInfo=cell(numel(functions),1);
                                        for ii=1:numel(functions)
                                            fcn=functions(ii);
                                            codeLinkInfo{ii}=sprintf('struct(''ssid'', ''%s'', ''codeCovInfo'', {{''%s'', ''%s''}})',...
                                            ssid,fcn.location.file.shortPath,fcn.name);
                                        end
                                    end
                                end
                            else



                                if isempty(outcomeIdx)
                                    if metricName=="condition"&&~isempty(covPt.parentDecision)
                                        return
                                    end
                                end


                                fcn=covPt.node.function;
                                file=fcn.location.file;


                                fileFilterDef=res.getEffectiveFilter(file);
                                fcnFilterDef=res.getEffectiveFilter(fcn);
                                if~isempty(fileFilterDef)||~isempty(fcnFilterDef)
                                    return
                                end


                                exprIdx=[];
                                extraIdx=[];
                                sourceCode='';
                                if metricName=="decision"
                                    cvMetricType=1;
                                    exprIdx=find(sfcnRes.CodeTr.getDecisionPoints(fcn)==covPt);
                                    sourceCode=covPt.node.getSourceCode();
                                    if isempty(outcomeIdx)
                                        text=getString(message('Slvnv:simcoverage:cvhtml:SFcnExcludedOrJustifiedExpr',...
                                        genHTMLSourceElement(sourceCode)));
                                    else
                                        numOutcomes=covPt.outcomes.Size();
                                        text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterDecOutcome',...
                                        getDecOutcomeStr(outcomeIdx,numOutcomes),genHTMLSourceElement(sourceCode)));
                                    end
                                elseif metricName=="condition"
                                    cvMetricType=0;
                                    if isempty(covPt.parentDecision)

                                        exprIdx=find(sfcnRes.CodeTr.getStandaloneConditionPoints(fcn)==covPt);
                                        sourceCode=covPt.node.getSourceCode();
                                        if isempty(outcomeIdx)
                                            text=getString(message('Slvnv:simcoverage:cvhtml:SFcnExcludedOrJustifiedExpr',...
                                            genHTMLSourceElement(sourceCode)));
                                        else
                                            text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterCondOutcome',...
                                            getCondOutcomeStr(outcomeIdx),genHTMLSourceElement(sourceCode)));
                                        end
                                    elseif~isempty(outcomeIdx)

                                        exprIdx=find(covPt.parentDecision.subConditions.toArray()==covPt);
                                        extraIdx=find(sfcnRes.CodeTr.getDecisionPoints(fcn)==covPt.parentDecision);
                                        sourceCode=covPt.parentDecision.node.getSourceCode();
                                        text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterDecCondOutcome',...
                                        getCondOutcomeStr(outcomeIdx),covPt.node.getSourceCode(),genHTMLSourceElement(sourceCode)));
                                    end
                                elseif metricName=="cvmetric_Structural_relationalop"
                                    cvMetricType=3;
                                    if isa(covPt.parentDecisionOrCondition,'internal.cxxfe.instrum.ConditionPoint')

                                        condCovPt=covPt.parentDecisionOrCondition;
                                        if isempty(condCovPt.parentDecision)

                                            exprIdx=find(sfcnRes.CodeTr.getStandaloneConditionPoints(fcn)==condCovPt);
                                            sourceCode=condCovPt.node.getSourceCode();
                                            text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterCondRelopOutcome',...
                                            getRelopOutcomeStr(outcomeIdx,covPt.outcomes.Size()==2),genHTMLSourceElement(sourceCode)));
                                        elseif~isempty(outcomeIdx)

                                            extraIdx=find(condCovPt.parentDecision.subConditions.toArray()==condCovPt);
                                            exprIdx=find(sfcnRes.CodeTr.getDecisionPoints(fcn)==condCovPt.parentDecision);
                                            sourceCode=condCovPt.parentDecision.node.getSourceCode();
                                            text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterDecCondRelopOutcome',...
                                            getRelopOutcomeStr(outcomeIdx,covPt.outcomes.Size()==2),extraIdx,genHTMLSourceElement(sourceCode)));
                                        end
                                    else

                                        decCovPt=covPt.parentDecisionOrCondition;
                                        exprIdx=find(sfcnRes.CodeTr.getDecisionPoints(fcn)==decCovPt);
                                        sourceCode=decCovPt.node.getSourceCode();
                                        text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterDecRelopOutcome',...
                                        getRelopOutcomeStr(outcomeIdx,covPt.outcomes.Size()==2),genHTMLSourceElement(sourceCode)));
                                    end
                                elseif metricName=="mcdc"
                                    cvMetricType=2;
                                    decCovPt=covPt.parentDecision;
                                    exprIdx=find(sfcnRes.CodeTr.getDecisionPoints(fcn)==decCovPt);
                                    sourceCode=decCovPt.node.getSourceCode();
                                    text=getString(message('Slvnv:simcoverage:cvhtml:CodeFilterMCDCCondOutcome',...
                                    outcomeIdx,genHTMLSourceElement(sourceCode)));
                                else
                                    return
                                end


                                ssid=getSIDFromCvIdSafe(cvId);
                                codeLinkInfo=sprintf('struct(''ssid'', ''%s'', ''codeCovInfo'', {{''%s'', ''%s'', ''%s'', %s, %d}})',...
                                ssid,...
                                file.shortPath,...
                                fcn.name,...
                                sourceCode,...
                                mat2str([exprIdx,outcomeIdx,extraIdx]),...
                                cvMetricType);
                            end


                            function isSFcn=isSFcnCvId(this,cvid)
                                isSFcn=false;
                                if~isfield(this,'callFromCvmodelview')
                                    isSFcn=isfield(this.cvstruct,'sfcnCovRes')&&...
                                    isfield(this.cvstruct.sfcnCovRes,'covId2InstanceInfo')&&...
                                    isa(this.cvstruct.sfcnCovRes.covId2InstanceInfo,'containers.Map')&&...
                                    this.cvstruct.sfcnCovRes.covId2InstanceInfo.isKey(cvid);
                                end

                                function covPts=getSFcnCoveragePoints(sfcnRes,metricName)
                                    switch metricName
                                    case 'decision'
                                        covPts=sfcnRes.CodeTr.getDecisionPoints(sfcnRes.CodeTr.Root);
                                    case 'condition'
                                        covPts=sfcnRes.CodeTr.getConditionPoints(sfcnRes.CodeTr.Root);
                                    case 'mcdc'
                                        covPts=sfcnRes.CodeTr.getMCDCPoints(sfcnRes.CodeTr.Root);
                                    case 'cvmetric_Structural_relationalop'
                                        covPts=sfcnRes.CodeTr.getRelationalBoundaryPoints(sfcnRes.CodeTr.Root);
                                    otherwise
                                        covPts=[];
                                    end

                                    function ssid=getSIDFromCvIdSafe(cvId)
                                        ssid='';
                                        try
                                            ssid=cvi.TopModelCov.getSID(cvId);
                                        catch
                                        end


                                        function str=getRelopOutcomeStr(outcomeIdx,isFloat)
                                            if isFloat
                                                if outcomeIdx==1
                                                    str='LT';
                                                else
                                                    str='GT';
                                                end
                                            else
                                                if outcomeIdx==1
                                                    str='LT';
                                                elseif outcomeIdx==2
                                                    str='EQ';
                                                else
                                                    str='GT';
                                                end
                                            end


                                            function str=getCondOutcomeStr(outcomeIdx)
                                                if outcomeIdx==1
                                                    str='T';
                                                else
                                                    str='F';
                                                end


                                                function str=getDecOutcomeStr(outcomeIdx,numOutcomes)
                                                    if numOutcomes>2
                                                        str=num2str(outcomeIdx);
                                                    else
                                                        if outcomeIdx==1
                                                            str='F';
                                                        else
                                                            str='T';
                                                        end
                                                    end


                                                    function str=genHTMLSourceElement(str)

                                                        str=['<code>',str,'</code>'];
