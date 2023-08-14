classdef ConstAnnotator<internal.mtree.analysis.ConstAnnotator








    methods(Static)

        function messages=run(functionInfoRegistry)
            import internal.mtree.analysis.ConstAnnotator.*

            messages=internal.mtree.Message.empty;
            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            analyzers=containers.Map();

            assert(numel(fcnTypeInfos)==1,'Fcn block expects only one function')
            functionTypeInfo=fcnTypeInfos{1};
            analyzer=internal.ml2pir.fcn.ConstAnnotator(functionTypeInfo,functionInfoRegistry,analyzers);
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

    methods(Access=public)

        function nodeDescriptor=visitID(this,node,~)
            varName=node.string;
            nodeDescriptor=this.getVarDescriptor(varName);

            if~nodeDescriptor.type.isScalar&&~strcmp(node.Parent.kind,'SUBSCR')





                scalarType=nodeDescriptor.type.copy;
                scalarType.setDimensions([1,1]);
                nodeDescriptor.type=scalarType;
            end

            this.setNodeDescriptor(node,nodeDescriptor);
        end

    end

    methods(Access=protected)

        function type=getTypeFromMTree(this,node,~)
            type=internal.mtree.type.UnknownType;
            if strcmp(node.kind,'ID')

                varInfo=this.FunctionTypeInfo.getVarInfo(node.tree2str);
                if~isempty(varInfo)
                    type=internal.mtree.Type.fromVarTypeInfo(varInfo);
                end
            end
        end

        function descriptor=nodeEval(this,node,inputs,numOut)
            if nargin<4
                numOut=1;
            end

            descriptor=internal.ml2pir.fcn.EvalExpr.NodeEval(...
            node,inputs,numOut,this);
        end

    end
end



