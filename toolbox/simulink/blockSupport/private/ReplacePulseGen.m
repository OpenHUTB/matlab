function ReplacePulseGen(block,h)













    if askToReplace(h,block)

        oldEntries=GetMaskEntries(block);
        CheckEntries(block,oldEntries,4);

        Period=oldEntries{1};
        PulseWidth=oldEntries{2};
        PulseHeight=oldEntries{3};
        StartTime=oldEntries{4};


        DutyCycle=['100 * (',PulseWidth,')/(',Period,')'];



        funcSet=uReplaceBlock(h,block,...
        'built-in/DiscretePulseGenerator',...
        'PulseType','Time-based',...
        'Amplitude',PulseHeight,...
        'Period',Period,...
        'PulseWidth',DutyCycle,...
        'PhaseDelay',StartTime,...
        'VectorParams1D','on');

        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
