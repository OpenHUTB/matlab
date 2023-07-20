classdef ProfileLogsTile<handle
    properties
layerName
TileInfo
TileEvent

    end

    methods
        function this=ProfileLogsTile(layerName,TileInfo,TileEvent)
            this.layerName=layerName;
            this.TileInfo=TileInfo;
            this.TileEvent=TileEvent;
        end
    end

    methods

        function IPTileLatency=getIPTileLatency(this)
            IPTileLatency=this.TileEvent.Conv_IP_TileDone{1}-this.TileEvent.Conv_IP_TileStart{1};
        end

        function OPTileLatency=getOPTileLatency(this)
            OPTileLatency=this.TileEvent.Conv_OP_TileDone{1}-this.TileEvent.Conv_OP_TileStart{1};
        end

    end

    methods

        function TileCycles=getTileCycles(this)

            TileCycles=this.TileEvent.Conv_OP_done{end}-this.TileEvent.Conv_IP_start{1};
        end

        function TileSingleIPBurstNum=getTileSingleIPBurstNum(this)
            TileSingleIPBurstNum=this.TileInfo.IPlongburst;
        end

        function TileSingleOPBurstNum=getTileSingleOPBurstNum(this)
            TileSingleOPBurstNum=this.TileInfo.OPlongburst;
        end

        function getIPBurstLatency=getIPBurstLatency(this)

            IPBurstCycles=this.TileEvent.Conv_IP_done{end}-this.TileEvent.Conv_IP_start{1};
            getIPBurstLatency=ceil(IPBurstCycles/length(this.TileEvent.Conv_IP_done));
        end

        function IPBurstInterval=getIPBurstInterval(this)


            IPInternalDelay=0;
            for i=2:length(this.TileEvent.Conv_IP_start)
                IPInternalDelay=IPInternalDelay+(this.TileEvent.Conv_IP_start{i}-this.TileEvent.Conv_IP_done{i-1});
            end
            IPBurstInterval=ceil(IPInternalDelay/(length(this.TileEvent.Conv_IP_start)-1));
        end

        function IPtoConvInterval=getIPtoConvInterval(this)
            IPtoConvInterval=this.TileEvent.Conv_Conv_start{1}-this.TileEvent.Conv_IP_done{end};
        end



        function ConvtoOPInterval=getConvtoOPInterval(this)
            ConvtoOPInterval=this.TileEvent.Conv_OP_start{1}-this.TileEvent.Conv_Conv_done{end};
        end

        function OPBurstLatency=getOPBurstLatency(this)

            OPBurstCycles=this.TileEvent.Conv_OP_done{end}-this.TileEvent.Conv_OP_start{1};
            OPBurstLatency=ceil(OPBurstCycles/length(this.TileEvent.Conv_OP_done));
        end

        function OPBurstInterval=getOPBurstInterval(this)

            OPInternalDelay=0;
            for i=2:length(this.TileEvent.Conv_OP_start)
                OPInternalDelay=OPInternalDelay+(this.TileEvent.Conv_OP_start{i}-this.TileEvent.Conv_OP_done{i-1});
            end
            OPBurstInterval=ceil(OPInternalDelay/(length(this.TileEvent.Conv_OP_start)-1));
        end


    end

    methods

        function CompCycles=getConvlatency(this)

            CompCycles=this.TileEvent.Conv_Conv_done{1}-this.TileEvent.Conv_Conv_start{1};
        end

        function ConvTileSize=getConvTileSize(this)
            ConvTileSize=this.TileInfo.tilesize;
        end

    end

end