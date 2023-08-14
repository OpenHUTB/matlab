function slrealtimeIPBlocks(obj)





    ver_obj=obj.ver;

    if isR2021aOrEarlier(ver_obj)

        blks=obj.findBlocksWithMaskType('slrealtimeudpsend');
        for idx=1:numel(blks)
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});

            localIP=get_param(blks{idx},'ipAddress');
            if(isempty(localIP))
                if(ver_obj.isR2015aOrEarlier()||~ver_obj.isSLX)
                    obj.appendRule(['<Block',identifyBlock,':insertpair ipAddress 0.0.0.0>']);
                else
                    obj.appendRule(['<Block',identifyBlock,'<InstanceData',':insertpair ipAddress 0.0.0.0>>']);
                end
            end

            localPort=get_param(blks{idx},'localPort');
            if(isempty(localPort))
                if(ver_obj.isR2015aOrEarlier()||~ver_obj.isSLX)
                    obj.appendRule(['<Block',identifyBlock,':insertpair localPort 0>']);
                else
                    obj.appendRule(['<Block',identifyBlock,'<InstanceData',':insertpair localPort 0>>']);
                end
            end
        end


        blks=obj.findBlocksWithMaskType('slrealtimetcpclient');
        for idx=1:numel(blks)
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});

            clientIP=get_param(blks{idx},'clientAddress');
            if(isempty(clientIP))
                if(ver_obj.isR2015aOrEarlier()||~ver_obj.isSLX)
                    obj.appendRule(['<Block',identifyBlock,':insertpair clientAddress 0.0.0.0>']);
                else
                    obj.appendRule(['<Block',identifyBlock,'<InstanceData',':insertpair clientAddress 0.0.0.0>>']);
                end
            end

            clientPort=get_param(blks{idx},'clientPort');
            if(isempty(clientPort))
                if(ver_obj.isR2015aOrEarlier()||~ver_obj.isSLX)
                    obj.appendRule(['<Block',identifyBlock,':insertpair clientPort 0>']);
                else
                    obj.appendRule(['<Block',identifyBlock,'<InstanceData',':insertpair clientPort 0>>']);
                end
            end
        end
    end

    if isR2021bOrEarlier(ver_obj)

        UDPSendBlks=obj.findBlocksWithMaskType('slrealtimeudpsend');
        for idx=1:numel(UDPSendBlks)
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(UDPSendBlks{idx});

            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(identifyBlock,...
            'enableMessage',ver_obj));
        end



        UDPReceiveBlks=obj.findBlocksWithMaskType('slrealtimeudpreceive');
        for idx=1:numel(UDPReceiveBlks)
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(UDPReceiveBlks{idx});

            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(identifyBlock,...
            'enableMessage',ver_obj));
            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(identifyBlock,...
            'maxPackets',ver_obj));
        end

    end
