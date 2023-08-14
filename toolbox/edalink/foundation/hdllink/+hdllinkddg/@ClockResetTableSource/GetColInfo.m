function[widths,headings,height]=GetColInfo(this)

    headings={...
    'Full HDL Name',...
    sprintf('Waveform Type'),...
'Period/Duration'...
    };
    height=4;

    maxPathLength=this.GetMaxPathLength;
    maxEdgeLength=max(cellfun(@(x)(length(x)),hdllinkddg.ClockResetRowSource.getStrValues('edge')));
    perDurLength=length(headings{3});
    padding=3;
    widths=[maxPathLength,maxEdgeLength,perDurLength];
    widths=widths+padding;

end
