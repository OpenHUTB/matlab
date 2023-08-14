function lAuxiliaryMakefileContent=getCoderTargetAuxMakefileContent...
    (componentBuildInfoPath)




    lAuxiliaryMakefileContent='';
    auxMakefile='codertarget_assembly_flags.mk';
    sourceFile=fullfile(componentBuildInfoPath,auxMakefile);
    if exist(sourceFile,'file')
        lAuxiliaryMakefileContent=fileread(sourceFile);
    end
