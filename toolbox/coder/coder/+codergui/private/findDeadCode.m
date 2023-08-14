function[results,deadFunctions]=findDeadCode(report,includedFcnIds,mode)






    funcs=report.inference.Functions;
    scripts=report.inference.Scripts;
    if isempty(includedFcnIds)
        includedFcnIds=1:numel(funcs);
    end
    if nargin<3
        mode='full';
    end
    mode=validatestring(mode,{'full','partial','minimal'});
    switch mode
    case 'full'
        forDeadCode=true;
        forDeadFuncs=true;
    case 'partial'
        forDeadCode=false;
        forDeadFuncs=true;
    otherwise
        forDeadCode=false;
        forDeadFuncs=false;
    end





    rows=cell(numel(includedFcnIds),3);
    rows(:,1)={funcs(includedFcnIds).ScriptID};
    rows(:,2)={funcs(includedFcnIds).TextStart};
    rows(:,3)=num2cell(includedFcnIds);
    rows(:,4)=num2cell(1:numel(includedFcnIds));
    rows=sortrows(rows,[1,2,3,4]);

    if forDeadCode
        results=cell2struct(cell(numel(includedFcnIds),3),...
        {'variableLocationIds','expresssionLocationIds','deadCode'},2);
    else
        results=cell2struct(cell(numel(includedFcnIds),2),...
        {'variableLocationIds','expresssionLocationIds'},2);
    end
    if forDeadFuncs
        deadFunctions=cell(size(scripts));
    else
        deadFunctions={};
    end

    prevScript=-1;
    fcnNodeIndices=[];
    fcnNodeStarts=[];
    deadFcnMask=[];
    prevTextStart='';
    chunkStart=1;
    scriptTree=[];

    for i=1:size(rows,1)
        [scriptId,textStart]=rows{i,1:2};
        process=false;
        if prevScript==-1
            prevScript=scriptId;
            prevTextStart=textStart;
        elseif prevScript~=scriptId
            process=true;
        elseif prevTextStart~=textStart
            process=true;
        end
        if process
            processChunk(chunkStart,i-1);
            if(prevScript~=0)&&(prevScript~=scriptId)
                processForDeadFunctions();
                scriptTree=[];
            end
            chunkStart=i;
            prevScript=scriptId;
            prevTextStart=textStart;
        end
    end
    processChunk(chunkStart,size(rows,1));
    processForDeadFunctions();



    function processChunk(chunkStart,chunkEnd)
        if prevScript<=0
            return;
        end
        if isempty(scriptTree)
            fcnNodeIndices=[];
            if prevScript>0
                script=scripts(prevScript);
                [~,~,ext]=fileparts(script.ScriptPath);
                if~strcmpi(ext,'.p')
                    scriptTree=mtree(script.ScriptText);
                    if scriptTree.count()>0&&~strcmp(scriptTree.root.kind,'ERR')
                        fcnNodes=scriptTree.mtfind('Kind',{'FUNCTION','ANON'});
                        fcnNodeIndices=fcnNodes.indices();
                        fcnNodeStarts=lefttreepos(fcnNodes);
                        deadFcnMask=true(size(fcnNodeStarts));
                    else
                        scriptTree=[];
                    end
                end
            end
        end

        fcnNode=[];
        textOffset=0;
        if~isempty(fcnNodeIndices)
            sampleFunc=funcs(rows{chunkStart,3});
            matchFilter=fcnNodeStarts==sampleFunc.TextStart+1;
            matchIndex=fcnNodeIndices(matchFilter);
            if~isempty(matchIndex)
                fcnNode=scriptTree.select(matchIndex).Tree;
                deadFcnMask(matchFilter)=false;
            end
        end

        chunkedFuncs=funcs([rows{chunkStart:chunkEnd,3}]);
        [varLocIds,exprLocIds,deadVarCalls]=segregateLocations(fcnNode,textOffset,chunkedFuncs);
        runDca=~isempty(fcnNode)&&forDeadCode;

        if runDca
            exclusions=fcnNode.mtfind('Kind',{'FUNCTION','ANON'},'Parent.Null',false).Tree.indices();
            deadExprIndices=findDeadExprs(fcnNode,textOffset,chunkedFuncs,exclusions);
            deadCallIndices=findDeadCalls(fcnNode,textOffset,chunkedFuncs,exclusions,deadVarCalls);
            deadRanges=combineRanges(deadExprIndices,deadCallIndices,textOffset);
        end

        for ii=chunkStart:chunkEnd
            rIdx=rows{ii,4};
            dIdx=ii-chunkStart+1;
            results(rIdx).variableLocationIds=varLocIds{dIdx};
            results(rIdx).expressionLocationIds=exprLocIds{dIdx};
            if runDca
                results(rIdx).deadCode=deadRanges{dIdx};
            end


            if~isempty(fcnNode)
                results(rIdx).functionBodyExtents=[(fcnNode.Body.lefttreepos()-1),fcnNode.Body.righttreepos()];
                results(rIdx).inputNames=fcnNode.Ins.strings();
                results(rIdx).outputNames=fcnNode.Outs.strings();
            else
                results(rIdx).functionBodyExtents=[-1,0];
                results(rIdx).inputNames={};
                results(rIdx).outputNames={};
            end
        end
    end


    function processForDeadFunctions()
        if~forDeadFuncs||prevScript<=0||isempty(scriptTree)
            return;
        end
        deadNodes=scriptTree.select(fcnNodeIndices(deadFcnMask)).mtfind('Kind','FUNCTION');
        startLines=deadNodes.pos2lc(deadNodes.lefttreepos());
        endLines=deadNodes.pos2lc(deadNodes.righttreepos());
        deadFunctions{prevScript}=cell2struct(...
        [num2cell(startLines),num2cell(endLines)],...
        {'startLine','endLine'},2);
    end
