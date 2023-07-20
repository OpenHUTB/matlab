function tf=isAnalyzeAllChoicesDisabled(blk)





    tf=~Simulink.variant.reducer.utils.isAnalyzeAllChoicesEnabled(blk);
end
