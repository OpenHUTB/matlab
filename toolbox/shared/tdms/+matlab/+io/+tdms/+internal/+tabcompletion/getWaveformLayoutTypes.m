function waveformLayouts=getWaveformLayoutTypes()




    e=?matlab.io.tdms.internal.wrapper.TimeChannel;
    waveformLayouts=string({e.EnumerationMemberList.Name});
end


