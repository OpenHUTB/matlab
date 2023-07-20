function exportWaveformFile(View,wav,comp,matfilepath)




    Waveform=phased.apps.internal.WaveformViewer.WaveformProperties(wav);
    CompressionType=phased.apps.internal.WaveformViewer.getWaveformString(class(comp));

    if~strcmp(CompressionType,'Dechirp')
        Compression=phased.apps.internal.WaveformViewer.compressionProperties(wav,comp);
        prompt={getString(message('phased:apps:waveformapp:ExportWaveformLabel')),getString(message('phased:apps:waveformapp:ExportCompressionLabel'))};
        dlgtitle=getString(message('phased:apps:waveformapp:ExportToFileTitle'));
        dims=[1,60];
        definput={'waveform','compression'};
        input=inputdlg(prompt,dlgtitle,dims,definput);
        if~isempty(input)
            while~isempty(input)&&(isempty(input{1})||isempty(input{2}))
                if View.Toolstrip.IsAppContainer
                    uialert(View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:entervalidnames')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'Modal',true,'Icon','warning');
                else
                    uiwait(warndlg(getString(message('phased:apps:waveformapp:entervalidnames')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'modal'));
                end
                input=inputdlg(prompt,dlgtitle,dims,definput);
            end
            lib={Waveform,Compression};
            libchanged=cell2struct(lib,input',2);
            save(matfilepath,'-struct','libchanged');
        end
    else
        prompt={getString(message('phased:apps:waveformapp:ExportWaveformLabel'))};
        dlgtitle=getString(message('phased:apps:waveformapp:ExportToFileTitle'));
        dims=[1,60];
        definput={'waveform'};
        input=inputdlg(prompt,dlgtitle,dims,definput);
        if~isempty(input)
            while isempty(input{1})
                if View.Toolstrip.IsAppContainer
                    uialert(View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:entervalidnames')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'Icon','warning','Modal',true);
                else
                    uiwait(warndlg(getString(message('phased:apps:waveformapp:entervalidnames')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'modal'));
                end
                input=inputdlg(prompt,dlgtitle,dims,definput);
            end
            lib={Waveform};
            libchanged=cell2struct(lib,input',1);
            save(matfilepath,'-struct','libchanged');
        end
    end