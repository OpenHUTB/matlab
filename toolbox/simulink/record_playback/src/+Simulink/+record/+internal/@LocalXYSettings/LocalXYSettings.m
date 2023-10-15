classdef LocalXYSettings




    properties


        SubPlotID


        isAutoLimits


        limits
    end

    methods


        function obj = LocalXYSettings( plotIndex )
            if nargin > 0
                obj.SubPlotID = plotIndex;
            end
            obj.isAutoLimits = true;

            obj.limits = [ 0, 10,  - 5, 5 ];
        end


        function obj = set.SubPlotID( obj, plotIndex )
            Simulink.record.internal.verifySubPlot( plotIndex );
            obj.SubPlotID = plotIndex;
        end


        function obj = set.isAutoLimits( obj, autoLimits )
            validateattributes( autoLimits, 'logical', { 'scalar' } );
            obj.isAutoLimits = autoLimits;
        end


        function obj = set.limits( obj, limits )
            validateattributes( limits, obj.NUMERIC_CLASS, obj.LIMITS_ATTRIBUTES );
            obj.limits = limits;
        end
    end

    methods ( Static )

        function xyLocalSettingObj = createXYLocalSettingsFromDataModel( subPlotID, xyLocalDataModel )
            arguments
                subPlotID
                xyLocalDataModel SdiVisual.LocalXYSettings
            end


            subPlotID = Simulink.record.internal.verifySubPlot( subPlotID );


            xyLocalSettingObj = Simulink.record.internal.LocalXYSettings( subPlotID );
            xyLocalSettingObj.isAutoLimits = xyLocalDataModel.autoLimits;
            xyLocalSettingObj.limits = [ xyLocalDataModel.limits.xMin, xyLocalDataModel.limits.xMax, xyLocalDataModel.limits.yMin, xyLocalDataModel.limits.yMax ];
        end

    end


    properties ( Constant, Access = protected )
        NUMERIC_CLASS = { 'numeric' }
        LIMITS_ATTRIBUTES = { 'ncols', 4, 'real', 'finite' }
    end
end

