classdef CloneDetectionUI < Simulink.CloneDetection.internal.ClonesDataBase

    properties
        ddgRight;
        ddgBottom;
        ddgHelp;
        refactorButtonEnable;
        compareModelButtonEnable;
        colorCodes;
        toolstripCtx;
        regionSizeEnable;
        cloneGroupSizeEnable;
    end

    methods ( Static )
        function obj = getActiveInstance( system )
            obj = get_param( system, 'CloneDetectionUIObj' );
        end
    end

    methods ( Access = 'public' )
        populateCloneResultsInGUI( this );


        function this = CloneDetectionUI( system )
            arguments
                system = ''
            end
            this = this@Simulink.CloneDetection.internal.ClonesDataBase( system );
            this.initCloneDetectionUI(  );
        end

        function initCloneDetectionUI( this )
            this.ddgBottom = CloneDetectionUI.internal.DDGViews.ddgDialogBottom( this );
            this.ddgRight = CloneDetectionUI.internal.DDGViews.ddgDialogRight( this );
            this.ddgHelp = CloneDetectionUI.internal.DDGViews.ddgDialogHelp( this );
            this.colorCodes = struct( 'exactColor', CloneDetectionUI.internal.util.getExactColorCode,  ...
                'similarColor', CloneDetectionUI.internal.util.getSimilarColorCode,  ...
                'exclusionColor', CloneDetectionUI.internal.util.getExclusionColorCode );
            this.refactorButtonEnable = false;
            this.compareModelButtonEnable = false;
            this.regionSizeEnable = false;
            this.cloneGroupSizeEnable = false;
        end

        function setRefactorButtonEnable( obj, value )
            if ~isempty( obj.toolstripCtx ) && isvalid( obj.toolstripCtx )
                obj.toolstripCtx.enableRefactor = value;
            end
            obj.refactorButtonEnable = value;
        end

        function setRegionSizeEnable( obj, value )
            if ~isempty( obj.toolstripCtx ) && isvalid( obj.toolstripCtx )
                obj.toolstripCtx.regionSizeEnable = value;
            end
            obj.regionSizeEnable = value;
        end

        function setCloneGroupSizeEnable( obj, value )
            if ~isempty( obj.toolstripCtx ) && isvalid( obj.toolstripCtx )
                obj.toolstripCtx.cloneGroupSizeEnable = value;
            end
            obj.cloneGroupSizeEnable = value;
        end

        function setCompareModelButtonEnable( obj, value )
            if ~isempty( obj.toolstripCtx ) && isvalid( obj.toolstripCtx )
                obj.toolstripCtx.enableVerify = value;
            end
            obj.compareModelButtonEnable = value;
        end


        function exitHiliteMode( this )
            allSys = find_system( 'SearchDepth', 0 );
            for ii = 1:length( allSys )
                set_param( allSys{ ii }, 'HiliteAncestors', 'off' );
            end

            CloneDetectionUI.internal.util.hiliteAllClones ...
                ( this.refactorButtonEnable, length( this.m2mObj.cloneresult.similar ), this.blockPathCategoryMap, this.colorCodes );
        end
    end

    methods ( Access = 'protected' )
        function constructHelperMaps( obj )
            obj.constructHelperMaps@Simulink.CloneDetection.internal.ClonesDataBase;
        end
    end
end


