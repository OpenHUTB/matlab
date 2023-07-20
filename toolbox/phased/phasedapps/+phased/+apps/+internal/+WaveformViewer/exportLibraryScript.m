function exportLibraryScript(wavobj,compobj,index)




    sw=StringWriter;
    dateTimeStr=datestr(now);
    ml=ver('matlab');
    pat=ver('phased');
    addcr(sw)
    addcr(sw)

    for m=1:length(index)
        i=index(m);
        waveform=wavobj.Elements{i};


        if~isa(waveform,'phased.apps.internal.WaveformViewer.FMCWWaveform')
            waveformname=sprintf(waveform.Name);
            exportScript(waveform,sw,waveformname)
            addcr(sw)
            addcr(sw)
        end
    end
    add(sw,'% WaveformSpecification')
    addcr(sw)
    add(sw,'%s = ','waveformSpec')
    add(sw,'{')

    for m=1:length(index)
        i=index(m);
        Waveform=wavobj.Elements{i};
        if~isa(Waveform,'phased.apps.internal.WaveformViewer.FMCWWaveform')
            k=sprintf(Waveform.Name);
            add(sw,'%s ',k)
        end
    end
    add(sw,'};')
    addcr(sw)
    addcr(sw)
    add(sw,'% SampleRate')
    addcr(sw)
    add(sw,'%s = ','fs')
    add(sw,sprintf('%d',wavobj.Elements{1}.SampleRate))
    add(sw,';')
    addcr(sw)
    add(sw,'%s = ','waveformLib')

    add(sw,'phased.PulseWaveformLibrary')
    add(sw,'(')

    add(sw,'''%s'',','WaveformSpecification')
    add(sw,'waveformSpec')
    add(sw,',')
    add(sw,'''%s'',','SampleRate')
    add(sw,'fs')
    addcr(sw,');')
    addcr(sw)
    addcr(sw,'% Call step method of waveformLib to generate IQ samples of pulse Waveform library')
    addcr(sw,'% Change the index to switch among the Waveforms')
    addcr(sw,' samples = {};')
    addcr(sw,'for i=1:numel(waveformLib.WaveformSpecification)');
    addcr(sw,'samples{i} = waveformLib(i);')
    addcr(sw,'end');

    for m=1:length(index)
        i=index(m);
        waveform=wavobj.Elements{i};
        process=compobj.Processes{i};


        if~isa(waveform,'phased.apps.internal.WaveformViewer.FMCWWaveform')
            str=extractAfter(waveform.Name,"Waveform");
            rangeprocessingname=strcat("Process",str);
            coefficients=strcat("coefficients",str);
            ProcessType=phased.apps.internal.WaveformViewer.getWaveformString(class(process));
            switch ProcessType
            case 'MatchedFilter'
                add(sw,'%s = ',coefficients)
                add(sw,'getMatchedFilter(waveformLib,')
                add(sw,'%d ); ',m)
                addcr(sw)
                addcr(sw)
                add(sw,'%s = ',rangeprocessingname)
                op=cell(0,2);
                op{end+1,1}='SpectrumWindow';
                op{end,2}=sprintf('''%s''',process.SpectrumWindow);
                add(sw,'{')
                add(sw,'''%s'',','MatchedFilter')
                add(sw,'''%s'',%s,',op{1,1},op{1,2})
                if strcmp(process.SpectrumWindow,'Taylor')
                    op{end+1,1}='coefficients';
                    op{end,2}=coefficients;
                    op{end+1,1}='SideLobeAttenuation';
                    op{end,2}=sprintf('%.15g',process.SideLobeAttenuation);
                    op{end+1,1}='SpectrumRange';
                    op{end,2}=sprintf('[%.15g %.15g]',process.SpectrumRange(1),process.SpectrumRange(2));
                    op{end+1,1}='Nbar';
                    op{end,2}=sprintf('%.15g',process.Nbar);
                    add(sw,'''%s'',%s(:,1),',op{2,1},op{2,2})
                    add(sw,'''%s'',%s,',op{3,1},op{3,2})
                    add(sw,'''%s'',%s,',op{4,1},op{4,2})
                    add(sw,'''%s'',%s};',op{5,1},op{5,2})
                elseif strcmp(process.SpectrumWindow,'Kaiser')
                    op{end+1,1}='coefficients';
                    op{end,2}=coefficients;
                    op{end+1,1}='SpectrumRange';
                    op{end,2}=sprintf('[%.15g %.15g]',process.SpectrumRange(1),process.SpectrumRange(2));
                    op{end+1,1}='Beta';
                    op{end,2}=sprintf('%.15g',process.Beta);
                    add(sw,'''%s'',%s(:,1),',op{2,1},op{2,2})
                    add(sw,'''%s'',%s,',op{3,1},op{3,2})
                    add(sw,'''%s'',%s};',op{4,1},op{4,2})
                elseif strcmp(process.SpectrumWindow,'Chebyshev')
                    op{end+1,1}='coefficients';
                    op{end,2}=coefficients;
                    op{end+1,1}='SpectrumRange';
                    op{end,2}=sprintf('[%.15g %.15g]',process.SpectrumRange(1),process.SpectrumRange(2));
                    op{end+1,1}='SideLobeAttenuation';
                    op{end,2}=sprintf('%.15g',process.SideLobeAttenuation);
                    add(sw,'''%s'',%s(:,1),',op{2,1},op{2,2})
                    add(sw,'''%s'',%s,',op{3,1},op{3,2})
                    add(sw,'''%s'',%s};',op{4,1},op{4,2})
                elseif strcmp(process.SpectrumWindow,'None')
                    op{end+1,1}='coefficients';
                    op{end,2}=coefficients;
                    add(sw,'''%s'',%s(:,1)};',op{2,1},op{2,2})
                else
                    op{end+1,1}='coefficients';
                    op{end,2}=coefficients;
                    op{end+1,1}='SpectrumRange';
                    op{end,2}=sprintf('[%.15g %.15g]',process.SpectrumRange(1),process.SpectrumRange(2));
                    add(sw,'''%s'',%s(:,1),',op{2,1},op{2,2})
                    add(sw,'''%s'',%s};',op{3,1},op{3,2})
                end
            case 'StretchProcessor'
                add(sw,'%s = ',rangeprocessingname)
                op=cell(0,2);
                op{end+1,1}='ReferenceRange';
                op{end,2}=sprintf('%.15g',process.ReferenceRange);
                op{end+1,1}='RangeSpan';
                op{end,2}=sprintf('%.15g',process.RangeSpan);
                op{end+1,1}='RangeFFTLength';
                op{end,2}=sprintf('%.15g',process.RangeFFTLength);
                op{end+1,1}='RangeWindow';
                op{end,2}=sprintf('''%s''',process.RangeWindow);
                add(sw,'{')
                add(sw,'''%s'',','StretchProcessor')
                add(sw,'''%s'',%s,',op{1,1},op{1,2})
                add(sw,'''%s'',%s,',op{2,1},op{2,2})
                add(sw,'''%s'',%s,',op{3,1},op{3,2})
                switch process.RangeWindow
                case 'Chebyshev'
                    op{end+1,1}='SidelobeAttenuation';
                    op{end,2}=sprintf('%.15g',process.SideLobeAttenuation);
                    add(sw,'''%s'',%s,',op{4,1},op{4,2})
                    add(sw,'''%s'',%s};',op{5,1},op{5,2})
                case 'Kaiser'
                    op{end+1,1}='Beta';
                    op{end,2}=sprintf('%.15g',process.Beta);
                    add(sw,'''%s'',%s,',op{4,1},op{4,2})
                    add(sw,'''%s'',%s};',op{5,1},op{5,2})
                case 'Taylor'
                    op{end+1,1}='SidelobeAttenuation';
                    op{end,2}=sprintf('%.15g',process.SideLobeAttenuation);
                    op{end+1,1}='Nbar';
                    op{end,2}=sprintf('%.15g',process.Nbar);
                    add(sw,'''%s'',%s,',op{4,1},op{4,2})
                    add(sw,'''%s'',%s,',op{5,1},op{5,2})
                    add(sw,'''%s'',%s};',op{6,1},op{6,2})
                case 'None'
                    add(sw,'''%s'',%s};',op{4,1},op{4,2})
                case 'Hann'
                    add(sw,'''%s'',%s};',op{4,1},op{4,2})
                case 'Hamming'
                    add(sw,'''%s'',%s};',op{4,1},op{4,2})
                end
            end
            addcr(sw)
            addcr(sw)
        end
    end
    add(sw,'% ProcessingSpecification')
    addcr(sw)
    add(sw,'%s = ','processSpec')
    add(sw,'{')

    for m=1:length(index)
        i=index(m);
        Waveform=wavobj.Elements{i};
        str=extractAfter(Waveform.Name,"Waveform");
        rangeprocessingname=strcat("Process",str);
        if~isa(Waveform,'phased.apps.internal.WaveformViewer.FMCWWaveform')
            k=sprintf(rangeprocessingname);
            add(sw,'%s ',k)
        end
    end
    add(sw,'};')
    addcr(sw)
    add(sw,'%s = ','compLib')

    add(sw,'phased.PulseCompressionLibrary')
    add(sw,'(')

    add(sw,'''%s'',','WaveformSpecification')
    add(sw,'waveformSpec')
    add(sw,',')
    add(sw,'''%s'',','ProcessingSpecification')
    add(sw,'processSpec')
    add(sw,',')
    add(sw,'''%s'',','SampleRate')
    add(sw,'fs')
    addcr(sw,');')
    addcr(sw)
    addcr(sw,'% Call step method of waveformLib to generate IQ samples of pulse compression library')
    addcr(sw,'% Change the index to switch among the Waveforms')
    addcr(sw,' compressedsamples = {};')
    addcr(sw,'for i=1:numel(waveformLib.WaveformSpecification)');
    addcr(sw,'compressedsamples{i} = compLib(samples{i},i);')
    addcr(sw,'end');
    newDoc=matlab.desktop.editor.newDocument(sw.string);
    newDoc.smartIndentContents;
end