function ReplaceSpectrumAnalyzer(block,h)






    if askToReplace(h,block)


        sfunBlock=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','S-Function');
        sfunName=get_param(sfunBlock,'FunctionName');
        sfunParams=get_param(sfunBlock,'Parameters');

        if strcmp(sfunName,'sfunpsd')&&(sfunParams{1}(end)=='0')
            libBlock=sprintf('simulink_extras/Additional\nSinks/Power Spectral\nDensity');
        elseif strcmp(sfunName,'sfunpsd')&&(sfunParams{1}(end)=='1')
            libBlock=sprintf('simulink_extras/Additional\nSinks/Averaging\nPower Spectral\nDensity');
        elseif strcmp(sfunName,'sfuntf')&&(sfunParams{1}(end)=='0')
            libBlock=sprintf('simulink_extras/Additional\nSinks/Spectrum\nAnalyzer');
        elseif strcmp(sfunName,'sfuntf')&&(sfunParams{1}(end)=='1')
            libBlock=sprintf('simulink_extras/Additional\nSinks/Averaging\nSpectrum\nAnalyzer');
        else
            DAStudio.error('SimulinkBlocks:upgrade:unrecognizedSpecAnBlock');
        end

        funcSet=uBlock2Link(h,block,libBlock);
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end

