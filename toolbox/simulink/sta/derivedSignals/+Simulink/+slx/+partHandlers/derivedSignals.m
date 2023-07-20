function h=derivedSignals





    h=Simulink.slx.PartHandler('derivedSignals','blockDiagram',[],@i_save);
end

function i_save(modelHandle,saveOptions)









    writer=saveOptions.writerHandle;
    prefix15b_prelease='/simulink/waveform_generator_blk_data_';
    if~isempty(writer.getMatchingPartNames(prefix15b_prelease))
        parts=writer.getMatchingPartDefinitions(prefix15b_prelease);
        writer.deletePart(parts);
    end
    prefix=[saveOptions.getPartNamePrefix,'WaveformGenerator/waveform_generator_blk_data_'];
    if~isempty(writer.getMatchingPartNames(prefix))
        parts=writer.getMatchingPartDefinitions(prefix);

        writer.deletePart(parts);
    end



































































































end
