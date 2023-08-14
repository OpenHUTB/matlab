






classdef EmbeddedCoderAnnotations<coder.coverage.Annotations

    properties(Access=private)
Kinds
Events
Columns
Lines
JustifyLinks
FnCov
FnTotal
FnExitCov
FnExitTotal
CondCov
CondTotal
DecCov
DecTotal
SwitchLabelCov
SwitchLabelTotal
McdcCov
McdcTotal
StmtCov
StmtTotal
CodeGenFolder
ComponentObjDir
ComponentDir
ComponentObjDirs
CovData
        CovRes=[]
CompPathFcn
FcnExitCovEnabled
    end

    methods(Access=public)




        function this=EmbeddedCoderAnnotations(covData,codeGenFolder,componentObjDirs)
            this.CovData=covData;
            this.CovRes=cell(numel(covData),1);
            this.CodeGenFolder=codeGenFolder;
            this.ComponentObjDirs=cell(size(componentObjDirs));
            for i=1:numel(componentObjDirs)

                this.ComponentObjDirs{i}=fullfile(componentObjDirs{i});
            end
            if ispc
                this.CompPathFcn=@strcmpi;
            else
                this.CompPathFcn=@strcmp;
            end
            this.FcnExitCovEnabled=logical(codeinstrumprivate('feature','enableFcnExitInAnnotation'));
        end




        function summary=getSummaryHtml(this)

            labels={};
            bars={};

            if~isempty(this.DecTotal)||~isempty(this.SwitchLabelTotal)
                if isempty(this.DecTotal)
                    this.DecTotal=0;
                    this.DecCov=0;
                end
                if isempty(this.SwitchLabelTotal)
                    this.SwitchLabelTotal=0;
                    this.SwitchLabelCov=0;
                end
                [labels{end+1},bars{end+1}]=coder.coverage.Annotations.getHtmlSummaryBar...
                (this.DecCov+this.SwitchLabelCov,this.DecTotal+this.SwitchLabelTotal,'Slvnv:codecoverage:DecisionCoverageLabel',...
                'Slvnv:codecoverage:DecisionCoverageTooltip');
            end

            if~isempty(this.CondTotal)
                [labels{end+1},bars{end+1}]=coder.coverage.Annotations.getHtmlSummaryBar...
                (this.CondCov,this.CondTotal,'Slvnv:codecoverage:ConditionCoverageLabel',...
                'Slvnv:codecoverage:ConditionCoverageTooltip');
            end

            if~isempty(this.McdcTotal)
                [labels{end+1},bars{end+1}]=coder.coverage.Annotations.getHtmlSummaryBar...
                (this.McdcCov,this.McdcTotal,'Slvnv:codecoverage:McdcCoverageLabel',...
                'Slvnv:codecoverage:McdcCoverageTooltip');
            end

            if~isempty(this.StmtTotal)
                [labels{end+1},bars{end+1}]=coder.coverage.Annotations.getHtmlSummaryBar...
                (this.StmtCov,this.StmtTotal,'Slvnv:codecoverage:StatementCoverageLabel',...
                'Slvnv:codecoverage:StatementCoverageTooltip');
            end

            if~isempty(this.FnTotal)
                [labels{end+1},bars{end+1}]=coder.coverage.Annotations.getHtmlSummaryBar...
                (this.FnCov,this.FnTotal,'Slvnv:codecoverage:FunctionCoverageLabel',...
                'Slvnv:codecoverage:FunctionCoverageTooltip');
            end

            if this.FcnExitCovEnabled&&~isempty(this.FnExitTotal)
                [labels{end+1},bars{end+1}]=coder.coverage.Annotations.getHtmlSummaryBar...
                (this.FnExitCov,this.FnExitTotal,'Slvnv:codecoverage:FunctionExitCoverageLabel',...
                'Slvnv:codecoverage:FunctionExitCoverageTooltip');
            end

            if isempty(labels)
                summary='';
                return
            end



            summary=sprintf('%s\n<p><table style="width:0;white-space:nowrap">\n',...
            SlCov.coder.EmbeddedCoderAnnotations.getDisplayName());
            numItems=0;
            for ii=1:numel(labels)
                if numItems==0
                    pref='<tr><td>';
                else
                    pref='<td>&nbsp;&nbsp;&nbsp;&nbsp;';
                end
                if numItems==2
                    suff=['</tr>',newline];
                    numItems=0;
                else
                    suff='';
                    numItems=numItems+1;
                end
                summary=sprintf('%s%s%s</td><td>%s</td>%s',...
                summary,pref,labels{ii},bars{ii},suff);
            end
            if numItems~=0
                pref=['</tr>',newline];
            else
                pref='';
            end
            summary=sprintf('%s%s</table>\n<p>',summary,pref);
        end




        function[lineNos,colNos,textStr1,textStr1Status,textStr2,textStr2Status,...
            toolTips,justifyLinks]=getAnnotations(this)

            lineNos=this.Lines;
            colNos=this.Columns;
            events=this.Events;
            kinds=this.Kinds;

            textStr1=cell(size(lineNos));
            textStr1Status=cell(size(lineNos));
            textStr2=cell(size(lineNos));
            textStr2Status=cell(size(lineNos));
            toolTips=cell(size(lineNos));
            justifyLinks=cell(size(lineNos));

            for i=1:numel(kinds)
                str2='';
                stat2='';
                kind=kinds{i};
                event=events{i};
                switch kind
                case 'decision'
                    switch event
                    case 'none'
                        tip='Decision not covered';
                        str1='&nbsp;&nbsp;=&gt;';
                        stat1='F';
                    case 'full'
                        tip='Decision covered true and false';
                        str1='TF&nbsp;&nbsp;';
                        stat1='T';
                    case 'true'
                        tip='Decision covered true, but not false';
                        str1='&nbsp;=&gt;';
                        stat1='F';
                        str2='T';
                        stat2='T';
                    case 'false'
                        tip='Decision covered false, but not true';
                        str1='&nbsp;=&gt;';
                        stat1='F';
                        str2='F';
                        stat2='T';
                    end
                case 'function'
                    switch event
                    case 'none'
                        tip='Function not called';
                        str1='=&gt;&nbsp;&nbsp;';
                        stat1='F';
                    case 'full'
                        tip='Function called';
                        str1='Fcn&nbsp;';
                        stat1='T';
                    end
                case 'statement'
                    switch event
                    case 'none'
                        tip='Statement not executed';
                        str1='=&gt;&nbsp;&nbsp;';
                        stat1='F';
                    case 'full'
                        tip='Statement executed';
                        str1='S&nbsp;';
                        stat1='T';
                    end
                case 'switch-label'
                    switch event
                    case 'none'
                        tip='Switch label not covered';
                        str1='=&gt;&nbsp;&nbsp;';
                        stat1='F';
                    case 'full'
                        tip='Switch label covered';
                        str1='Sw&nbsp;&nbsp;';
                        stat1='T';
                    end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
                case 'constant'
                    assert(strcmp(event,'none'),...
                    'For constant, the only allowed event is none');
                    tip='Constant not measured';
                    str1='&nbsp;&nbsp;&nbsp;k';
                    stat1='N';
                case 'condition'
                    switch event
                    case 'none'
                        tip='Condition not covered';
                        str1='&nbsp;&nbsp;=&gt;';
                        stat1='F';
                    case 'full'
                        tip='Condition covered true and false';
                        str1='tf&nbsp;&nbsp;';
                        stat1='T';
                    case 'true'
                        tip='Condition covered true, but not false';
                        str1='&nbsp;=&gt;';
                        stat1='F';
                        str2='t';
                        stat2='T';
                    case 'false'
                        tip='Condition covered false, but not true';
                        str1='&nbsp;=&gt;';
                        stat1='F';
                        str2='f';
                        stat2='T';
                    end
                otherwise

                    assert(false,['Unexpected kind: ',kind]);
                end
                textStr1{i}=str1;
                textStr1Status{i}=stat1;
                textStr2{i}=str2;
                textStr2Status{i}=stat2;
                toolTips{i}=tip;
                justifyLinks{i}=this.JustifyLinks{i};
            end
        end




        function setSrcFile(this,file,componentDir,instrumentedObjectCodeFolder)

            this.reset();

            if isempty(this.CovData)
                return
            end

            try
                if~strcmp(componentDir,this.ComponentDir)

                    componentDirRel=componentDir(length(this.CodeGenFolder)+2:end);
                    objFolder=fullfile(componentDirRel,instrumentedObjectCodeFolder);
                    lComponentObjDirIdx=...
                    strcmp(this.ComponentObjDirs,objFolder);

                    if sum(lComponentObjDirIdx)~=1

                        return
                    end

                    this.ComponentObjDir=this.ComponentObjDirs{lComponentObjDirIdx};
                    this.ComponentDir=componentDir;
                end


                for ii=1:numel(this.CovData)
                    codeCovData=this.CovData(ii);
                    files=codeCovData.CodeTr.getFilesInResults();
                    for jj=1:numel(files)
                        srcPathFromCovFile=files(jj).path;
                        if~coder.coverage.CodeCoverageHook.isAbsPath({srcPathFromCovFile})
                            srcPathFromCovFile=fullfile(this.CodeGenFolder,srcPathFromCovFile);
                            srcPathFromCovFile=RTW.reduceRelativePath(srcPathFromCovFile);
                        end
                        if feval(this.CompPathFcn,fullfile(srcPathFromCovFile),fullfile(file))
                            computeResults(this,codeCovData,files(jj));
                            return
                        end
                    end
                end
            catch Me

                warning(message('Slvnv:codecoverage:CodeViewExtractionError',Me.message));
            end
        end

        function computeResults(this,codeCovData,file)
            res=codeCovData.getAggregatedResults();
            codeCovDataStruct=codeCovData.toStruct;
            filterCtx=codeCovDataStruct.config.filterCtx;

            numFunctions=0;
            funEntryStats=res.getDeepMetricStats(file,internal.cxxfe.instrum.MetricKind.FUN_ENTRY);
            if funEntryStats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                this.FnCov=double(funEntryStats.numCovered);
                numFunctions=double(funEntryStats.numNonExcluded);
                this.FnTotal=numFunctions;
            end
            if numFunctions~=0
                funEntryCovPts=codeCovData.CodeTr.getFunEntryPoints(file);
                fnPos=zeros(numel(funEntryCovPts),2,'int64');
                iCoveredFunctions=false(numel(funEntryCovPts),1);
                for ii=1:numel(funEntryCovPts)
                    funEntryCovPt=funEntryCovPts(ii);
                    fcn=funEntryCovPt.node.function;
                    fnPos(ii,:)=[fcn.location.lineNum,fcn.location.colNum];
                    iCoveredFunctions(ii)=(res.getNumHitsForCovId(funEntryCovPt.outcomes(1).covId)>0);
                end
            else
                fnPos=zeros(0,2,'int64');
                iCoveredFunctions=false(0,1);
            end

            if this.FcnExitCovEnabled
                funExitStats=res.getDeepMetricStats(file,internal.cxxfe.instrum.MetricKind.FUN_EXIT);
                if funExitStats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                    this.FnExitCov=double(funExitStats.numCovered);
                    this.FnExitTotal=double(funExitStats.numNonExcluded);
                end
            end

            decStats=res.getDeepMetricStats(file,internal.cxxfe.instrum.MetricKind.DECISION);
            if decStats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                this.DecCov=double(decStats.numCovered);
                numDecOutcomes=double(decStats.numNonExcluded);
                this.DecTotal=numDecOutcomes;
            else
                numDecOutcomes=0;
            end
            if numDecOutcomes~=0
                decCovPts=codeCovData.CodeTr.getDecisionPoints(file);
                decPos=zeros(numel(decCovPts),2,'int64');
                iFalseDecs=false(numel(decCovPts),1);
                iTrueDecs=false(numel(decCovPts),1);
                casePos=zeros(0,2,'int64');
                iCaseCov=false(0,1);
                this.SwitchLabelCov=0;
                numDecisions=0;
                numDecOutcomes=0;
                justifyDecLinks={};
                numSwitchCaseOutcomes=0;
                swIdx=false(size(decCovPts));
                for ii=1:numel(decCovPts)
                    decCovPt=decCovPts(ii);
                    if decCovPt.node.kind==internal.cxxfe.instrum.ProgramNodeKind.DECISION
                        numDecisions=numDecisions+1;
                        numDecOutcomes=numDecOutcomes+2;
                        if~isempty(decCovPt.node.startLocation)
                            decPos(ii,:)=[decCovPt.node.startLocation.lineNum,decCovPt.node.startLocation.colNum];
                        end
                        iFalseDecs(ii)=(res.getNumHitsForCovId(decCovPt.outcomes(1).covId)>0);
                        iTrueDecs(ii)=(res.getNumHitsForCovId(decCovPt.outcomes(2).covId)>0);
                        justifyDecLinks{numDecisions}=this.getJustifyDecLinks(iFalseDecs(ii),iTrueDecs(ii),...
                        filterCtx,codeCovDataStruct,res,codeCovData,decCovPt);%#ok<AGROW> 
                    else
                        swIdx(ii)=true;
                        numCase=decCovPts(ii).outcomes.Size();
                        iCaseCov=[iCaseCov;false(numCase,1)];%#ok<AGROW>
                        casePos=[casePos;zeros(numCase,2,'int64')];%#ok<AGROW>
                        for jj=1:numCase
                            caseInstrPt=decCovPts(ii).outcomes(jj);
                            iCaseCov(numSwitchCaseOutcomes+jj,1)=(res.getNumHitsForCovId(caseInstrPt.covId)>0);
                            if~isempty(caseInstrPt.node.startLocation)
                                casePos(numSwitchCaseOutcomes+jj,:)=[caseInstrPt.node.startLocation.lineNum...
                                ,caseInstrPt.node.startLocation.colNum];
                            end
                        end
                        this.SwitchLabelCov=this.SwitchLabelCov+sum(iCaseCov(numSwitchCaseOutcomes+1:end,1));
                        numSwitchCaseOutcomes=numSwitchCaseOutcomes+numCase;
                    end
                end
                decPos(swIdx,:)=[];
                iFalseDecs(swIdx,:)=[];
                iTrueDecs(swIdx,:)=[];
                this.DecTotal=numDecOutcomes;
                this.DecCov=sum(iFalseDecs)+sum(iTrueDecs);

                this.SwitchLabelTotal=numSwitchCaseOutcomes;
            else
                numDecisions=0;
                decPos=zeros(0,2,'int64');
                iFalseDecs=false(0,1);
                iTrueDecs=false(0,1);
                numSwitchCaseOutcomes=0;
                iCaseCov=false(0,1);
                casePos=zeros(0,2,'int64');
            end

            condStats=res.getDeepMetricStats(file,internal.cxxfe.instrum.MetricKind.CONDITION);
            if condStats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                this.CondCov=double(condStats.numCovered);
                numConditions=double(condStats.numNonExcluded/2);
                this.CondTotal=numConditions*2;
            else
                numConditions=0;
            end
            if numConditions~=0
                condCovPts=codeCovData.CodeTr.getConditionPoints(file);
                condPos=zeros(numel(condCovPts),2,'int64');
                iFalseConds=false(numel(condCovPts),1);
                iTrueConds=false(numel(condCovPts),1);
                justifyCondLinks={};
                for ii=1:numel(condCovPts)
                    condCovPt=condCovPts(ii);
                    if~isempty(condCovPt.node.startLocation)
                        condPos(ii,:)=[condCovPt.node.startLocation.lineNum,condCovPt.node.startLocation.colNum];
                    end
                    iFalseConds(ii)=(res.getNumHitsForCovId(condCovPt.outcomes(1).covId)>0);
                    iTrueConds(ii)=(res.getNumHitsForCovId(condCovPt.outcomes(2).covId)>0);
                    justifyCondLinks{ii}=this.getJustifyCondLinks(iFalseConds(ii),iTrueConds(ii),...
                    filterCtx,codeCovDataStruct,res,codeCovData,condCovPt);%#ok<AGROW> 
                end
            else
                condPos=zeros(0,4,'int64');
                iFalseConds=false(0,1);
                iTrueConds=false(0,1);
            end

            numStatements=0;
            stmtStats=res.getDeepMetricStats(file,internal.cxxfe.instrum.MetricKind.STATEMENT);
            if stmtStats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                this.StmtCov=double(stmtStats.numCovered);
                numStatements=double(stmtStats.numNonExcluded);
                this.StmtTotal=numStatements;
            end
            if numStatements~=0
                stmtCovPts=codeCovData.CodeTr.getStatementPoints(file);
                stmtPos=zeros(numel(stmtCovPts),2,'int64');
                iCoveredStatements=false(numel(stmtCovPts),1);
                for ii=1:numel(stmtCovPts)
                    stmtCovPt=stmtCovPts(ii);
                    if~isempty(stmtCovPt.node.startLocation)
                        stmtPos(ii,:)=[stmtCovPt.node.startLocation.lineNum,stmtCovPt.node.startLocation.colNum];
                    end
                    iCoveredStatements(ii)=(res.getNumHitsForCovId(stmtCovPt.outcomes(1).covId)>0);
                end
            else
                stmtPos=zeros(0,2,'int64');
                iCoveredStatements=false(0,1);
            end

            mcdcStats=res.getDeepMetricStats(file,internal.cxxfe.instrum.MetricKind.MCDC);
            if mcdcStats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                this.McdcCov=double(mcdcStats.numCovered);
                this.McdcTotal=double(mcdcStats.numNonExcluded);
            end

            kinds=[...
            repmat({'function'},[numFunctions,1]);...
            repmat({'statement'},[numStatements,1]);...
            repmat({'decision'},[numDecisions,1]);...
            repmat({'condition'},[numConditions,1]);...
            repmat({'switch-label'},[numSwitchCaseOutcomes,1])...
            ];

            lines=[fnPos(:,1);stmtPos(:,1);decPos(:,1);condPos(:,1);casePos(:,1)];
            columns=[fnPos(:,2);stmtPos(:,2);decPos(:,2);condPos(:,2);casePos(:,2)];

            events=cell(numel(kinds),1);
            iFull=[iCoveredFunctions;iCoveredStatements;iFalseDecs&iTrueDecs;iFalseConds&iTrueConds;iCaseCov];
            events(iFull)={'full'};
            iNone=[~iCoveredFunctions;~iCoveredStatements;~iFalseDecs&~iTrueDecs;~iFalseConds&~iTrueConds;~iCaseCov];
            events(iNone)={'none'};
            iFalse=[false(numFunctions+numStatements,1);iFalseDecs&~iTrueDecs;iFalseConds&~iTrueConds;false(size(iCaseCov))];
            events(iFalse)={'false'};
            iTrue=[false(numFunctions+numStatements,1);~iFalseDecs&iTrueDecs;~iFalseConds&iTrueConds;false(size(iCaseCov))];
            events(iTrue)={'true'};

            justifyLinks=cell(numel(kinds),1);
            jdx=numFunctions+numStatements;
            for idx=1:numDecisions
                justifyLinks{jdx+idx}=justifyDecLinks{idx};
            end
            jdx=numFunctions+numStatements+numDecisions;
            for idx=1:numConditions
                justifyLinks{jdx+idx}=justifyCondLinks{idx};
            end

            this.Kinds=kinds;
            this.Lines=lines;
            this.Events=events;
            this.Columns=columns;
            this.JustifyLinks=justifyLinks;

            this.setAnnotationsAvailable(true);
        end

        function reset(this)
            this.FnCov=[];
            this.FnTotal=[];
            this.FnExitCov=[];
            this.FnExitTotal=[];
            this.DecCov=[];
            this.DecTotal=[];
            this.CondCov=[];
            this.CondTotal=[];
            this.SwitchLabelCov=[];
            this.SwitchLabelTotal=[];
            this.McdcCov=[];
            this.McdcTotal=[];
            this.StmtCov=[];
            this.StmtTotal=[];

            this.Kinds=[];
            this.Events=[];
            this.Columns=[];
            this.Lines=[];

            this.setAnnotationsAvailable(false);
        end
    end

    methods(Static)
        function name=getName()
            name=SlCov.coder.EmbeddedCoder.getName();
        end
        function name=getDisplayName()
            name=SlCov.getCoverageToolName();
        end
    end

    methods(Static,Hidden)
        function varargout=writeCodeViewInformation(cvd)

            nargoutchk(0,1);
            covFiles={};

            if isa(cvd,'cvdata')
                cvdg=cv.cvdatagroup();
                cvdg.add(cvd);
            elseif isa(cvd,'cv.cvdatagroup')
                cvdg=cvd;
            else
                if nargout==1
                    varargout{1}=covFiles;
                end
                return
            end



            customCodeCvd=[];
            moduleInfo=cell(0,2);
            allNames=cvdg.allNames();
            for ii=1:numel(allNames)
                cvds=cvdg.get(allNames{ii});
                for jj=1:numel(cvds)
                    cvd=cvds(jj);
                    if~SlCov.CovMode.isGeneratedCode(cvd.simMode)
                        continue
                    end

                    if cvd.isCustomCode



                        customCodeCvd=[customCodeCvd;cvd];%#ok<AGROW>
                        continue

                    elseif cvd.isSharedUtility
                        dbFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(cvd.codeCovData.OrigModuleName);
                        writeCodeViewFile(dbFile,cvd.codeCovData);
                        continue

                    else
                        [~,modelName,~,errmsg]=cvi.ReportUtils.loadTopModelAndRefModels(cvd,cvd.simMode);
                        if~isempty(errmsg)

                            warning(errmsg);
                            continue
                        end

                        moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(modelName,cvd.simMode);
                        dbFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);
                        moduleInfo=[moduleInfo;{dbFile,[]}];%#ok<AGROW>
                        writeCodeViewFile(dbFile,cvd.codeCovData);
                    end
                end
            end



            for ii=1:numel(customCodeCvd)
                codeCovData=customCodeCvd(ii).codeCovData;
                files=codeCovData.CodeTr.getFilesInResults();
                filePath=files(1).path;
                for jj=1:size(moduleInfo,1)

                    if~isfile(moduleInfo{jj,1})

                        continue
                    end
                    if isempty(moduleInfo{jj,2})
                        trObj=codeinstrum.internal.TraceabilityData(moduleInfo{jj,1});
                        moduleInfo{jj,2}=trObj;
                    end


                    if~isempty(moduleInfo{jj,2}.getFile(filePath))
                        writeCodeViewFile(moduleInfo{jj,1},codeCovData);
                    end
                end
            end

            if nargout==1
                varargout{1}=covFiles;
            end


            function writeCodeViewFile(trDbFile,codeCovData)
                cgDir=fileparts(trDbFile);
                htmlFolder=fullfile(cgDir,'html');
                if~isfolder(htmlFolder)
                    return
                end
                try
                    codeAnnot=SlCov.coder.EmbeddedCoderAnnotations(codeCovData,cgDir,[]);

                    files=codeCovData.CodeTr.getFilesInResults();

                    for kk=1:numel(files)
                        codeAnnot.reset();
                        codeAnnot.computeResults(codeCovData,files(kk));
                        if codeAnnot.hasAnnotations
                            [~,name,ext]=fileparts(files(kk).shortPath);
                            covData=codeAnnot.getData();
                            covFile=fullfile(htmlFolder,[name,ext,'.cov_',SlCov.coder.EmbeddedCoder.getName()]);
                            save(covFile,'covData','-mat');
                            covFiles=[covFiles,{covFile}];%#ok<AGROW>
                        end
                    end
                catch Me


                    disp(getString(message('Slvnv:codecoverage:CodeViewExtractionError',Me.message)));
                end
            end
        end

        function justifyDecLink=getJustifyDecLinks(iFalseDecs,iTrueDecs,...
            filterCtx,codeCovDataStruct,res,codeCovData,decCovPt)

            justifyDecLink={{'False','',''},{'True','',''}};
            if~isempty(filterCtx)
                covId=filterCtx.cvdataId;
                filterCtxIdx=filterCtx.filterCtxId;
                reportViewCmd=filterCtx.reportViewCmd;
            end
            for outcomeIdx=1:2
                if outcomeIdx==1
                    decOutcome=iFalseDecs;
                else
                    decOutcome=iTrueDecs;
                end
                if decOutcome
                    justifyDecLink{outcomeIdx}{2}='Covered';
                else
                    if isempty(filterCtx)
                        justifyDecLink{outcomeIdx}{2}='Not covered';
                    else
                        modelName=codeCovDataStruct.modelinfo.analyzedModel;
                        filterFileName='';
                        ssid='';
                        effectiveFilter=res.getEffectiveFilter(decCovPt.outcomes(outcomeIdx));
                        if~isempty(effectiveFilter)
                            if strcmp(effectiveFilter.mode,'JUSTIFIED')
                                justifyDecLink{outcomeIdx}{2}='Justified';


                            else

                            end
                        else
                            codeTr=codeCovData.CodeTr;
                            locDecIdx=find(codeTr.getDecisionPoints(decCovPt.node.function)==decCovPt,1);
                            codeCovInfo=sprintf('{ ''%s'',  ''%s'', ''%s'', [%d, %d], 1}',...
                            decCovPt.function.primarySourceFile.shortPath,...
                            decCovPt.function.name,...
                            decCovPt.node.getSourceCode,...
                            locDecIdx,...
                            outcomeIdx);

                            justifyDecLink{outcomeIdx}{2}='Not covered';
                            linkStr=sprintf('%s(''%s'', ''%s'', %d,  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s);',...
                            'cvi.FilterExplorer.FilterExplorer.reportRuleCallback',...
                            filterCtxIdx,...
                            [],...
                            covId,...
                            reportViewCmd,...
                            modelName,...
                            filterFileName,...
                            'add',...
                            ssid,...
                            codeCovInfo);
                            justifyDecLink{outcomeIdx}{3}=linkStr;
                        end
                    end
                end
            end
        end


        function justifyCondLink=getJustifyCondLinks(iFalseConds,iTrueConds,...
            filterCtx,codeCovDataStruct,res,codeCovData,condCovPt)

            justifyCondLink={{'False','',''},{'True','',''}};
            if~isempty(filterCtx)
                covId=filterCtx.cvdataId;
                filterCtxIdx=filterCtx.filterCtxId;
                reportViewCmd=filterCtx.reportViewCmd;
            end
            for outcomeIdx=1:2
                if outcomeIdx==1
                    condOutcome=iFalseConds;
                else
                    condOutcome=iTrueConds;
                end
                if condOutcome
                    justifyCondLink{outcomeIdx}{2}='Covered';
                else
                    if isempty(filterCtx)
                        justifyCondLink{outcomeIdx}{2}='Not covered';
                    else
                        modelName=codeCovDataStruct.modelinfo.analyzedModel;
                        filterFileName='';
                        ssid='';
                        effectiveFilter=res.getEffectiveFilter(condCovPt.outcomes(outcomeIdx));
                        if~isempty(effectiveFilter)
                            if strcmp(effectiveFilter.mode,'JUSTIFIED')
                                justifyCondLink{outcomeIdx}{2}='Justified';


                            else

                            end
                        else
                            codeTr=codeCovData.CodeTr;
                            if isempty(condCovPt.parentDecision)

                                locCondIdx=find(codeTr.getStandaloneConditionPoints(condCovPt.node.function)==condCovPt,1);
                                conditionSourceCode=condCovPt.getSourceCode();
                                codCovInfoCond=sprintf('[%d, %d]',locCondIdx,outcomeIdx);
                            else

                                locDecIdx=find(codeTr.getDecisionPoints(condCovPt.node.function)==condCovPt.parentDecision,1);
                                locCondIdx=find(condCovPt.parentDecision.subConditions.toArray()==condCovPt,1);
                                conditionSourceCode=condCovPt.parentDecision.getSourceCode();
                                codCovInfoCond=sprintf('[%d, %d, %d]',locCondIdx,outcomeIdx,locDecIdx);
                            end

                            codeCovInfo=sprintf('{ ''%s'',  ''%s'', ''%s'', %s, 0}',...
                            condCovPt.function.primarySourceFile.shortPath,...
                            condCovPt.function.name,...
                            conditionSourceCode,...
                            codCovInfoCond);

                            justifyCondLink{outcomeIdx}{2}='Not covered';
                            linkStr=sprintf('%s(''%s'', ''%s'', %d,  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s);',...
                            'cvi.FilterExplorer.FilterExplorer.reportRuleCallback',...
                            filterCtxIdx,...
                            [],...
                            covId,...
                            reportViewCmd,...
                            modelName,...
                            filterFileName,...
                            'add',...
                            ssid,...
                            codeCovInfo);
                            justifyCondLink{outcomeIdx}{3}=linkStr;
                        end
                    end
                end
            end
        end
    end
end


