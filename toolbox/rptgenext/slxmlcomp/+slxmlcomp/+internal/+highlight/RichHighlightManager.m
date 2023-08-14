classdef RichHighlightManager<handle




    properties(Access=private)
DelegateHighlightManager
JLayout
Disposables
    end

    methods
        function obj=RichHighlightManager(...
            jLocationStyleFactory,...
            jStyleChangeAfterMergeNotifier,...
            jReportSupplier,...
jLayout...
            )

            obj.Disposables={};
            import slxmlcomp.internal.highlight.window.JavaReportWindowFactory
            f2=JavaReportWindowFactory(jReportSupplier);
            windowFactories=obj.createSideWindowGroupFactories(jLocationStyleFactory,jStyleChangeAfterMergeNotifier);
            windowFactories(end+1)=f2;

            import slxmlcomp.internal.highlight.window.LayoutAdapters
            layout=LayoutAdapters.fromJLayout(jLayout);
            obj.JLayout=jLayout;

            import slxmlcomp.internal.highlight.WindowManager
            windowManager=WindowManager(layout,windowFactories);

            import slxmlcomp.internal.highlight.HighlightManager
            obj.DelegateHighlightManager=HighlightManager(windowManager);

        end

        function highlight(obj,topHighlightActionData,bottomHighlightActionData)
            import slxmlcomp.internal.highlight.window.LayoutAdapters

            obj.registerWithStoreWindowPositions(...
            topHighlightActionData,bottomHighlightActionData...
            );






            topLocation=obj.createLocation(topHighlightActionData);
            topLocation.BDInfo.ensureLoaded();
            bottomLocation=obj.createLocation(bottomHighlightActionData);
            bottomLocation.BDInfo.ensureLoaded();

            obj.DelegateHighlightManager.highlight(...
            topLocation,...
            LayoutAdapters.jSideToContentId(obj.JLayout.getTopChoice())...
            );

            obj.DelegateHighlightManager.highlight(...
            bottomLocation,...
            LayoutAdapters.jSideToContentId(obj.JLayout.getBottomChoice())...
            );

        end

        function layoutChanged(obj,jLayout)
            import slxmlcomp.internal.highlight.window.LayoutAdapters
            newLayout=LayoutAdapters.fromJLayout(jLayout);
            obj.DelegateHighlightManager.layoutChanged(newLayout);
            obj.JLayout=jLayout;
        end

        function comparisonResultChanged(obj,newResult)
            obj.DelegateHighlightManager.comparisonChanged(newResult);
        end

        function delete(obj)
            delete(obj.DelegateHighlightManager);
        end

    end

    methods(Access=private)

        function registerWithStoreWindowPositions(obj,topHighlightData,bottomHighlightData)


            import slxmlcomp.internal.highlight.PositionStoreMediator
            instance=PositionStoreMediator.getInstance();
            instance.registerWithStoreWindowPositions();

            import slxmlcomp.internal.highlight.PositionStoreMediator;

            function pos=getJavaReportPosition()
                leftFile=string(topHighlightData.getFile().getAbsolutePath());
                rightFile=string(bottomHighlightData.getFile().getAbsolutePath());

                import slxmlcomp.internal.highlight.window.getJavaReportPosition;
                pos=getJavaReportPosition(leftFile,rightFile);
            end

            mediator=PositionStoreMediator.getInstance();
            obj.Disposables{end+1}=mediator.addPositionSupplier(...
            "Report",@getJavaReportPosition...
            );
        end

        function location=createLocation(~,jHighlightData)
            import slxmlcomp.internal.highlight.window.BDLocation;
            location=BDLocation.fromJHighlightData(jHighlightData);
        end

        function factories=createSideWindowGroupFactories(...
            obj,...
            jLocationStyleFactory,...
jStyleChangeAfterMergeNotifier...
            )
            import slxmlcomp.internal.highlight.ContentId

            factories=slxmlcomp.internal.highlight.ContentWindowFactory.empty();
            for contentId=ContentId.AllSides
                factories(end+1)=obj.createSideWindowGroupFactory(...
                contentId,...
                jLocationStyleFactory,...
jStyleChangeAfterMergeNotifier...
                );%#ok<AGROW>
            end
        end

        function factory=createSideWindowGroupFactory(~,...
            contentId,...
            jLocationStyleFactory,...
jStyleChangeAfterMergeNotifier...
            )

            import slxmlcomp.internal.highlight.window.SLEditorWindowFactory
            import slxmlcomp.internal.highlight.window.ConfigSetWindowFactory

            sideFactories=[...
            SLEditorWindowFactory(jLocationStyleFactory,jStyleChangeAfterMergeNotifier,contentId),...
            ConfigSetWindowFactory();...
            ];

            import slxmlcomp.internal.highlight.WindowGroupFactory
            factory=WindowGroupFactory(sideFactories,contentId);
        end

    end

end