end



function[varLocIds,exprLocIds,deadVarCalls]=segregateLocations(fcnNode,textOffset,reportFuncs)
    varLocIds=cell(size(reportFuncs));
    exprLocIds=varLocIds;
    deadVarCalls=varLocIds;

    if~isempty(fcnNode)
        vars=fcnNode.mtfind('Kind','ID','Isvar',true).indices();
        anonVars=fcnNode.mtfind('Kind','ANONID').indices();
        vars=fcnNode.select([vars,anonVars]);
        varStarts=int32(lefttreepos(vars)+textOffset);
    else
        return;
    end

    for i=1:numel(reportFuncs)
        locations=reportFuncs(i).MxInfoLocations;
        matchIndices=find(fastIsVariableLocation(locations));



        possibles=locations(matchIndices);
        locStarts=[possibles.TextStart]+1;
        [startFilter,startMatches]=ismember(locStarts,varStarts);
        varEnds=int32(righttreepos(vars)+textOffset);
        varEnds=varEnds(startMatches(startFilter));
        if any(startFilter)
            matchIndices=matchIndices(startFilter);
            matchIndices=matchIndices((locStarts(startFilter)+[possibles(startFilter).TextLength]-1)==varEnds');
        else
            matchIndices=[];
        end

        deadVarIndices=vars.indices();
        deadVarIndices=deadVarIndices(~ismember(varStarts,[locations(matchIndices).TextStart]+1));
        deadVarCalls{i}=indices(trueparent(vars.select(deadVarIndices).mtfind(...
        'Parent.Kind',{'CALL','SUBSCR'})));

        varLocIds{i}=matchIndices;
        notVars=true(size(locations));
        notVars(matchIndices)=false;
        exprLocIds{i}=find(notVars);
    end
end



function deadIndices=findDeadExprs(fcnNode,textOffset,chunkedFuncs,exclusions)
    deadables=fcnNode.mtfind('Kind',{'EXPR','PRINT','EQUALS'}).indices();
    callExprs=fcnNode.mtfind('Kind','EXPR','Arg.Kind','CALL').indices();
    subscrCalls=fcnNode.mtfind('Kind','EXPR','Arg.Kind',{'DOT','SUBSCR'},'Arg.Left.Left.Kind','ID').indices();
    doubleSubscrCalls=fcnNode.mtfind('Kind','EXPR','Arg.Kind',{'DOT','SUBSCR'},...
    'Arg.Left.Kind',{'DOT','SUBSCR'},'Arg.Left.Left.Left.Kind','ID').indices();
    deadables=fcnNode.select(setdiff(deadables,[exclusions,callExprs,subscrCalls,doubleSubscrCalls]));
    deadableIndices=deadables.indices();

    lefts=lefttreepos(deadables)+textOffset;
    [lefts,leftIndices]=unique(int32(lefts));
    deadableIndices=deadableIndices(leftIndices);

    rights=righttreepos(deadables);
    rights=rights(leftIndices)+textOffset;

    deadIndices=cell(numel(chunkedFuncs),1);
    for i=1:numel(chunkedFuncs)
        deadMask=~ismember(lefts,unique([chunkedFuncs(i).MxInfoLocations.TextStart]+1));
        deadIndices{i}=[deadableIndices(deadMask)',lefts(deadMask),rights(deadMask)];
    end
end



function deadCallIndices=findDeadCalls(fcnNode,textOffset,reportFcns,exclusions,deadVarCalls)
    persistent builtins;
    if isempty(builtins)
        builtins=sort(strsplit(builtin('_getEmlBuiltinNames'),','));
        builtins=builtins(2:end);
    end


    calls=fcnNode.mtfind('Kind',{'CALL','DCALL'},'Parent.Left.Isvar',false);
    callIndices=setdiff(calls.indices(),exclusions);
    callees=cell(size(callIndices));
    if~isempty(callees)
        for i=1:numel(callIndices)
            call=fcnNode.select(callIndices(i));
            callees{i}=string(call.Left);
        end
    end


    subscrCalls=fcnNode.mtfind('Kind','SUBSCR','Left.Kind','DOT');
    subscrIndices=setdiff(subscrCalls.indices(),exclusions);
    subscrCallees=cell(size(subscrIndices));
    if~isempty(subscrCallees)
        for i=1:numel(subscrIndices)
            call=fcnNode.select(subscrIndices(i));
            funcName=tree2str(call.Left);
            subscrCallees{i}=funcName;
        end
    end


    deadables=~ismember([callees,subscrCallees],builtins);
    subscrOffset=numel(callIndices)+1;
    if~isempty(callIndices)
        callIndices=callIndices(deadables(1:numel(callIndices)));
    end
    if~isempty(subscrIndices)
        subscrIndices=subscrIndices(deadables(subscrOffset:end));
    end

    deadCallIndices=cell(1,numel(reportFcns));

    for i=1:numel(reportFcns)
        deadables=fcnNode.select([callIndices,subscrIndices,deadVarCalls{i}]);
        indices=deadables.indices();
        if isempty(indices)
            continue;
        end

        callStarts=unique([reportFcns(i).CallSites.TextStart]+1);
        deadMask=~ismember(lefttreepos(deadables)+textOffset,callStarts);

        if any(deadMask)
            growables=trueparent(deadables.select(indices(deadMask)).mtfind('Parent.Kind',{'EQ','NE','GT','GE','LT','LE'}));
            growables=fcnNode.select([growables.indices(),indices(deadMask)]);
            deadCallIndices{i}=[growables.indices()',lefttreepos(growables)+textOffset,righttreepos(growables)+textOffset];
        end
    end
end



function deadRanges=combineRanges(exprRanges,callRanges,textOffset)
    deadRanges=cell(1,numel(exprRanges));

    for i=1:numel(exprRanges)
        exprs=exprRanges{i};
        eCount=size(exprs,1);
        eIdx=1;
        calls=callRanges{i};
        cCount=size(calls,1);
        cIdx=1;
        stitched=zeros(eCount+cCount,2,'int32');
        sIdx=1;
        outerIdx=0;


        while eIdx<=eCount&&cIdx<=cCount
            if exprs(eIdx,2)<calls(cIdx,2)
                pushExpr(false);
            elseif exprs(eIdx,2)>calls(cIdx,2)
                pushCall(false);
            elseif exprs(eIdx,3)>calls(cIdx,3)
                pushExpr(true);
            elseif exprs(eIdx,3)<calls(cIdx,3)
                pushCall(true);
            else

                cIdx=cIdx+1;
                eIdx=eIdx+1;
            end
        end

        while eIdx<=eCount
            pushExpr(false);
        end

        while cIdx<=cCount
            pushCall(false);
        end

        deadRanges{i}=[stitched(1:sIdx-1,1)-1,stitched(1:sIdx-1,2)]+textOffset;
    end


    function pushExpr(consumeCall)
        if shouldKeep(exprs(eIdx,2:3))
            stitched(sIdx,:)=exprs(eIdx,2:3);
            outerIdx=sIdx;
            sIdx=sIdx+1;
        end
        eIdx=eIdx+1;
        if consumeCall
            cIdx=cIdx+1;
        end
    end

    function pushCall(consumeExpr)
        if shouldKeep(calls(cIdx,2:3))
            stitched(sIdx,:)=calls(cIdx,2:3);
            outerIdx=sIdx;
            sIdx=sIdx+1;
        end
        cIdx=cIdx+1;
        if consumeExpr
            cIdx=cIdx+1;
        end
    end

    function keep=shouldKeep(range)
        if outerIdx>0&&stitched(outerIdx,1)<=range(1)&&stitched(outerIdx,2)>=range(2)
            keep=false;
        else
            keep=true;
        end
    end
end
