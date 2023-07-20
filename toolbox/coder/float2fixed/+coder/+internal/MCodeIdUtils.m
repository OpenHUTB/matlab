classdef MCodeIdUtils

    properties(Access=private)
fullFilePath
MTree
idInfoMap
    end

    methods
        function this=MCodeIdUtils(fullFilePath)
            this.fullFilePath=fullFilePath;
            this.MTree=mtree(fileread(fullFilePath));
            this.idInfoMap={};
        end

        function infoMap=computeFunctionInfo(this)

            fcnNodes=this.MTree.find('Kind','FUNCTION');
            fcnIndices=fcnNodes.indices;

            if(~isempty(fcnIndices))
                rootFcnIndex=fcnIndices(1);
                rootFcnName=string(this.MTree.select(rootFcnIndex).Fname);
            end

            for ii=1:length(fcnIndices)

                fcnNode=this.MTree.select(fcnIndices(ii));


                callNodes=fcnNode.Tree.mtfind('Kind',{'DCALL','CALL'});
                fname=string(fcnNode.Fname);

                idInfoStruct.fcnInfo=this.getFcnInfos(strings(Left(callNodes)),rootFcnName);


                varNodes=fcnNode.Tree.mtfind('Isvar',true);
                vars=unique(strings(varNodes));

                persistentVars=unique(strings(list(Arg(fcnNode.Tree.mtfind('Kind','PERSISTENT')))));
                inParams=strings(list(fcnNode.Ins));
                outParams=strings(list(fcnNode.Outs));



                indexVars=strings(Left(fcnNode.Tree.mtfind('Kind','SUBSCR','Right.Kind','CALL')));

                idInfoStruct.varInfo=this.getVarInfos(vars,inParams,outParams,persistentVars,indexVars);

                this.idInfoMap{end+1}={fname};
                this.idInfoMap{end}{end+1}=idInfoStruct;
            end

            infoMap=this.idInfoMap;
        end
    end
    methods(Access=private)

        function fcnInfos=getFcnInfos(this,fnames,parentFname)
            fcnInfos=cell(size(fnames));
            for ii=1:length(fnames)
                fcnInfos{ii}=this.createFcnInfo(fnames{ii},parentFname,this.fullFilePath);
            end
        end



        function variableInfos=getVarInfos(this,vars,inParams,outParams,persistentVars,indexVars)
            variableInfos=cell(size(vars));
            for ii=1:length(vars)
                varName=vars{ii};
                isin=any(strcmp(varName,inParams));
                isout=any(strcmp(varName,outParams));
                ispersistent=any(strcmp(varName,persistentVars));
                isindex=any(strcmp(varName,indexVars));
                istemp=~isin&&~isout&&~ispersistent;
                variableInfos{ii}=this.createVarInfo(vars{ii},isin,isout,istemp,ispersistent,isindex);
            end
        end

        function fcnInfo=createFcnInfo(~,fcnName,parentFname,parentFullPath)
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

        function varInfo=createVarInfo(~,varname,isin,isout,istemp,ispersistent,isindex)
            varInfo.varName=varname;
            varInfo.isinp=isin;
            varInfo.isout=isout;
            varInfo.istemp=istemp;
            varInfo.ispersistent=ispersistent;
            varInfo.isindex=isindex;
        end

    end
end