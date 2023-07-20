function ReplacePulseGen2(block,h)




    if askToReplace(h,block)
        oldEntries=GetMaskEntries(block);
        CheckEntries(block,oldEntries,4);



        Period=oldEntries{1};
        DutyCycle=oldEntries{2};
        Amplitude=oldEntries{3};
        StartTime=oldEntries{4};
        if length(oldEntries)>4
            Vect1D=oldEntries{5};
        else
            Vect1D='on';
        end



        funcSet=uReplaceBlock(h,block,...
        'built-in/DiscretePulseGenerator',...
        'PulseType','Time-based',...
        'Amplitude',Amplitude,...
        'Period',Period,...
        'PulseWidth',DutyCycle,...
        'PhaseDelay',StartTime,...
        'VectorParams1D',Vect1D);

        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
