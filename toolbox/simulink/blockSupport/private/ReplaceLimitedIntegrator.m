function ReplaceLimitedIntegrator(block,h)








    if askToReplace(h,block)
        entries=GetMaskEntries(block);
        LowerLimit=entries{1};
        UpperLimit=entries{2};
        X0=entries{3};


        funcSet=uReplaceBlock(h,block,'built-in/Integrator',...
        'LimitOutput','on',...
        'LowerSaturationLimit',LowerLimit,...
        'UpperSaturationLimit',UpperLimit,...
        'InitialCondition',X0);
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
