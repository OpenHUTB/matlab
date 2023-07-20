function MIDIControlsBlock(obj)




    if isR2013aOrEarlier(obj.ver)

        blks=obj.findBlocksWithMaskType('MIDI Controls');
        for idx=1:numel(blks)
            blk=blks{idx};
            RawUint8=get_param(blk,'RawUint8');

            if strcmp(RawUint8,'Raw MIDI (0 - 127)')
                obj.replaceWithEmptySubsystem(blk,...
                'MIDI Controls Raw MIDI',...
                DAStudio.message('dsp:block:midiRawUint8NotAvailable'));
            end
        end

        obj.appendRule('<Block<SourceBlock|"dspsrcs4/MIDI Controls"><RawUint8:remove>>');
    end
