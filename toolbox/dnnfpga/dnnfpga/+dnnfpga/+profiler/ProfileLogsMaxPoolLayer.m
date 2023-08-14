classdef ProfileLogsMaxPoolLayer<dnnfpga.profiler.ProfileLogsConvpLayerbase






    properties
layerName
verbose
layerTles
LayerInfo
LayerEvent
    end

    methods
        function this=ProfileLogsMaxPoolLayer(layerName,verbose)
            this.verbose=verbose;
            this.layerName=layerName;
        end
    end

    methods

        function LayerCycle=getLayerCycle(this)
            switch this.verbose
            case 1
                LayerCycle=this.getLayerCycleVerbose_1;
            case 2
                LayerCycle=this.getLayerCycleVerbose_2;
            case 3
                LayerCycle=this.getLayerCycleVerbose_3;
            end
        end

        function LayerStart=getLayerStart(this)
            LayerStart=this.getLayerStartVerbose();
        end

        function LayerEnd=getLayerEnd(this)
            LayerEnd=this.getLayerEndVerbose();
        end
    end

    methods

        function addLayerEvent(this,LayerEvent)

            this.LayerEvent=LayerEvent;
        end

        function layerDetails=getLayerCycleVerbose_1(this)
            layerDetails.layerLatency=this.LayerEvent.Conv_LayerDone-this.LayerEvent.Conv_LayerStart;
        end

    end

    methods

        function addTiles(this,Tile)

            this.layerTles{end+1}=Tile;
        end

        function layerDetails=getLayerCycleVerbose_2(this)

            firstTile=this.layerTles{1};
            LayerCycle=this.LayerEvent.Conv_LayerDone-this.LayerEvent.Conv_LayerStart;
            IPTileLatency=firstTile.getIPTileLatency;
            ConvLatency=firstTile.getConvlatency;
            ConvTileSize=firstTile.getConvTileSize;
            OPTileLatency=firstTile.getOPTileLatency;

            layerDetails.layerLatency=LayerCycle;
            layerDetails.ConvLatency=ConvLatency;
            layerDetails.IPTileLatency=IPTileLatency;
            layerDetails.OPTileLatency=OPTileLatency;
            layerDetails.ConvTileSize=ConvTileSize;


        end

    end

    methods

        function layerDetails=getLayerCycleVerbose_3(this)

            firstTile=this.layerTles{1};
            LayerCycle=this.LayerEvent.Conv_LayerDone-this.LayerEvent.Conv_LayerStart;
            IPBurstLatency=firstTile.getIPBurstLatency;
            IPBurstInterval=firstTile.getIPBurstInterval;
            IPtoConvInterval=firstTile.getIPtoConvInterval;
            ConvLatency=firstTile.getConvlatency;
            ConvTileSize=firstTile.getConvTileSize;
            ConvtoOPInterval=firstTile.getConvtoOPInterval;
            OPBurstInterval=firstTile.getOPBurstInterval;
            OPBurstLatency=firstTile.getOPBurstLatency;
            TileSingleIPBurstNum=firstTile.getTileSingleIPBurstNum;
            TileSingleOPBurstNum=firstTile.getTileSingleOPBurstNum;

            layerDetails.layerLatency=LayerCycle;
            layerDetails.IPBurstLatency=IPBurstLatency;
            layerDetails.IPBurstInterval=IPBurstInterval;
            layerDetails.IPtoConvInterval=IPtoConvInterval;
            layerDetails.ConvLatency=ConvLatency;
            layerDetails.ConvTileSize=ConvTileSize;
            layerDetails.ConvtoOPInterval=ConvtoOPInterval;
            layerDetails.OPBurstInterval=OPBurstInterval;
            layerDetails.OPBurstLatency=OPBurstLatency;
            layerDetails.TileSingleIPBurstNum=TileSingleIPBurstNum;
            layerDetails.TileSingleOPBurstNum=TileSingleOPBurstNum;


        end

    end

    methods

        function LayerStart=getLayerStartVerbose(this)

            LayerStart=this.LayerEvent.Conv_LayerStart;
        end

        function LayerEnd=getLayerEndVerbose(this)

            LayerEnd=this.LayerEvent.Conv_LayerDone;
        end
    end
end
