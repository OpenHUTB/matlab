classdef EvalExpr<internal.mtree.analysis.EvalExpr








    methods(Static)
        function nodeDescriptor=NodeEval(node,argDescriptors,numOutputs,...
            constAnnotator)
            import internal.ml2pir.fcn.EvalExpr.*

            assert(numOutputs==1,'Fcn block expressions can only have one output');

            argDescriptorsOrig=argDescriptors;
            argDescriptors=internal.mtree.analysis.expandDescriptors(argDescriptorsOrig);

            type=resolveUnknownType(node,argDescriptors,constAnnotator);

            origTypeUnknown=false;
            nodeDescriptor=NodeEvalImpl(node,argDescriptors,...
            argDescriptorsOrig,type,numOutputs,constAnnotator,origTypeUnknown);
        end
    end

    methods(Static,Access=protected)
        function retType=resolveUnknownType(node,argDescriptors,constAnnotator)
            type=resolveUnknownType@internal.mtree.analysis.EvalExpr(node,argDescriptors,constAnnotator);

            if~type.isFloat
                nonConstArgs=argDescriptors(cellfun(@(x)~x.isConst,argDescriptors));
                if~isempty(nonConstArgs)

                    retType=nonConstArgs{1}.type.copy;
                    if~type.isUnknown



                        retType.setDimensions(type.Dimensions);
                    end
                else


                    retType=type;
                end
            else

                retType=type;
            end
        end
    end
end

