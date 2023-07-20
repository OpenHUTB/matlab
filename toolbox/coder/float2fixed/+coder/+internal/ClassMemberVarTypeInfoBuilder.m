classdef ClassMemberVarTypeInfoBuilder<coder.internal.MTreeVisitor




    properties
FcnMTree
FcnMTreeAttributes
FcnExprMap
FcnTypeInfo
MxInfos
PropertyDependencies
MxArrays
    end

    methods(Access=public)
        function this=ClassMemberVarTypeInfoBuilder()
            this.FcnMTree=0;
            this.FcnTypeInfo=0;
        end

        function run(this,fcnMTreeAttributes,mxInfoLocations,MxInfos,fcnTypeInfo,propertyDependencies,MxArrays)
            this.FcnMTree=fcnTypeInfo.tree;
            this.FcnMTreeAttributes=fcnMTreeAttributes;
            this.FcnExprMap=[];
            this.MxInfos=MxInfos;
            this.FcnTypeInfo=fcnTypeInfo;

            this.buildExprMap(mxInfoLocations);
            this.PropertyDependencies=propertyDependencies;
            this.MxArrays=MxArrays;

            if~isempty(this.FcnMTree)
                this.visit(this.FcnMTree,[]);
            end
        end

        function buildExprMap(this,mxInfoLocations)
            this.FcnExprMap=containers.Map('KeyType','double','ValueType','any');
            if isempty(mxInfoLocations)
                return;
            end
            if isa(mxInfoLocations(1),'fixed.internal.InstrumentedMxInfoLocation')
                offset=0;
            else
                offset=1;
            end
            for kk=1:length(mxInfoLocations)
                mxLocInfo=mxInfoLocations(kk);
                v.leftpos=mxLocInfo.TextStart+offset;
                v.rightpos=v.leftpos+mxLocInfo.TextLength-1;
                v.mxLocInfo=mxLocInfo;

                if this.FcnExprMap.isKey(v.leftpos)
                    if isa(mxLocInfo,'fixed.internal.InstrumentedMxInfoLocation')
                        if any(isinf(mxLocInfo.SimMin))||any(isinf(mxLocInfo.SimMax))


                            continue;
                        end
                    end
                    pv=this.FcnExprMap(v.leftpos);
                    if v.rightpos>pv.rightpos
                        this.FcnExprMap(v.leftpos)=v;
                    end
                else
                    this.FcnExprMap(v.leftpos)=v;
                end
            end
        end
    end

    methods
        function propertyPath=getPropertyPath(this,memberAccessExpr)
            propertyPath=[];

            exprs=strsplit(memberAccessExpr,'.');
            if numel(exprs)==1

                return;
            end
            baseVarName=exprs{1};

            baseVarInfos=this.FcnTypeInfo.getVarInfosByName(baseVarName);
            if~isempty(baseVarInfos)&&baseVarInfos{1}.isMCOSClass()
                exprs{1}=baseVarInfos{1}.inferred_Type.Class;
                propertyPath=strjoin(exprs,'.');
            end
        end
    end

    methods(Access=public)
        function out=visitEQUALS(this,assignNode,input)%#ok<INUSD>
            out=[];
            lhs=assignNode.Left;
            rhs=assignNode.Right;

            if strcmp(lhs.kind,'SUBSCR')


                lhs=lhs.Left;
            end

            if strcmp(rhs.kind,'SUBSCR')


                rhs=rhs.Left;
            end

            if lhs.iskind('LB')

                return;
            end

            if~lhs.iskind('DOT')

                return;
            end

            objNode=lhs.Left;
            if~objNode.iskind('ID')


            end


            objName=strtrim(objNode.tree2str(0,1));
            objVarInfos=this.FcnTypeInfo.getVarInfosByName(objName);
            if isempty(objVarInfos)

                return;
            end
            assert(~isempty(objVarInfos));
            if~objVarInfos{1}.isMCOSClass()

                return;
            end

            if~this.FcnExprMap.isKey(rhs.lefttreepos)


                return;
            end


            memberAccessExpr=strtrim(lhs.tree2str(0,1));
            varInfos=this.FcnTypeInfo.getVarInfosByFullVarName(memberAccessExpr);
            if isempty(varInfos)

                varLogInfo.SymbolName=memberAccessExpr;
                varLogInfo.SimMin=[];
                varLogInfo.SimMax=[];
                varLogInfo.DesignIsInteger=[];
                varLogInfo.IsAlwaysInteger=0;
                varLogInfo.IsArgin=false;
                varLogInfo.IsOutputArg=false;
                isCoderConst=false;

                v=this.FcnExprMap(rhs.lefttreepos);
                rhsMxLocInfo=v.mxLocInfo;
                inferredInfo=coder.internal.FcnInfoRegistryBuilder.getMappedInferredTypeInfo(...
                rhsMxLocInfo.MxInfoID,this.MxInfos,this.MxArrays);
                varLogInfo.MxInfoID=rhsMxLocInfo.MxInfoID;
                if(strcmp(inferredInfo.Class,'struct'))
                    varLogInfo.IsAlwaysInteger=[];
                    varLogInfo.LoggedFieldNames={};
                    varLogInfo.LoggedFieldMxInfoIDs={};
                    varLogInfo.LoggedFieldsInferredTypes={};
                    varLogInfo.nestedStructuresInferredTypes=coder.internal.lib.Map();

                    varLogInfo=coder.internal.FcnInfoRegistryBuilder.addStructField(varLogInfo,...
                    varLogInfo.SymbolName,rhsMxLocInfo.MxInfoID,...
                    this.MxInfos,...
                    this.MxArrays);
                end

                varTypeInfo=coder.internal.VarTypeInfo(varLogInfo,inferredInfo,isCoderConst);
                varTypeInfo.TextStart=lhs.lefttreepos;
                varTypeInfo.TextLength=lhs.righttreepos-lhs.lefttreepos+1;
                varTypeInfo.MxInfoLocationId=0;




                varTypeInfo.Synthesized=true;
                varTypeInfo.IsAlwaysInteger=true;
                this.FcnTypeInfo.addVarInfo(memberAccessExpr,varTypeInfo);

                return;
            end

            varInfos=this.FcnTypeInfo.getVarInfosByName(memberAccessExpr);

            if~varInfos{1}.Synthesized



            end

            v=this.FcnExprMap(rhs.lefttreepos);
            rhsMxLocInfo=v.mxLocInfo;

            if varInfos{1}.isMCOSClass||varInfos{1}.isStruct
                return;
            end

            if isa(rhsMxLocInfo,'fixed.internal.InstrumentedMxInfoLocation')
                if isempty(rhsMxLocInfo.SimMin)||isinf(rhsMxLocInfo.SimMin)||...
                    isempty(rhsMxLocInfo.SimMax)||isinf(rhsMxLocInfo.SimMax)
                    if strcmp(rhs.kind,'DOT')

                        lhsPropertyPath=this.getPropertyPath(lhs.tree2str(0,1));
                        assert(~isempty(lhsPropertyPath));

                        rhsPropertyPath=this.getPropertyPath(rhs.tree2str(0,1));
                        if numel(strfind(rhsPropertyPath,'.'))>1



                            return;
                        end

                        if strcmp(lhsPropertyPath,rhsPropertyPath)

                            return;
                        end

                        if~isempty(rhsPropertyPath)

                            if this.PropertyDependencies.isKey(rhsPropertyPath)
                                deps=this.PropertyDependencies(rhsPropertyPath);
                            else
                                deps={};
                            end
                            deps{end+1}=lhsPropertyPath;
                            deps=unique(deps);
                            this.PropertyDependencies(rhsPropertyPath)=deps;
                        end
                    end
                end
                for ii=1:length(varInfos)
                    varInfo=varInfos{ii};
                    if~isempty(varInfo.SimMin)
                        varInfo.SimMin=min(varInfo.SimMin,rhsMxLocInfo.SimMin);
                    else
                        varInfo.SimMin=rhsMxLocInfo.SimMin;
                    end

                    if~isempty(varInfo.SimMax)
                        varInfo.SimMax=max(varInfo.SimMax,rhsMxLocInfo.SimMax);
                    else
                        varInfo.SimMax=rhsMxLocInfo.SimMax;
                    end

                    varInfo.IsAlwaysInteger=rhsMxLocInfo.IsAlwaysInteger;
                end
            end
        end
    end
end


