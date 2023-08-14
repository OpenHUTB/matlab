














































function infoMap=MLFcnInfo(fullFilePath)


    MTree=mtree(fileread(fullFilePath));
    idInfoMap=containers.Map();

    infoMap=computeFunctionInfo;

    function infoMap=computeFunctionInfo

        fcnNodes=MTree.find('Kind','FUNCTION');
        fcnIndices=fcnNodes.indices;

        if(~isempty(fcnIndices))
            rootFcnIndex=fcnIndices(1);
            rootFcnName=string(MTree.select(rootFcnIndex).Fname);
        end

        for ii=1:length(fcnIndices)

            fcnNode=MTree.select(fcnIndices(ii));



            fname=string(fcnNode.Fname);




            varNodes=fcnNode.Tree.mtfind('Isvar',true);
            vars=unique(strings(varNodes));

            persistentVars=unique(strings(list(Arg(fcnNode.Tree.mtfind('Kind','PERSISTENT')))));
            inParams=strings(list(fcnNode.Ins));
            outParams=strings(list(fcnNode.Outs));



            indexVars=strings(Left(fcnNode.Tree.mtfind('Kind','SUBSCR','Right.Kind','ID')));
            loopIndexVars=strings(Index(fcnNode.Tree.mtfind('Kind','FOR','Index.Kind','ID')));
            globalVars=unique(strings(list(Arg(fcnNode.Tree.mtfind('Kind','GLOBAL')))));

            varInfo=getVarInfos(vars,inParams,outParams,persistentVars,indexVars,loopIndexVars,globalVars);



            idInfoStruct.inputVars={varInfo(([varInfo.isin]==1)').varName};
            idInfoStruct.outputVars={varInfo(([varInfo.isout]==1)').varName};
            idInfoStruct.persistentVars={varInfo(([varInfo.ispersistent]==1)').varName};
            idInfoStruct.loopIdxVars={varInfo(([varInfo.isloopidx]==1)').varName};
            idInfoStruct.tempVars={varInfo(([varInfo.istemp]==1)').varName};
            idInfoStruct.globalVars={varInfo(([varInfo.isglobal]==1)').varName};

            idInfoMap(fname)=idInfoStruct;
        end

        infoMap=idInfoMap;
    end


    function fcnInfos=getFcnInfos(fnames,parentFname)

        fcnInfos=struct('fcnname',{},'fullpath',{},'issubfcn',{},'isundefined',{},'isbuiltin',{});
        for ii=1:length(fnames)
            fcnInfos(ii)=createFcnInfo(fnames{ii},parentFname,fullFilePath);
        end
    end



    function variableInfos=getVarInfos(vars,inParams,outParams,persistentVars,indexVars,loopIdxVars,globalVars)
        isin=cell(size(vars));
        isout=cell(size(vars));
        ispersistent=cell(size(vars));
        isindex=cell(size(vars));
        istemp=cell(size(vars));
        isloopidx=cell(size(vars));
        isglobalidx=cell(size(vars));

        for ii=1:length(vars)
            varName=vars{ii};
            isin{ii}=any(strcmp(varName,inParams));
            isout{ii}=any(strcmp(varName,outParams));
            ispersistent{ii}=any(strcmp(varName,persistentVars));
            isindex{ii}=any(strcmp(varName,indexVars));
            isglobalidx{ii}=any(strcmp(varName,globalVars));
            istemp{ii}=~isin{ii}&&~isout{ii}&&~ispersistent{ii}&&~isglobalidx{ii};
            isloopidx{ii}=any(strcmp(varName,loopIdxVars));
        end
        variableInfos=struct('varName',vars,...
        'isin',isin,...
        'isout',isout,...
        'ispersistent',ispersistent,...
        'isindex',isindex,...
        'istemp',istemp,...
        'isloopidx',isloopidx,...
        'isglobal',isglobalidx);
    end

    function fcnInfo=createFcnInfo(fcnName,parentFname,parentFullPath)
        fcnInfo.fcnname=fcnName;


        if(~isempty(parentFname))

            fcnInfo.fullpath=which(fcnName,'in',parentFname);
        end

        if isempty(fcnInfo.fullpath)
            fcnInfo.fullpath=coder.internal.Helper.which(fcnName);
            fcnInfo.issubfcn=false;
        else
            if(strfind(fcnInfo.fullpath,parentFullPath))
                fcnInfo.issubfcn=true;
            else
                fcnInfo.issubfcn=false;
            end
        end

        fcnInfo.isundefined=false;

        if(isempty(fcnInfo.fullpath))
            fcnInfo.isundefined=true;
        end

        if~isempty(regexp(fcnInfo.fullpath,'^built-in','once'))
            fcnInfo.isbuiltin=true;
        else
            fcnInfo.isbuiltin=false;
        end

    end
end




