classdef(Hidden,Sealed)NewPlotEventData<event.EventData





    properties
RequestedPlotTag
    end

    methods
        function this=NewPlotEventData(plotType)
            if any(strcmp(plotType,{'arrayGeoFig','pattern3DFig',...
                'azPatternFig','elPatternFig','uPatternFig',...
                'gratingLobeFig'}))
                this.RequestedPlotTag=plotType;
            end
        end
    end

end

