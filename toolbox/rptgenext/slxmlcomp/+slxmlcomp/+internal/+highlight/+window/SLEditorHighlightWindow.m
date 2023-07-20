classdef SLEditorHighlightWindow<slxmlcomp.internal.highlight.HighlightWindow




    properties(Access=private)
SystemName
EditorStyler
Disposables
WindowInfo
BDInfo
ZoomHandlers
LocationStyleFactory
TraversalFactory
ContentId
ComparisonResult
ModelWasClosed
Position
    end

    methods(Static)
        function instance=newInstance(...
            location,...
            locationStyleFactory,...
            styleChangeAfterMergeNotifier,...
            traversalFactory,...
contentId...
            )

            import slxmlcomp.internal.highlight.window.SLEditorHighlightWindow
            instance=SLEditorHighlightWindow(...
            location,...
            locationStyleFactory,...
            traversalFactory,...
contentId...
            );
            try
                instance.listenForEditorRemoveHighlightEvents();
                instance.removeHighlightingOnModelNameChange();
                instance.setClosedFlagOnModelClose();
                instance.updateStylesAfterMerges(styleChangeAfterMergeNotifier);
            catch exception
                delete(instance);
                exception.rethrow
            end
        end

        function instance=newPlainInstance(...
            location,...
            locationStyleFactory,...
            traversalFactory,...
contentId...
            )
            import slxmlcomp.internal.highlight.window.SLEditorHighlightWindow
            instance=SLEditorHighlightWindow(...
            location,...
            locationStyleFactory,...
            traversalFactory,...
contentId...
            );
        end
    end

    methods(Access=public)

        function setPosition(obj,coordinates)
            obj.closeTestHarnessesForModel();
            obj.ensureSystemLoaded();
            obj.Position=coordinates;



            allEditors=GLUE2.Util.findAllEditors(obj.SystemName);
            for editor=allEditors
                editor.getStudio().setStudioPosition(toXYWidthHeight(coordinates));
            end

            if isempty(allEditors)






                set_param(obj.SystemName,"Location",obj.Position);
            end
        end

        function applyDiffStyles(obj,comparisonResult)
            if(isequal(obj.ComparisonResult,comparisonResult)...
                &&obj.EditorStyler.isBackgroundStyleApplied())...
                ||~bdIsLoaded(obj.SystemName)

                return
            end


            obj.ComparisonResult=comparisonResult;

            obj.EditorStyler.clearDiffStyles();
            if~obj.EditorStyler.isBackgroundStyleApplied()
                obj.EditorStyler.fadeAll();
            end

            if obj.BDInfo.IsTestHarness
                traversal=obj.TraversalFactory.forHarnessBD(comparisonResult,obj.BDInfo.HarnessName);
            else
                traversal=obj.TraversalFactory.forRootBD(comparisonResult);
            end
            obj.applyNewDiffStyles(traversal);
        end

        function updateStylesIfNecessary(obj,jDifferenceIterator)
            if obj.EditorStyler.isBackgroundStyleApplied()
                obj.updateDiffStyles(jDifferenceIterator);
            end
        end

        function applyAttentionStyle(obj,location)
            obj.ensureSystemLoaded();
            obj.EditorStyler.applyAttentionStyle(location);
        end

        function clearAttentionStyle(obj)
            obj.EditorStyler.clearAttentionStyles();
        end

        function zoomToShow(obj,location)
            obj.ensureSystemLoaded();
            for zoomHandler=obj.ZoomHandlers
                handler=zoomHandler{1};
                if handler.canHandle(location)
                    handler.zoomTo(location);
                    break
                end
            end
        end

        function clearDiffStyles(obj)
            obj.EditorStyler.clearForegroundStyles();
            obj.EditorStyler.clearBackgroundStyle();
        end

        function areSame=canDisplay(obj,location)
            windowInfo=obj.getWindowInfo(location);
            areSame=isequal(windowInfo,obj.WindowInfo);
        end

        function show(obj)
            obj.closeTestHarnessesForModel();
            obj.ensureSystemLoaded();
            if "on"~=get_param(obj.SystemName,"open")
                set_param(obj.SystemName,"open","on");
            end
            obj.registerWithStoreWindowPositions();
        end

        function hide(obj)
            if~bdIsLoaded(obj.SystemName)
                return
            end

            allEditors=GLUE2.Util.findAllEditors(obj.SystemName);
            for editor=allEditors
                editor.getStudio().close();
            end

        end

        function delete(obj)
            obj.clearAllStyles();
        end
    end

    methods(Access=private)
        function obj=SLEditorHighlightWindow(...
            location,...
            locationStyleFactory,...
            traversalFactory,...
contentId...
            )
            obj.WindowInfo=obj.getWindowInfo(location);
            obj.BDInfo=location.BDInfo;
            obj.SystemName=obj.BDInfo.getSystemName();
            obj.LocationStyleFactory=locationStyleFactory;
            obj.TraversalFactory=traversalFactory;
            obj.ContentId=contentId;
            obj.ModelWasClosed=false;

            obj.ZoomHandlers={...
            slxmlcomp.internal.highlight.window.ChartZoomHandler(),...
            slxmlcomp.internal.highlight.window.TruthTableZoomHandler(),...
            slxmlcomp.internal.highlight.window.SimulinkZoomHandler(),...
            };

            import slxmlcomp.internal.highlight.SLEditorRichStyler
            obj.EditorStyler=SLEditorRichStyler(obj.SystemName);
        end

        function applyNewDiffStyles(obj,jDifferenceIterator)
            obj.forEachDiffStyle(...
            jDifferenceIterator,...
            @(location,style)obj.EditorStyler.styleLocation(location,style)...
            );
        end

        function updateDiffStyles(obj,jDifferenceIterator)
            obj.forEachDiffStyle(...
            jDifferenceIterator,...
            @(location,style)obj.EditorStyler.updateDiffStyle(location,style)...
            );
        end

        function forEachDiffStyle(obj,jDifferenceIterator,styleAction)
            import slxmlcomp.internal.highlight.StringLocation
            import slxmlcomp.internal.highlight.window.LayoutAdapters
            jSide=LayoutAdapters.contentIdToJSide(obj.ContentId);

            while jDifferenceIterator.hasNext()
                difference=jDifferenceIterator.next();
                jLocStyle=obj.LocationStyleFactory.getLocationStyle(...
                difference,...
jSide...
                );
                if isempty(jLocStyle)


                    continue
                end
                location=StringLocation(...
                string(jLocStyle.getType()),...
                string(jLocStyle.getLocation())...
                );



                try
                    styleAction(...
                    location,...
                    jLocStyle.getStyle()...
                    );
                catch exception
                    if slxmlcomp.internal.highlight.getSetIsStrictErrorHandling()
                        rethrow(exception);
                    end
                end
            end
        end


        function listenForEditorRemoveHighlightEvents(obj)
            function clearAllStyles(bdHandle)
                if isvalid(obj)&&strcmp(obj.SystemName,get_param(bdHandle,'Name'))
                    obj.EditorStyler.clearAllStyles();
                end
            end

            removeHighlightMediator=slxmlcomp.internal.highlight.RemoveHighlightMediator.getInstance();

            cleanupAction=removeHighlightMediator.addListener(...
            @(bdHandle)clearAllStyles(bdHandle)...
            );

            obj.Disposables{end+1}=onCleanup(cleanupAction);
        end

        function registerWithStoreWindowPositions(obj)
            function position=getEditorPosition()
                if bdIsLoaded(obj.SystemName)
                    position=get_param(obj.SystemName,'Location');
                else
                    position=[];
                end
            end

            import slxmlcomp.internal.highlight.PositionStoreMediator
            instance=PositionStoreMediator.getInstance();
            obj.Disposables{end+1}=instance.addPositionSupplier(...
            obj.ContentId,...
            @getEditorPosition...
            );
        end

        function updateStylesAfterMerges(obj,styleChangeAfterMergeNotifier)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.gui.highlight.MATLABStyleApplier
            styleApplier=MATLABStyleApplier(obj);
            styleChangeAfterMergeNotifier.addListener(styleApplier);
            obj.Disposables{end+1}=onCleanup(@()styleChangeAfterMergeNotifier.removeListener(styleApplier));
        end

        function setClosedFlagOnModelClose(obj)


            function setModelWasClosedFlag()
                obj.ModelWasClosed=true;
            end

            modelCloseMediator=slxmlcomp.internal.highlight.ModelCloseMediator.getInstance();
            cleanupAction=modelCloseMediator.addListener(...
            obj.SystemName,...
            @setModelWasClosedFlag...
            );

            obj.Disposables{end+1}=onCleanup(cleanupAction);
        end

        function clearAllStyles(obj)
            obj.EditorStyler.clearAllStyles();
        end

        function closeTestHarnessesForModel(obj)
            if bdIsLoaded(obj.SystemName)
                slxmlcomp.internal.testharness.closeAll(obj.SystemName,{});
            end
        end

        function ensureSystemLoaded(obj)
            obj.BDInfo.ensureLoaded();
            if~obj.BDInfo.IsTestHarness
                slxmlcomp.internal.highlight.hideAllBdScopes(obj.SystemName,obj.WindowInfo.Id);
            end

            if obj.ModelWasClosed
                obj.ModelWasClosed=false;
                set_param(obj.SystemName,"Location",obj.Position);
            end
        end

        function windowInfo=getWindowInfo(~,location)
            windowResolver=slxmlcomp.internal.highlight.window.SLEditorWindowResolver();
            windowInfo=windowResolver.getInfo(location);
        end

        function removeHighlightingOnModelNameChange(obj)
            function clearAllStyles(newName)
                if isvalid(obj)
                    obj.EditorStyler.clearAllStyles(newName);
                end
            end

            modelRenameMediator=slxmlcomp.internal.highlight.ModelRenameMediator.getInstance();
            cleanupAction=modelRenameMediator.addListener(...
            obj.SystemName,...
            @clearAllStyles...
            );

            obj.Disposables{end+1}=onCleanup(cleanupAction);
        end

    end

end

function coords=toXYWidthHeight(x1y1x2y2)
    width=x1y1x2y2(3)-x1y1x2y2(1);
    height=x1y1x2y2(4)-x1y1x2y2(2);
    coords=[x1y1x2y2(1),x1y1x2y2(2),width,height];
end
