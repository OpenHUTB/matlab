classdef TileSetReaderEnvironmentManager<handle

















    properties

        EnableMapTileFileCache logical=true


        EnableDiagnostics logical=false


        EnableErrorDiagnostics logical=false


        ConnectionTimeout double
    end


    methods(Access=private)
        function this=TileSetReaderEnvironmentManager()
            options=weboptions;
            this.ConnectionTimeout=options.Timeout;
        end
    end


    methods(Static)
        function this=instance()
mlock
            persistent uniqueInstanceOfEnvironmentManager
            if isempty(uniqueInstanceOfEnvironmentManager)||~isvalid(uniqueInstanceOfEnvironmentManager)
                this=matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager();




                hasLocalClient=matlab.internal.lang.capability.Capability.isSupported('LocalClient');
                this.EnableMapTileFileCache=hasLocalClient;
                uniqueInstanceOfEnvironmentManager=this;
            else
                this=uniqueInstanceOfEnvironmentManager;
            end
        end
    end
end
