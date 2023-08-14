function[F,S]=getSymbolNames(filename)
















    S={};
    F={};

    mt=matlab.depfun.internal.cacheMtree(filename);
    if isempty(mt)
        return;
    end
    isScript=(mt.FileType==mtree.Type.ScriptFile);







    dotNodes=mtfind(mt,'Kind','DOT');
    fileLvlInfo.dotIDs=indices(dotNodes);



    allFunOrClsNodes=mt.mtfind('Isfunorclass',true)|mt.mtfind('Kind','QUEST').Arg;
    allFunOrClsIDs=indices(allFunOrClsNodes);

    dotQualifiedFunOrClsNodes=mtfind(allFunOrClsNodes,'Parent.Kind','DOT');
    fileLvlInfo.dotQualifiedFunOrClsIDs=indices(dotQualifiedFunOrClsNodes);




    atBaseNodes=mtfind(allFunOrClsNodes,'Parent.Kind','ATBASE');
    if~isempty(atBaseNodes)


        atBaseIDs=indices(atBaseNodes);
        allFunOrClsIDs=setdiff(allFunOrClsIDs,atBaseIDs);
        fileLvlInfo.dotQualifiedFunOrClsIDs=setdiff(fileLvlInfo.dotQualifiedFunOrClsIDs,atBaseIDs);
    end

    fileLvlInfo.nonDotQualifiedFunOrClsIDs=setdiff(allFunOrClsIDs,fileLvlInfo.dotQualifiedFunOrClsIDs);
    fileLvlInfo.nonDotQualifiedFunOrClsSyms=strings(select(mt,fileLvlInfo.nonDotQualifiedFunOrClsIDs));



    funs=mtfind(mt,'Kind','FUNCTION');
    fids=indices(funs);
    nfids=length(fids);
    if~isempty(fids)


        methods=List(Body(mtfind(mt,'Kind','METHODS')));
        if~isempty(methods)
            mids=indices(methods);
            F=strings(Fname(select(funs,setdiff(fids,mids))));
        else
            F=strings(Fname(funs));
        end



        [~,namepart,~]=fileparts(filename);
        F(strcmp(F,namepart))=[];
    end










    flag_TooManyLocalFunctions=false;

    if nfids>100
        flag_TooManyLocalFunctions=true;

        imptNode=mtfind(mt,'String','import');
        toBeTrimed=[];
        if~isempty(imptNode)
            imptIdx=indices(imptNode);

            imptfids=[];
            for i=1:length(imptIdx)

                dcallNode=trueparent(select(mt,imptIdx(i)));

                fcnNode=trueparent(dcallNode);

                if strcmp(kind(fcnNode),'FUNCTION')
                    imptfids=[imptfids,indices(fcnNode)];
                end
            end
            fids=unique(imptfids);
            nfids=length(fids);
        else

            nfids=0;
        end
    end

    if isScript
        nfids=nfids+1;
    end

    S=cell(nfids,1);

    for j=1:nfids
        if isScript&&j==nfids

            T=not(Tree(mtfind(mt,'Kind','FUNCTION')));
        else

            id=fids(j);
            T=Tree(select(mt,id));


            if flag_TooManyLocalFunctions
                toBeTrimed=[toBeTrimed,indices(T)];
            end
            T=removeFnameNodeFromSubTree(T,id);
        end

        tS=getSymbolNamesInSubTree(T,fileLvlInfo);

        [tI,tIstar]=getImportList(T);



        for k=1:length(tI)
            if isempty(matlab.depfun.internal.cacheWhich(tI{k}))
                error(message('MATLAB:depfun:req:BadImport',tI{k},filename))
            end
        end




        dots=strfind(tI,'.');
        importSimpleName=cell(length(tI),1);
        importPrefix=cell(length(tI),1);
        for k=1:length(tI)
            if~isempty(dots{k})
                importSimpleName{k,1}=tI{k}(dots{k}(end)+1:end);
                importPrefix{k,1}=tI{k}(1:dots{k}(end));
            else



                importSimpleName{k,1}=tI{k};
                importPrefix{k,1}='';
            end
        end
        tSFirstName=tS;
        for k=1:length(tS)
            dotIdx=find(tSFirstName{k}=='.');
            if~isempty(dotIdx)
                tSFirstName{k}(dotIdx(1):end)=[];
            end
        end
        [IA,IB]=ismember(tSFirstName,importSimpleName);
        for k=1:length(IA)
            if IA(k)
                tS{k}=[importPrefix{IB(k)},tSFirstName{k}];
            end
        end


        remainInds=1:length(tS);
        remainInds(IA)=[];
        nImports=length(tIstar);
        for k=remainInds
            sym=tS{k};
            for n=1:nImports
                symWithImport=[tIstar{n},sym];
                f=which(symWithImport);
                if~isempty(f)
                    tS{k}=symWithImport;
                    break;
                end
            end
        end


        S{j}=tS;
    end


    if flag_TooManyLocalFunctions
        wholeTree=indices(mt);
        wholeTree(toBeTrimed)=[];
        newTree=select(mt,wholeTree);
        newTree=removeFnameNodeFromSubTree(newTree);
        RS=getSymbolNamesInSubTree(newTree,fileLvlInfo);
    else
        RS={};
    end




    nA=mtfind(mt,'Kind','ATTR');
    idsA=indices(nA);
    pAS={};
    for id=idsA
        nAR=Right(select(mt,id));
        as=getSymbolNamesInAttribute(Tree(nAR),fileLvlInfo);

        if~any(ismember({'public';'protected';'private';'immutable'},as))
            pAS=[pAS,as];
        end
    end
    if~isempty(pAS)&&~isempty(F)

        attr_fcn_idx=ismember(F,pAS);
        F(attr_fcn_idx)=[];
    end






    nP=mtfind(mt,'Kind','PROPERTIES');
    idsP=indices(nP);
    PS={};
    for id=idsP
        nPR=mtfind(Tree(select(mt,id)),'Kind','EQUALS');
        if~isempty(nPR)
            PS=[PS,getSymbolNamesInSubTree(Tree(nPR),fileLvlInfo)];
        end
    end




    nE=mtfind(mt,'Kind','ENUMERATION');
    idsE=indices(nE);
    ES={};
    for id=idsE
        nER=mtfind(Tree(select(mt,id)),'Kind','LP');
        if~isempty(nER)

            idsnER=indices(nER);
            for k=1:length(idsnER)




                eNode=Tree(Right(select(mt,idsnER(k))));
                while~isempty(eNode)
                    ES=[ES,getSymbolNamesInSubTree(eNode,fileLvlInfo)];
                    eNode=Tree(Next(eNode));
                end
            end
        end
    end


    SC={};
    c=mtfind(mt,'Kind','CLASSDEF');
    if~isempty(c)
        cn=Cexpr(c);
        ltSym=mtfind(Tree(cn),'Kind','LT');
        if~isempty(ltSym)
            SC=getSymbolNamesInSubTree(Tree(Right(ltSym)),fileLvlInfo);
            [tf,remove]=ismember('handle',SC);
            if tf
                SC(remove)=[];
            end
        end
    end


    nCMT=mtfind(mt,'Kind','COMMENT');
    CMTstr=strings(nCMT);

    PRGM=processPragmas('function',CMTstr);
    PRGMX=processPragmas('exclude',CMTstr);


    PRGMX=stripDotMExt(PRGMX);
    PRGM=stripDotMExt(PRGM);
    PRGMX=setdiff(PRGMX,PRGM);


    isSchemaDotM=~isempty(regexp(filename,'schema.m$','ONCE'));

    bcS={};
    if isSchemaDotM

        sc_node=mtfind(mt,'Kind','DOT','Left.String','schema','Right.String','class');

        bc_node=Next(Next(Right(trueparent(sc_node))));

        if~isempty(bc_node)
            bcS=findUDDBaseClass(mt,bc_node);
        end
    end


    smS={};
    if isSchemaDotM

        schema_method_node=mtfind(mt,'Kind','DOT','Left.String','schema','Right.String','method');
        if~isempty(schema_method_node)

            cl_name=getQualifiedClsName(filename);

            method_name_node=Next(Right(trueparent(schema_method_node)));
            method_name_id=indices(method_name_node);
            for id=method_name_id
                cwn=select(mt,id);
                if~isempty(cwn)&&strcmp(kind(cwn),'CHARVECTOR')
                    method_name=strings(cwn);
                    method_name=method_name{1};
                    if method_name(1)==''''&&method_name(end)==''''
                        method_name=method_name(2:end-1);
                    end

                    if~isempty(cl_name)
                        qualified_method_name=[cl_name,'.',method_name];
                    else
                        qualified_method_name=method_name;
                    end

                    smS=[smS,qualified_method_name];
                end
            end
        end
    end


    spS={};
    if isSchemaDotM




        schema_prop_node=mtfind(mt,'Kind','DOT','Left.String','schema',...
        'Right.String','prop');
        if~isempty(schema_prop_node)

            prop_type_node=Next(Next(Right(trueparent(schema_prop_node))));
            prop_type_id=indices(prop_type_node);
            for id=prop_type_id
                tn=select(mt,id);


                if~isempty(tn)&&strcmp(kind(tn),'CHARVECTOR')

                    type_name=strings(tn);

                    type_name=type_name{1};

                    if type_name(1)==''''&&type_name(end)==''''
                        type_name=type_name(2:end-1);
                    end




                    space=strfind(type_name,' ');
                    if~isempty(space)
                        type_name=type_name(1:space-1);
                    end


                    if analyzableName(type_name)
                        spS=[spS,type_name];
                    end
                end
            end
        end
    end

    iconS={};
    if~isempty(regexp(filename,'.+\.mlapp$','ONCE'))
        icon_nodes=mtfind(mt,'Kind','EQUALS','Left.Right.String',{'Icon','ImageSource'});
        if~isempty(icon_nodes)
            icon_node_ids=indices(icon_nodes);
            for k=1:length(icon_node_ids)
                iconNode=select(mt,icon_node_ids(k));
                iconFileNode=iconNode.Right;
                if strcmp(kind(iconFileNode),'CHARVECTOR')
                    icon_file_str=string(iconFileNode);

                    if~strcmp(icon_file_str,'''''')
                        iconS{end+1}=icon_file_str(2:end-1);
                    end
                end
            end
        end
    end



    if matlab.depfun.internal.requirementsSettings.isDataDetectionOn()
        fileStruct=...
        matlab.depfun.internal.extractFileReferencedAsString(filename);
    else
        fileStruct={};
    end
    fileS={};
    if~isempty(fileStruct)
        fileS={fileStruct.symbol};


        ignoreIdx=contains(fileS,'/')...
        |contains(fileS,matlab.depfun.internal.requirementsConstants.FileSep);
        fileS(ignoreIdx)=[];
    end

    S=[S{:},RS,pAS(:)',SC(:)',PS(:)',ES(:)',PRGM(:)',bcS,smS,spS,iconS,fileS]';
    S=setdiff(S,PRGMX);
    S=unique(S);
    S=checkAlias(S);
end

function tf=analyzableName(type)
    persistent skipNames;
    if isempty(skipNames)
        uddPropTypes={'MATLAB';'mxArray';'int';'string';'bool';...
        'ustring';'on/off';'MATLAB array';'posint';'posdouble'};
        skipNames=[...
        matlab.depfun.internal.requirementsConstants.matlabBuiltinClasses;...
        uddPropTypes];
    end
    tf=~any(strcmp(skipNames,type));
end


function bcS=findUDDBaseClass(T,bcNode)





    bcName='';
    pkgName='';
    bcS=[];
    if strcmp(kind(bcNode),'ID')

        clsHNode=mtfind(T,'Kind','EQUALS','Left.String',string(bcNode));
        real_bcNode=Right(clsHNode);
        bcS=findUDDBaseClass(T,real_bcNode);
    elseif strcmp(kind(bcNode),'SUBSCR')...
        &&strcmp(kind(Left(bcNode)),'DOT')...
        &&strcmp(string(Right(Left(bcNode))),'findclass')
        bcName=string(Right(bcNode));
        pkgH=Left(Left(bcNode));
        pkgHNode=mtfind(T,'Kind','EQUALS','Left.String',string(pkgH),...
        'Right.Left.String','findpackage');
        pkgName=findUDDPkgName(pkgHNode);
    elseif strcmp(kind(bcNode),'CALL')...
        &&strcmp(string(Left(bcNode)),'findclass')
        if strcmp(kind(Right(bcNode)),'CHARVECTOR')
            bcName=string(Right(bcNode));
            pkgH=Right(trueparent(bcNode));
            if strcmp(kind(pkgH),'ID')
                pkgHNode=mtfind(T,'Kind','EQUALS','Left.String',string(pkgH),...
                'Right.Left.String','findpackage');
            else
                pkgHNode=mtfind(T,'Kind','EQUALS','Left.Kind','ID',...
                'Right.Left.String','findpackage');
            end
            pkgName=findUDDPkgName(pkgHNode);
        elseif strcmp(kind(Right(bcNode)),'CALL')...
            &&strcmp(string(Left(Right(bcNode))),'findpackage')
            bcName=string(Next(Right(bcNode)));
            pkgName=findUDDPkgName(bcNode);
        elseif strcmp(kind(Right(bcNode)),'ID')...
            &&strcmp(kind(Next(Right(bcNode))),'CHARVECTOR')
            bcName=string(Next(Right(bcNode)));
            pkgH=Right(bcNode);
            pkgHNode=mtfind(T,'Kind','EQUALS','Left.String',string(pkgH),...
            'Right.Left.String','findpackage');
            pkgName=findUDDPkgName(pkgHNode);
        end
    end

    if~isempty(bcName)&&~isempty(pkgName)
        bcName=bcName(2:end-1);
        pkgName=pkgName(2:end-1);
        bcS=[pkgName,'.',bcName];
    end
end

function pkgName=findUDDPkgName(pkgHNode)
    pkgName='';
    if~isempty(pkgHNode)
        pkgHNodeIdx=indices(pkgHNode);
        pkgHNode=select(pkgHNode,pkgHNodeIdx(end));
        if strcmp(string(Left(Right(pkgHNode))),'findpackage')
            pkgName=string(Right(Right(pkgHNode)));
        end
    end
end

function T=removeFnameNodeFromSubTree(T,fcnNodeIdx)

    if nargin<2
        fcnNode=mtfind(T,'Kind','FUNCTION');
    else
        fcnNode=select(T,fcnNodeIdx);
    end
    if~isempty(fcnNode)
        fnameNodeIdx=indices(fcnNode.Fname);
        orgIdx=indices(T);
        newIdx=setdiff(orgIdx,fnameNodeIdx);
        T=select(T,newIdx);
    end
end

function tS=getSymbolNamesInSubTree(T,fileLvlInfo)




















    ids=indices(T.mtfind('Isfunorclass',true)|T.mtfind('Kind','QUEST').Arg);
    tS1=fileLvlInfo.nonDotQualifiedFunOrClsSyms(...
    ismember(fileLvlInfo.nonDotQualifiedFunOrClsIDs,ids));

    dotQualifiedIds=ids(ismember(ids,fileLvlInfo.dotQualifiedFunOrClsIDs));
    tS2=cell(1,length(dotQualifiedIds));
    for k=1:length(dotQualifiedIds)
        tS2{k}=getFullName(T,dotQualifiedIds(k),fileLvlInfo.dotIDs);
    end
    tS2(cellfun('isempty',tS2))=[];
    tS=unique([tS1,tS2]);
end

function tS=getSymbolNamesInAttribute(T,fileLvlInfo)


    ids=indices(T.mtfind('Kind','ID')|T.mtfind('Kind','QUEST').Arg);
    tS=cell(1,length(ids));
    for k=1:length(ids)
        tS{k}=getFullName(T,ids(k),fileLvlInfo.dotIDs);
    end
    tS(cellfun('isempty',tS))=[];
    tS=unique(tS);
end

function[I,Istar]=getImportList(T)





    IN=Right(mtfind(T,'Kind','DCALL','Left.String','import'));



    importStr=strings(List(IN));
    I={};
    Istar={};
    for k=1:numel(importStr)
        processImportStr(importStr{k});
    end

    function processImportStr(importStr)
        if importStr(end)=='*'
            Istar{end+1,1}=importStr(1:end-1);
        else
            I{end+1,1}=importStr;
        end
    end
end

function clsName=getQualifiedClsName(filename)
    clsName='';
    [pth,~,~]=fileparts(filename);





    chop=regexp(pth,'[/\\][@+]','ONCE');
    if~isempty(chop)
        prefix=pth(chop+2:end);


        clsName=regexprep(prefix,'[/\\][@+]','.');
    end
end

function symbolList=processPragmas(pragmaType,CMTstr)
    expr1=['^\s*%#\s*',pragmaType,'\s+(?<fname>\w[\w\.]*[^\s])\s*((?=\().+\)|\s*)$'];
    expr2='\s+(?<fname>\w[\w\.]*)';
    pragmaIdx=~cellfun('isempty',regexp(CMTstr,['^\s*%#\s*',pragmaType,'\s+'],'ONCE'));
    pragmaStr=CMTstr(pragmaIdx);
    symbolList={};
    for k=1:numel(pragmaStr)
        prgmFCN=regexp(pragmaStr{k},expr1,'names');
        if~isempty(prgmFCN)
            symbolList=[symbolList,prgmFCN.fname];%#ok
        else
            prgmFCNs=regexp(pragmaStr{k},expr2,'names');
            if~isempty(prgmFCNs)
                symbolList=[symbolList,{prgmFCNs.fname}];%#ok
            end
        end
    end
end

function result=stripDotMExt(fileList)
    result=regexprep(fileList,...
    matlab.depfun.internal.requirementsConstants.analyzableMatlabFileExtPat,'');
end



