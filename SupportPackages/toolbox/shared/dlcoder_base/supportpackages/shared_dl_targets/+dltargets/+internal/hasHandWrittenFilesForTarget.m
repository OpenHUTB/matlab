function tf=hasHandWrittenFilesForTarget(targetLibrary)




    tf=any(strcmpi(targetLibrary,["cudnn","onednn","arm_neon","tensorrt"]));

end
