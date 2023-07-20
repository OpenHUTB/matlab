function h=playback




    h=Simulink.slx.PartHandler('playback',[],[],@i_save);

end

function i_save(modelHandle,~)


    Simulink.internal.savePlaybackBlockParts(modelHandle);
end
