function exportToScript(obj,~)





    obj.setStatus(getString(message('comm:waveformGenerator:Exporting')));

    sw=StringWriter;


    sw=exportHeader(obj,sw);


    sw=exportGenerationCode(obj,sw);

    sw=exportImpairmentsCode(obj,sw);

    sw=exportVisualizationCode(obj,sw);

    sw=exportTransmissionCode(obj,sw);


    indentCode(sw);

    matlab.desktop.editor.newDocument(sw.string);


    obj.setStatus(getString(message('comm:waveformGenerator:Exported2Script',obj.pCurrentWaveformType)));

    function sw=exportHeader(obj,sw)
        waveformRegistration=obj.pRegistrations.findChild('Class',class(obj.pParameters.CurrentDialog));


        if~isempty(waveformRegistration)
            propSet=waveformRegistration(1).PropertySet;
            verDirProp=propSet.findProperty('ToolboxDir');
            if isempty(verDirProp)
                toolboxDir='comm';

            else
                toolboxDir=verDirProp.Value;
            end
        else


            toolboxDir='wlan';
        end
        if needTransmitterCode(obj)&&strcmp(obj.pCurrentHWType,'Instrument')
            toolboxDir={toolboxDir,'instrument'};
        end

        header=matlabshared.application.getFileHeader('',toolboxDir);
        addcr(sw,header);
        addcr(sw,'');

        function sw=exportVisualizationCode(obj,sw)
            if obj.pPlotTimeScope||obj.pPlotSpectrum||obj.pPlotConstellation||obj.pPlotEyeDiagram
                addcr(sw,['%% ',getString(message('comm:waveformGenerator:VisualizeBtn'))]);
            end

            if obj.pPlotTimeScope
                addcr(sw,'% Time Scope');
                addcr(sw,'timeScope = timescope(''SampleRate'', Fs, ...');
                addcr(sw,sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t''TimeSpanOverrunAction'', ''scroll'', ...'));

                addcr(sw,sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t''TimeSpanSource'', ''property'', ...'));

                genDialog=obj.pParameters.GenerationDialog;
                if isa(genDialog,'wirelessWaveformGenerator.packetizedGenerationConfiguration')&&genDialog.NumFrames>1
                    addcr(sw,sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t''TimeSpan'', length(waveform)/Fs);'));
                else
                    symbolTime=double(obj.pParameters.FilteringDialog.Sps)/getSampleRate(obj.pParameters.CurrentDialog);
                    addcr(sw,sprintf(['\t\t\t\t\t\t\t\t\t\t\t\t\t''TimeSpan'', ',num2str(30*symbolTime),');']));
                end
                addTimeScopeCustomizations(obj.pParameters.CurrentDialog,sw);
                addcr(sw,'timeScope(waveform);');
                addcr(sw,'release(timeScope);');
                addcr(sw,'');
            end

            if obj.pPlotSpectrum
                addcr(sw,'% Spectrum Analyzer');
                addcr(sw,'spectrum = spectrumAnalyzer(''SampleRate'', Fs);');
                addSpectrumCustomizations(obj.pParameters.CurrentDialog,sw);
                addcr(sw,'spectrum(waveform);');
                addcr(sw,'release(spectrum);');
                addcr(sw,'');
            end
            currDialog=obj.pParameters.CurrentDialog;
            if obj.pPlotConstellation
                addcr(sw,'% Constellation Diagram');
                addcr(sw,'constel = comm.ConstellationDiagram(''ColorFading'', true, ...');
                addcr(sw,sprintf(['\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t''ShowTrajectory'', ',num2str(currDialog.showConstellationTrajectory),', ...']));


                sps=obj.pParameters.FilteringDialog.Sps;
                if sps>1
                    addcr(sw,sprintf(['\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t''SamplesPerSymbol'', ',num2str(sps),', ...']));
                end
                addcr(sw,sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t''ShowReferenceConstellation'', false);'));
                addConstellationCustomizations(obj.pParameters.CurrentDialog,sw);
                addcr(sw,'constel(waveform);');
                addcr(sw,'release(constel);');
                addcr(sw,'');
            end

            if obj.pPlotEyeDiagram
                addcr(sw,'% Eye Diagram');
                addcr(sw,['eyediagram(waveform, 2* ',num2str(currDialog.getSamplesPerSymbol()),');']);
                addcr(sw,'');
            end

            addCustomVisualizationCode(obj.pParameters.CurrentDialog,sw);
            addcr(sw,'');

            function sw=exportTransmissionCode(obj,sw)

                if needTransmitterCode(obj)

                    addcr(sw,['%% ',getString(message('comm:waveformGenerator:TransmitTT'))]);
                    obj.pParameters.RadioDialog.addTransmissionCode(sw);
                end

                function b=needTransmitterCode(obj)
                    dlg=obj.pParameters.RadioDialog;
                    b=~isempty(dlg)&&canExportCode(dlg);

