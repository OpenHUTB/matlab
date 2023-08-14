function rtwGenSettings=getModelRTWGenSettings(in)









    if ischar(in)
        [~,genSet]=coder.internal.getSTFInfo(in,'csfieldsonly',true);
    else
        genSet=in;
    end

    modelName=genSet.model;

    rtwGenSettings=coder.internal.getSTFInfoCSFields(genSet);

    mdlRefTgtType='NONE';
    if isfield(genSet,'ModelReferenceTargetType')
        mdlRefTgtType=getfield(genSet,'ModelReferenceTargetType');%#ok
    end

    folders=Simulink.filegen.internal.FolderConfiguration(modelName);
    if strcmpi(mdlRefTgtType,'NONE')

        rtwGenSettings.RelativeBuildDir=folders.CodeGeneration.ModelCode;
    else

        if strcmpi(mdlRefTgtType,'SIM')
            folder=folders.Simulation;
        else
            folder=folders.CodeGeneration;
        end

        rtwGenSettings.RelativeBuildDir=folder.ModelReferenceCode;
        rtwGenSettings.mdlRefRelativeSimDir=folders.Simulation.ModelReferenceCode;
        rtwGenSettings.mdlRefRelativeHdlDir=folders.HDLGeneration.ModelReferenceCode;
    end
end
