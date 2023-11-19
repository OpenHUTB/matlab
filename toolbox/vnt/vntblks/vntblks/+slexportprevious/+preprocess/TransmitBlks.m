function TransmitBlks(obj)

    exportVer=obj.ver;

    if exportVer.isR2019bOrEarlier

        blks=obj.findLibraryLinksTo('canlib/CAN Transmit');


        if~exportVer.isR2017bOrEarlier
            blks=[blks;obj.findLibraryLinksTo('canfdlib/CAN FD Transmit')];
        end

        paramName='EnableEventTransmit';

        for idx=1:length(blks)

            sid=get_param(blks{idx},'SID');

            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),paramName,exportVer));
        end
    end

end