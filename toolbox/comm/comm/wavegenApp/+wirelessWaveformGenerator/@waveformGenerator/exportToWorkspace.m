function exportToWorkspace(obj,~)




    prompt=getString(message('comm:waveformGenerator:WorkspaceVar'));
    title=getString(message('comm:waveformGenerator:exportToWorkspace'));


    obj.setStatus(getString(message('comm:waveformGenerator:Exporting')));

    outVar.type=obj.pCurrentWaveformType;
    outVar.config=obj.pWaveformConfiguration;
    outVar.Fs=obj.pSampleRate;
    if~isempty(obj.pGenerationImpairments)&&~isempty(fieldnames(obj.pGenerationImpairments))
        outVar.impairments=obj.pGenerationImpairments;
    end
    outVar.waveform=obj.pWaveform;
    outVar=obj.pParameters.CurrentDialog.appendExportData(outVar);

    [~,~]=export2wsdlg({prompt},{'var'},{outVar},title);



    obj.setStatus(getString(message('comm:waveformGenerator:Exported2Workspace',obj.pCurrentWaveformType)));
end
