function ACSources(obj)









    if isR2012bOrEarlier(obj.ver)

        BlksV=obj.findBlocksWithMaskType('AC Voltage Source');
        BlksC=obj.findBlocksWithMaskType('AC Current Source');
        Blks=[BlksV;BlksC];

        if(isempty(Blks))
            return;
        end

        for i=1:length(Blks)
            blk=Blks{i};
            try
                frequency=get_param(blk,'frequency');
                frequency_unit=get_param(blk,'frequency_unit');
                set_param(blk,'omega',frequency)
                set_param(blk,'omega_unit',frequency_unit)
            catch E
            end
        end

    end