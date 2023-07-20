function ret=getCurrentComparison()






    ret=Simulink.sdi.DiffRunResult.getLatest();
end