function[aTree,bTree]=alignMatlabCode(before,after,varargin)





    persistent ip;
    if isempty(ip)
        ip=inputParser();
        ip.addParameter('IgnoreLiteralValues',true,@islogical);
        ip.addParameter('IgnoreVariableNames',false,@islogical);
    end
    ip.parse(varargin{:});
    ignoreLiteralValues=ip.Results.IgnoreLiteralValues;
    ignoreVarNames=ip.Results.IgnoreVariableNames;

    aTree=toTree(before);
    bTree=toTree(after);



    [aSeq,aIndices,bSeq,bIndices]=generateTokenSequences(aTree,bTree,...
    ignoreLiteralValues,ignoreVarNames);


    if~isempty(aSeq)&&~isempty(bSeq)
        [abExp,baExp,score]=diffcode(aSeq,bSeq);
    else
        if isempty(bSeq)
            abExp=1:numel(aSeq);
            baExp=zeros(1,numel(aSeq));
        else
            abExp=zeros(1,numel(bSeq));
            baExp=1:numel(bSeq);
        end
        score=0;
    end

    if score>0

        abPrime=zeros(1,numel(abExp));
        abPrime(abExp~=0)=aSeq(abExp(abExp~=0));
        baPrime=zeros(1,numel(baExp));
        baPrime(baExp~=0)=bSeq(baExp(baExp~=0));
        shared=abPrime==baPrime;

        aTree=aTree.select(aIndices(abExp(shared)));
        bTree=bTree.select(bIndices(baExp(shared)));
    else
        aTree=aTree.select([]);
        bTree=bTree.select([]);
    end
end


function[firstSeq,firstIdx,secondSeq,secondIdx]=generateTokenSequences(...
    firstTree,secondTree,ignoreLiteralValues,ignoreVarNames)

    [firstSeq,firstIdx,sharedStrings]=generateTokenSequence(firstTree,{});
    [secondSeq,secondIdx]=generateTokenSequence(secondTree,sharedStrings);


    function[identifiers,origIndices,sharedStrings]=generateTokenSequence(mtp,sharedStrings)
        origIndices=mtp.indices();
        identifiers=zeros(1,numel(origIndices));


        stringIdx=mtp.Data(origIndices,8);
        if ignoreVarNames
            [~,varIndices]=intersect(origIndices,mtp.mtfind('Isvar',true).indices());
            stringIdx(varIndices)=0;
        end
        allStrings=repmat({''},1,numel(origIndices));
        allStrings(stringIdx>0)=mtp.nsStrings(origIndices(stringIdx>0));
        hasString=reshape(~cellfun('isempty',allStrings),[],1);
        allStrings=allStrings(hasString);


        [curUnique,~,uniqueIdx]=unique(allStrings);

        [~,curIdx,sharedIdx]=intersect(curUnique,sharedStrings);
        unifiedIdx=zeros(1,numel(curUnique));
        unifiedIdx(curIdx)=sharedIdx;
        newFilter=unifiedIdx==0;

        newIndices=numel(sharedStrings)+1:numel(sharedStrings)+nnz(newFilter);
        unifiedIdx(newFilter)=newIndices;
        identifiers(hasString)=unifiedIdx(uniqueIdx);
        sharedStrings(newIndices)=curUnique(newFilter);


        notHasString=~hasString;
        if ignoreLiteralValues
            notHasString=notHasString|ismember(mtp.nsKinds(origIndices),...
            {'STRING','CHARVECTOR','INT','DOUBLE'});
        end
        identifiers(notHasString)=-mtp.nsKindId(origIndices(notHasString));
    end
end


function filtered=toTree(arg)
    if~isa(arg,'codergui.internal.util.mtreeplus')
        mt=codergui.internal.util.mtreeplus(arg);
    else
        mt=arg;
    end
    filtered=mt.mtfind('Kind',{...
    'ID','FIELD','ANONID','INT','DOUBLE','STRING','CHARVECTOR','BANG'...
    ,'BREAK','CONTINUE','RETURN','TRANS','DOTTRANS','NOT','UMINUS','UPLUS'...
    ,'PARENS','AT','EXPR','PRINT','QUEST','GLOBAL','PERSISTENT','LB','LC'...
    ,'PLUS','MINUS','MUL','DIV','LDIV','EXP','DOTMUL','DOTDIV','DOTLDIV'...
    ,'DOTEXP','AND','OR','ANDAND','OROR','LT','GT','LE','GE','EQ','NE'...
    ,'CALL','SUBSCR','DCALL','EQUALS','COLON','CELL','DOT','DOTLP','ROW'...
    ,'IF','ELSEIF','ELSE','SWITCH','CASE','OTHERWISE','WHILE','FOR'...
    ,'PARFOR','SPMD','TRY','CATCH','FUNCTION','ANON','CLASSDEF','PROPERTIES'...
    ,'ATTRIBUTES','ATTR','METHODS','EVENTS','ENUMERATION','ATBASE','PROTO'});
end