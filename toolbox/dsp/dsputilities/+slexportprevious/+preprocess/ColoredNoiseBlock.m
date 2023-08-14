function ColoredNoiseBlock(obj)






    if isR2015aOrEarlier(obj.ver)

        blks=obj.findBlocksWithMaskType('dsp.simulink.ColoredNoise');

        numBlks=length(blks);

        for idx=1:numBlks

            blk=blks{idx};
            color=get_param(blk,'Color');
            switch color
            case 'pink'
                invPowerFreq='1';
            case 'brown'
                invPowerFreq='2';
            case 'white'
                invPowerFreq='0';
            case 'blue'
                invPowerFreq='-1';
            case 'purple'
                invPowerFreq='-2';
            case 'custom'
                invPowerFreq=get_param(blk,'InverseFrequencyPower');
            end
            set_param(blk,'InverseFrequencyPower',invPowerFreq);
        end

        obj.appendRule('<Block<SourceBlock|"dspsrcs4/Colored Noise"><Color:remove>>');
    end