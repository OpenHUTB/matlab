classdef ConstAnnotator<internal.mtree.analysis.ConstAnnotator








    methods(Static)

        function run(functionInfoRegistry)
            import internal.mtree.analysis.ConstAnnotator.*

            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            analyzers=containers.Map();

            assert(numel(fcnTypeInfos)==1,'If/Merge block expects only one function')
            functionTypeInfo=fcnTypeInfos{1};
            analyzer=internal.ml2pir.ifmerge.ConstAnnotator(functionTypeInfo,functionInfoRegistry,analyzers);
            analyzers(fcnTypeInfos{1}.specializationName)=analyzer;
            topLevelAnalyzers={analyzer};

            analyzers=analyzers.values();


            warnStates=warning('off','all');

            runAll(topLevelAnalyzers,analyzers);


            for i=1:numel(warnStates)
                s=warnStates(i);
                warning(s.state,s.identifier);
            end
        end

    end

    methods(Access=protected)

        function type=getTypeFromMTree(this,node,~)
            if strcmp(node.kind,'ID')
                [~,type]=this.getTypeFromIDNode(node);
            else







                varNodes=mtfind(node.Tree,'Kind','ID');
                varIndices=varNodes.indices;
                numVars=numel(varIndices);

                subscrNodes=mtfind(node.Tree,'Kind','SUBSCR');
                subscrIndices=subscrNodes.indices;
                numSubscrs=numel(subscrIndices);

                replacements=cell(1,2*(numVars+numSubscrs));
                replIdx=1;

                for i=1:numVars



                    varNode=varNodes.select(varIndices(i));
                    [hasType,tp]=this.getTypeFromIDNode(varNode);

                    if hasType&&tp.supportsExampleValues
                        replacements{replIdx}=varNode;
                        replacements{replIdx+1}=tp.getExampleValueString;
                        replIdx=replIdx+2;
                    end
                end

                for i=1:numSubscrs


                    subscrNode=subscrNodes.select(subscrIndices(i));
                    [hasReplacement,subscrStr]=this.getSubscrStr(subscrNode);

                    if hasReplacement
                        replacements{replIdx}=subscrNode;
                        replacements{replIdx+1}=subscrStr;
                        replIdx=replIdx+2;
                    end
                end

                replacements(replIdx:end)=[];



                [evalWorks,result]=this.doEval(node.tree2str(0,1,replacements));

                if evalWorks
                    type=internal.mtree.Type.fromValue(result);
                else
                    type=internal.mtree.type.UnknownType;
                end
            end
        end
    end

    methods(Access=private)

        function[hasType,type]=getTypeFromIDNode(this,node)
            hasType=false;
            type=internal.mtree.type.UnknownType;

            varInfo=this.FunctionTypeInfo.getVarInfo(node.tree2str);
            if~isempty(varInfo)
                hasType=true;
                type=internal.mtree.Type.fromVarTypeInfo(varInfo);
            end
        end



        function[isValidStr,str]=getSubscrStr(this,subscrNode)
            isValidStr=false;
            str='';

            matrixType=this.getTypeFromMTree(subscrNode.Left);
            if~matrixType.supportsExampleValues
                return;
            end
            exMatrixVal=matrixType.getExampleValue;

            numIdxs=count(subscrNode.Right);
            idxNode=subscrNode.Right;
            exIdxVals=cell(1,numIdxs);

            for i=1:numIdxs
                idxType=this.getTypeFromMTree(idxNode);
                if idxType.isLogical

                    return;
                end



                exIdxVals{i}=ones(idxType.Dimensions);
            end

            try
                exVal=exMatrixVal(exIdxVals{:});
            catch
                return
            end

            isValidStr=true;
            str=internal.mtree.formatConstValStr(exVal);
        end



        function[evalWorks,val]=doEval(~,str)
            try
                val=eval(str);
                evalWorks=true;
            catch
                val=[];
                evalWorks=false;
            end
        end
    end
end



