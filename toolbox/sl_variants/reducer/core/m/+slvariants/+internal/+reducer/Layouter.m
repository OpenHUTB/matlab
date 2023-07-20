classdef(Sealed,Hidden)Layouter<handle




    methods(Static,Access=public)

        function placeLayers(graphPath)
            Simulink.internal.variantlayout.LayoutManager(graphPath).placeLayers();
        end

    end

    methods(Access=public)

        function obj=Layouter()
            obj.BDToAutoLayoutInfo=containers.Map('keytype','char','valuetype','any');
        end

        function delete(obj)
            obj.BDToAutoLayoutInfo=containers.Map('keytype','char','valuetype','any');
        end

        function saveAnnotationInfoBeforeReduction(obj,bdToAutoLytInfo)





            for key=keys(bdToAutoLytInfo)
                bdName=key{1};
                graphToAnnotInfo=bdToAutoLytInfo(bdName);
                graphToAnnotArea=obj.getGraphToAnnotationArea(graphToAnnotInfo);
                obj.BDToAutoLayoutInfo(bdName)=graphToAnnotArea;
            end
        end

        function layoutGraphs(obj,bdToAutoLytInfo)
            for key=keys(bdToAutoLytInfo)
                bdName=key{1};

                origGraphToAnnot=obj.BDToAutoLayoutInfo(bdName);
                reducedGraphToAnnot=bdToAutoLytInfo(bdName);
                obj.resizeAreaAnnotaionsInGraph(origGraphToAnnot,reducedGraphToAnnot);
            end
        end

    end

    methods(Access=private)

        function resizeAreaAnnotaionsInGraph(obj,origGraphToAnnot,reducedGraphToAnnot)
            for key=keys(reducedGraphToAnnot)
                graph=key{1};

                slvariants.internal.reducer.log(['Layouting graph:',graph]);
                Simulink.internal.variantlayout.LayoutManager(graph).layoutModel();
                if isKey(origGraphToAnnot,graph)



                    origAnnots=origGraphToAnnot(graph);
                    reducedAnnots=reducedGraphToAnnot(graph);
                    obj.resizeAreaAnnotations(origAnnots,reducedAnnots);
                end
            end
        end

    end

    methods(Static,Access=private)

        function resizeAreaAnnotations(origAnnots,reducedAnnots)


            for annotIdx=1:numel(reducedAnnots.AreaAnnotations)
                redAnnotH=reducedAnnots.AreaAnnotations(annotIdx);
                redAnnotObj=get(redAnnotH,'Object');


                redAnnotArea=Simulink.internal.variantlayout.AnnotationArea(...
                redAnnotObj,reducedAnnots.Blocks);
                matchIdx=redAnnotArea.Handle==[origAnnots.Handle];
                origMargins=origAnnots(matchIdx).Margins;
                redAnnotArea.setAreaPosition(origMargins);
            end
        end

        function graphToAnnotArea=getGraphToAnnotationArea(graphToAnnotInfo)
            graphToAnnotArea=containers.Map('keytype','char','valuetype','any');
            for key=keys(graphToAnnotInfo)
                graph=key{1};
                annotInfo=graphToAnnotInfo(graph);
                annotAreas=Simulink.internal.variantlayout.AnnotationArea.empty;
                for annotIdx=1:numel(annotInfo.AreaAnnotations)
                    annotH=annotInfo.AreaAnnotations(annotIdx);
                    annotObj=get(annotH,'Object');
                    annotAreas(annotIdx)=Simulink.internal.variantlayout.AnnotationArea(...
                    annotObj,annotInfo.Blocks);
                end
                graphToAnnotArea(graph)=annotAreas;
            end
        end

    end

    properties(Access=private)



        BDToAutoLayoutInfo;

    end

end
