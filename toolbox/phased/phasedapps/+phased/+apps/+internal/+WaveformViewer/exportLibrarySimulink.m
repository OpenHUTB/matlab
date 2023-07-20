function exportLibrarySimulink(SampleRate,PropagationSpeed,wave,comp)



    assignin('base','Waveforms',wave)


    load_system('simulink')
    h=new_system('','model');
    sys=get(h,'Name');
    SampleRate=num2str(SampleRate);
    srcwaveform=[sys,'/Pulse Waveform Library'];
    srccompression=[sys,'/Pulse Compression Library'];

    add_block('phasedwavlib/Pulse Waveform Library',srcwaveform);


    set_param(srcwaveform,'SampleRate',SampleRate);
    set_param(srcwaveform,'WaveformSpecification','Waveforms');
    assignin('base','Compression',comp)
    add_block('phaseddetectlib/Pulse Compression Library',srccompression);
    set_param(srcwaveform,'Position',[300,200,450,300]);


    set_param(srccompression,'SampleRate',SampleRate);
    set_param(srccompression,'PropagationSpeed',num2str(PropagationSpeed));
    set_param(srccompression,'WaveformSpecification','Waveforms','ProcessingSpecification','Compression');
    set_param(srccompression,'Position',[300,421,475,480]);
    add_block('simulink/Sources/Constant',[sys,'/Index'],'Value','1','Position','[-45 325 -15 355]');
    add_line(sys,'Index/1','Pulse Waveform Library/1');
    add_line(sys,'Index/1','Pulse Compression Library/2');
    open_system(sys)
end