classdef LayoutAdapters<handle




    methods(Access=public,Static)

        function layout=fromJLayout(jLayout)

            legacyMATLABLayout=eval(jLayout.getLegacyMATLABLayout());

            if isa(legacyMATLABLayout,'slxmlcomp.internal.highlight.TwoSourceWindowLayout')
                layout=slxmlcomp.internal.highlight.window.LayoutAdapters.fromLegacyJLayout(...
                jLayout,'Left','Right'...
                );
            elseif isa(legacyMATLABLayout,'slxmlcomp.internal.highlight.ThreeWayMergeLayout')
                layout=slxmlcomp.internal.highlight.window.LayoutAdapters.fromLegacyJLayout(...
                jLayout,'Top','Bottom'...
                );
            else
                error("Invalid legacy MATLAB layout");
            end
        end


        function obj=fromLegacyJLayout(jLayout,topId,bottomId)

            legacyLayout=eval(jLayout.getLegacyMATLABLayout());

            import slxmlcomp.internal.highlight.window.LayoutAdapters
            import slxmlcomp.internal.highlight.ContentId

            positions=struct(...
            LayoutAdapters.jSideToContentId(jLayout.getTopChoice()),legacyLayout.getDefaultPositions(topId).Simulink,...
            LayoutAdapters.jSideToContentId(jLayout.getBottomChoice()),legacyLayout.getDefaultPositions(bottomId).Simulink,...
            ContentId.Report,legacyLayout.getReportPosition()...
            );

            obj=slxmlcomp.internal.highlight.FixedPositionLayout(positions);

        end

        function id=jSideToContentId(jSide)
            switch string(jSide)
            case "LEFT"
                fieldName="Left";
            case "RIGHT"
                fieldName="Right";
            case "BASE"
                fieldName="Base";
            case "THEIRS"
                fieldName="Theirs";
            case "MINE"
                fieldName="Mine";
            case "TARGET"
                if isa(jSide,"com.mathworks.comparisons.difference.side.TwoWayMergeChoice")
                    fieldName="Target2";
                else
                    fieldName="Target3";
                end
            otherwise
                error("Unknown side: "+string(jSide));
            end

            import slxmlcomp.internal.highlight.ContentId
            id=ContentId.(fieldName);
        end

        function jSide=contentIdToJSide(contentId)
            import slxmlcomp.internal.highlight.ContentId
            import com.mathworks.comparisons.difference.side.TwoWayMergeChoice
            import com.mathworks.comparisons.difference.three.ThreeWayMergeChoice

            switch contentId
            case ContentId.Left
                jSide=TwoWayMergeChoice.LEFT;
            case ContentId.Right
                jSide=TwoWayMergeChoice.RIGHT;
            case ContentId.Target2
                jSide=TwoWayMergeChoice.TARGET;
            case ContentId.Base
                jSide=ThreeWayMergeChoice.BASE;
            case ContentId.Theirs
                jSide=ThreeWayMergeChoice.THEIRS;
            case ContentId.Mine
                jSide=ThreeWayMergeChoice.MINE;
            case ContentId.Target3
                jSide=ThreeWayMergeChoice.TARGET;
            otherwise
                error("Invalid content id : "+contentId)
            end

        end

    end

end
