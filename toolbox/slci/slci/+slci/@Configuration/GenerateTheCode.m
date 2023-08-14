function GenerateTheCode(aObj)





    ProfileCodeGen=slci.internal.Profiler('SLCI','GenerateCode',...
    aObj.getModelName(),...
    aObj.getTargetName());

    if aObj.getGenerateCode()
        myStage=slci.internal.turnOnDiagnosticView('SLCI Code Generation',...
        aObj.getModelName());%#ok<*NASGU>
        try
            if~aObj.getTopModel()
                slInternal('genCodeForSLCIApp',aObj.getModelName(),...
                'ModelReferenceCoderTargetOnly');
            else
                slInternal('genCodeForSLCIApp',aObj.getModelName());
            end
        catch ME
            if aObj.fViaGUI

                slci.internal.outputMessage(ME,'error');
            end
            DAStudio.error('Slci:slci:ERROR_CODEGEN',aObj.getModelName());
        end
        if~isempty(aObj.fInspectProgressBar)
            aObj.setInspectProgressBarLabel('Inspect');
        end
    else
        aObj.checkForGeneratedCodeExistance();
    end

    ProfileCodeGen.stop();
end

