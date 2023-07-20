function[selectors,predefRules]=possibleCodeSelector(sid,varargin)





    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        argParser.addParameter('Mode','sfcn',@(x)any(validatestring(x,{'sfcn','xil','slcc'})));
        argParser.addParameter('CodeTr','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
        argParser.addParameter('CodeProverResults','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
        argParser.addParameter('IncludeOutcomes',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    end
    argParser.parse(varargin{:});


    selectors=[];
    predefRules=[];

    deadCodeInfo=[];

    switch lower(char(argParser.Results.Mode))
    case 'sfcn'
        sfunName=get_param(sid,'FunctionName');
        coveng=cvi.TopModelCov.getInstance(bdroot(sid));


        allPropMap=SlCov.FilterEditor.getPropertyDB;
        id=sprintf('P%d',int32(slcoverage.SFcnSelectorType.SFcnName));
        sFcnNameProp=allPropMap(id);
        sFcnNameProp.valueDesc=sfunName;
        description=SlCov.FilterEditor.getPropertyDescription(sFcnNameProp);
        selectors=slcoverage.SFcnSelector(slcoverage.SFcnSelectorType.SFcnName,sfunName);
        selectors(end).setDescription(description);


        if~coveng.slccCov.sfcnCov.sfcnName2Info.isKey(sfunName)
            return
        end


        sfunInfo=coveng.slccCov.sfcnCov.sfcnName2Info(sfunName);
        if~isstruct(sfunInfo)||~isfield(sfunInfo,'codeTr')||isempty(sfunInfo.codeTr)
            return
        end
        codeTr=sfunInfo.codeTr;
        ctorStr='slcoverage.SFcnSelector';

    case 'slcc'

        modelName=get_param(sid,'Name');
        coveng=cvi.TopModelCov.getInstance(modelName);
        if~coveng.slccCov.libName2Info.isKey(modelName)
            return
        end
        ccInfo=coveng.slccCov.libName2Info(modelName);
        if isempty(ccInfo.dbFile)||...
            ~isfile(ccInfo.dbFile)
            return
        end


        try
            codeTr=codeinstrum.internal.TraceabilityData(ccInfo.dbFile);
            codeTr.close();
        catch
            return
        end
        ctorStr='slcoverage.CodeSelector';
        sid='';

    case 'xil'

        codeTrFile=char(argParser.Results.CodeTr);
        if isempty(codeTrFile)||~isfile(codeTrFile)
            warning(message('Slvnv:codecoverage:CPFilterCannotFindCodeTrFile',sid));
            return
        end


        try
            codeTr=codeinstrum.internal.TraceabilityData(codeTrFile);
            codeTr.close();
        catch
            return
        end
        ctorStr='slcoverage.CodeSelector';
        sid='';


        cpResFile=char(argParser.Results.CodeProverResults);
        if~isempty(cpResFile)&&isfile(cpResFile)
            deadCodeInfo=extractDeadCodeInfo(cpResFile);
        end

    otherwise
        return
    end


    funSelectors=[];
    decSelectors=[];
    condSelectors=[];
    decOutcomeSelectors=[];
    condOutcomeSelectors=[];
    mcdcOutcomeSelectors=[];
    relBoundOutcomeSelectors=[];


    files=codeTr.getFilesInResults();

    idx=(([files.status]==internal.cxxfe.instrum.FileStatus.IGNORED)|...
    ([files.status]==internal.cxxfe.instrum.FileStatus.FAILED));
    files(idx)=[];
    for jj=1:numel(files)
        file=files(jj);
        fileName=file.shortPath;
        selectors=addSelector(selectors,ctorStr,fileName,'','','','',sid);


        for kk=1:file.definedFunctions.Size()
            fcn=file.definedFunctions(kk);
            funName=fcn.name;
            [funSelectors,sel]=addSelector(funSelectors,ctorStr,fileName,funName,'','','',sid);
            if~isempty(deadCodeInfo)&&~isempty(deadCodeInfo.fun)&&~isempty(sel)
                [deadCodeInfo.fun,filterRule]=findAndCreateFunRule(sel,fcn.location,fcn.declEndLocation,deadCodeInfo.fun);
                appendPredefinedRule(filterRule);
            end


            decCovPts=codeTr.getDecisionPoints(fcn);
            for locDecIdx=1:numel(decCovPts)
                decCovPt=decCovPts(locDecIdx);
                expr=decCovPt.node.getSourceCode();
                [decSelectors,sel]=addSelector(decSelectors,ctorStr,fileName,funName,expr,locDecIdx,1,sid);
                if~isempty(deadCodeInfo)&&~isempty(deadCodeInfo.block)&&~isempty(sel)
                    [deadCodeInfo.block,filterRule]=findAndCreateBlockRule(sel,decCovPt.node.startLocation,decCovPt.node.endLocation,deadCodeInfo.block);
                    appendPredefinedRule(filterRule);
                end


                if~argParser.Results.IncludeOutcomes||...
                    ~SlCov.isCodeOutcomeFilterFeatureOn()
                    continue
                end


                for outDecIdx=1:decCovPt.outcomes.Size()
                    decOutcomeSelectors=addSelector(decOutcomeSelectors,ctorStr,fileName,funName,expr,[locDecIdx,outDecIdx],1,sid);
                end


                for condIdx=1:decCovPt.subConditions.Size()
                    condOutcomeSelectors=addSelector(condOutcomeSelectors,ctorStr,fileName,funName,expr,[condIdx,1,locDecIdx],0,sid);
                    condOutcomeSelectors=addSelector(condOutcomeSelectors,ctorStr,fileName,funName,expr,[condIdx,2,locDecIdx],0,sid);
                end


                mcdcCovPt=decCovPt.mcdc;
                if~isempty(mcdcCovPt)
                    for mcdcIdx=1:mcdcCovPt.outcomes.Size()
                        mcdcOutcomeSelectors=addSelector(mcdcOutcomeSelectors,ctorStr,fileName,funName,expr,[locDecIdx,mcdcIdx],2,sid);
                    end
                end


                relOpCovPt=decCovPt.relationalOp;
                if~isempty(relOpCovPt)
                    for outIdx=1:relOpCovPt.outcomes.Size()
                        relBoundOutcomeSelectors=addSelector(relBoundOutcomeSelectors,ctorStr,fileName,funName,expr,[locDecIdx,outIdx],3,sid);
                    end
                else
                    for condIdx=1:decCovPt.subConditions.Size()
                        condCovPt=decCovPt.subConditions(condIdx);
                        relOpCovPt=condCovPt.relationalOp;
                        if~isempty(relOpCovPt)
                            for outIdx=1:relOpCovPt.outcomes.Size()
                                relBoundOutcomeSelectors=addSelector(relBoundOutcomeSelectors,ctorStr,fileName,funName,expr,[locDecIdx,outIdx,condIdx],3,sid);
                            end
                        end
                    end
                end
            end


            condCovPts=codeTr.getStandaloneConditionPoints(fcn);
            locIdx=0;
            for condIdx=1:numel(condCovPts)
                condCovPt=condCovPts(condIdx);


                locIdx=locIdx+1;

                expr=condCovPt.node.getSourceCode();
                [condSelectors,sel]=addSelector(condSelectors,ctorStr,fileName,funName,expr,locIdx,0,sid);
                if~isempty(deadCodeInfo)&&~isempty(deadCodeInfo.block)&&~isempty(sel)
                    [deadCodeInfo.block,filterRule]=findAndCreateBlockRule(sel,condCovPt.node.startLocation,condCovPt.node.endLocation,deadCodeInfo.block);
                    appendPredefinedRule(filterRule);
                end


                if~argParser.Results.IncludeOutcomes||...
                    ~SlCov.isCodeOutcomeFilterFeatureOn()
                    continue
                end


                condOutcomeSelectors=addSelector(condOutcomeSelectors,ctorStr,fileName,funName,expr,[locIdx,1],0,sid);
                condOutcomeSelectors=addSelector(condOutcomeSelectors,ctorStr,fileName,funName,expr,[locIdx,2],0,sid);


                relOpCovPt=condCovPt.relationalOp;
                if~isempty(relOpCovPt)
                    for rIdx=1:relOpCovPt.outcomes.Size()
                        relBoundOutcomeSelectors=addSelector(relBoundOutcomeSelectors,ctorStr,fileName,funName,expr,[locIdx,rIdx],3,sid);
                    end
                end
            end
        end
    end


    selectors=[selectors,funSelectors,decSelectors,condSelectors,...
    decOutcomeSelectors,condOutcomeSelectors,mcdcOutcomeSelectors,relBoundOutcomeSelectors];

    function appendPredefinedRule(filterRule)
        if isempty(filterRule)
            return
        end
        if isempty(predefRules)
            predefRules=filterRule;
        else
            predefRules=[predefRules,filterRule];
        end
    end
end


function[sel,tr]=addSelector(sel,ctorStr,fileName,funName,expr,exprIdx,cvMetricType,sid)

    key=SlCov.FilterEditor.encodeCodeFilterInfo(fileName,...
    funName,...
    expr,...
    exprIdx,...
    cvMetricType,...
    sid);
    [codeCovInfo,sid]=SlCov.FilterEditor.decodeCodeFilterInfo(key);

    if~isempty(sid)
        codeKey.ssid=sid;
        codeKey.codeCovInfo=codeCovInfo;
    else
        codeKey=codeCovInfo;
    end

    prop=SlCov.FilterEditor.deriveProperties(codeKey);
    if isempty(prop)


        tr=[];
        return
    end
    type=prop.selectorType;

    args={ctorStr,type};
    if~isempty(sid)
        args=[args,{sid}];
    end
    args=[args,{fileName,funName,expr}];
    if~isempty(exprIdx)
        args=[args,num2cell(codeCovInfo{4})];
    end
    try
        tr=feval(args{:});
    catch Me %#ok<NASGU>

        tr=[];
        return
    end

    description=SlCov.FilterEditor.getPropertyDescription(prop);
    description=strrep(description,'''','"');
    description=strrep(description,newline,' ');
    tr.setDescription(description);
    if isempty(sel)
        sel=tr;
    else
        sel(end+1)=tr;
    end

end


function deadCodeInfo=extractDeadCodeInfo(cpResFile)


    deadCodeInfo=[];


    if~isfile(cpResFile)
        warning(message('Slvnv:codecoverage:CPFilterCannotFindResFile',cpResFile));
        return
    end


    try
        dbObj=polyspace.internal.database.SqlDb(cpResFile,true,'obfuscated[e3yu7ypw5pMsWuFvKnuonJ5aHHwGHAqzCW]');
        if~dbObj.tableExists('','File')
            warning(message('Slvnv:codecoverage:CPFilterIncompleteResFile',cpResFile));
            return
        end
        stmtFile=dbObj.prepare('SELECT Path FROM File WHERE RefFile=?');
    catch
        warning(message('Slvnv:codecoverage:CPFilterUnexpectedErrorResFile',cpResFile));
        return
    end


    hasEmittedGenericWarning=false;


    deadCodeInfo=struct('fun',{[]},'block',{[]});


    try
        if dbObj.tableExists('','Function')&&...
            dbObj.columnExists('','Function','Name')&&...
            dbObj.columnExists('','Function','RefFile')&&...
            dbObj.columnExists('','Function','LineNum')&&...
            dbObj.columnExists('','Function','ColNum')&&...
            dbObj.columnExists('','Function','isDead')&&...
            dbObj.columnExists('','Function','BodyKind')
            out=dbObj.exec('SELECT Name, RefFile, LineNum, ColNum FROM Function WHERE isDead=1 AND BodyKind=1');
            for ii=1:size(out,1)
                deadCodeInfo.fun=[deadCodeInfo.fun;...
                struct('file',stmtFile.exec(out{ii,2}),...
                'name',out{ii,1},...
                'pos',[out{ii,3},out{ii,4}])...
                ];
            end
        else
            warning(message('Slvnv:codecoverage:CPFilterNoFunResFile',cpResFile));
        end
    catch
        hasEmittedGenericWarning=true;
        warning(message('Slvnv:codecoverage:CPFilterUnexpectedErrorResFile',cpResFile));
    end


    try
        if dbObj.tableExists('','Block')&&...
            dbObj.columnExists('','Block','ConditionRefFile')&&...
            dbObj.columnExists('','Block','ConditionLineNum')&&...
            dbObj.columnExists('','Block','ConditionColNum')&&...
            dbObj.columnExists('','Block','EndRefFile')&&...
            dbObj.columnExists('','Block','EndLineNum')&&...
            dbObj.columnExists('','Block','EndColNum')&&...
            dbObj.columnExists('','Block','isDead')
            out=dbObj.exec('SELECT ConditionRefFile, ConditionLineNum, ConditionColNum, EndRefFile, EndLineNum, EndColNum FROM Block WHERE isDead=1');
            for ii=1:size(out,1)

                if out(ii,1)~=out(ii,4)
                    continue
                end
                deadCodeInfo.block=[deadCodeInfo.block;...
                struct('file',stmtFile.exec(out(ii,1)),...
                'pos',[out(ii,2),out(ii,3)+1,out(ii,5),out(ii,6)+1])...
                ];
            end
        else
            warning(message('Slvnv:codecoverage:CPFilterNoBlockResFile',cpResFile));
        end
    catch
        if~hasEmittedGenericWarning
            warning(message('Slvnv:codecoverage:CPFilterUnexpectedErrorResFile',cpResFile));
        end
    end

end


function[deadInfo,filterRule]=findAndCreateFunRule(sel,funStartPos,funEndPos,deadInfo)

    persistent msg;
    if isempty(msg)
        msg=getString(message('Slvnv:codecoverage:CPFilterDeadFunLabel'));
    end

    filterRule=[];
    for ii=1:numel(deadInfo)

        if~strcmp(deadInfo(ii).name,sel.FunctionName)
            continue
        end


        if deadInfo(ii).pos(1)~=funStartPos.lineNum||...
            (deadInfo(ii).pos(2)>=funStartPos.colNum&&deadInfo(ii).pos(2)<funEndPos.colNum)
            continue
        end


        [~,fname,fext]=fileparts(deadInfo(ii).file);
        if~strcmp([fname,fext],sel.FileName)
            continue
        end



        filterRule=slcoverage.FilterRule(sel,msg,slcoverage.FilterMode.Justify);
        deadInfo(ii)=[];
        break
    end

end


function[deadInfo,filterRule]=findAndCreateBlockRule(sel,exprStartPos,exprEndPos,deadInfo)

    persistent msg;
    if isempty(msg)
        msg=getString(message('Slvnv:codecoverage:CPFilterDeadCodeLabel'));
    end

    filterRule=[];
    for ii=1:numel(deadInfo)

        if(exprStartPos.lineNum<deadInfo(ii).pos(1))||...
            (exprStartPos.colNum<deadInfo(ii).pos(2))||...
            (exprEndPos.lineNum>deadInfo(ii).pos(3))
            continue
        end


        [~,fname,fext]=fileparts(deadInfo(ii).file);
        if~strcmp([fname,fext],sel.FileName)
            continue
        end


        filterRule=slcoverage.FilterRule(sel,msg,slcoverage.FilterMode.Justify);
        break
    end

end
