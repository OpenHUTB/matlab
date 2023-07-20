function ReplaceResetIntegrator(block,h)










    if askToReplace(h,block)
        funcSet=uReplaceBlock(h,block,'built-in/Integrator',...
        'InitialConditionSource','external',...
        'ExternalReset','level');
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
