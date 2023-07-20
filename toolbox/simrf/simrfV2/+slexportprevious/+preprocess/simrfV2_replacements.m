function simrfV2_replacements(obj)




    verobj=obj.ver;

    if isR2021bOrEarlier(verobj)
        blksConnLbl=find_system(obj.modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'BlockType','ConnectionLabel','Tag','simrfV2util1/Connection Label');
        for idx=1:numel(blksConnLbl)
            obj.replaceWithEmptySubsystem(blksConnLbl{idx},...
            'Connection Label (RF Blockset)');
        end
        obj.appendRule(...
        ['<SourceBlock|"simrfV2elements/Ideal\nTransformer":',...
        'repval "simrfV2_lib/Elements/Ideal\nTransformer">']);
        obj.appendRule(...
        ['<SourceBlock|"simrfV2elements/Mutual\nInductor":',...
        'repval "simrfV2_lib/Elements/Mutual\nInductor">']);
        obj.appendRule(...
        ['<SourceBlock|"simrfV2elements/Three-Winding\nTransformer":',...
        'repval "simrfV2_lib/Elements/Three-Winding\nTransformer">']);
        blksAmp=find_system(obj.modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'ReferenceBlock','simrfV2elements/Amplifier');
        for idx=1:numel(blksAmp)
            SourceLinGain=get_param(blksAmp{idx},'Source_linear_gain');
            if strcmp(SourceLinGain,'AM/AM-AM/PM table')
                obj.replaceWithEmptySubsystem(blksAmp{idx},...
                'Amplifier (RF Blockset)');
                continue
            elseif strcmp(SourceLinGain,'Data source')






                nonLinear=false;
                MaskWSValues=simrfV2getblockmaskwsvalues(blksAmp{idx});
                if~(isfield(MaskWSValues,'IP3')&&...
                    (isnumeric(MaskWSValues.IP3)&&...
                    isscalar(MaskWSValues.IP3)))
                    nonLinear=true;
                else
                    switch get_param(blksAmp{idx},'Source_Poly')
                    case 'Odd order'
                        if(~(isfield(MaskWSValues,'P1dB')&&...
                            (isnumeric(MaskWSValues.P1dB)&&...
                            isscalar(MaskWSValues.P1dB)))||...
                            ~(isfield(MaskWSValues,'Psat')&&...
                            (isnumeric(MaskWSValues.Psat)&&...
                            isscalar(MaskWSValues.Psat))))
                            nonLinear=true;
                        else
                            if~(isinf(MaskWSValues.IP3)&&...
                                isinf(MaskWSValues.P1dB)&&...
                                isinf(MaskWSValues.Psat))
                                nonLinear=true;
                            end
                        end
                    case 'Even and odd order'
                        if~(isfield(MaskWSValues,'IP2')&&...
                            (isnumeric(MaskWSValues.IP2)&&...
                            isscalar(MaskWSValues.IP2)))
                            nonLinear=true;
                        else
                            if~(isinf(MaskWSValues.IP2)&&...
                                isinf(MaskWSValues.IP3))
                                nonLinear=true;
                            end
                        end
                    end
                end
                if nonLinear&&...
                    strcmp(get_param(blksAmp{idx},'ConstS21NL'),'off')
                    obj.replaceWithEmptySubsystem(blksAmp{idx},...
                    'Amplifier (RF Blockset)');
                    continue
                end
            end
            if strcmp(get_param(blksAmp{idx},'SetOpFreqAsMaxS21'),'on')
                set_param(blksAmp{idx},'SetOpFreqAsMaxS21','off');
            else
                set_param(blksAmp{idx},'SetOpFreqAsMaxS21','on');
            end
        end
        blksIMT=find_system(obj.modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'ReferenceBlock','simrfV2elements/IMT Mixer');
        for idx=1:numel(blksIMT)
            UseDataFile=get_param(blksIMT{idx},'UseDataFile');
            if strcmp(UseDataFile,'on')
                obj.replaceWithEmptySubsystem(blksIMT{idx},...
                'Amplifier (RF Blockset)');
            end
        end
        obj.appendRule(...
        slexportprevious.rulefactory.removeInstanceParameter(...
        '<SourceBlock|"simrfV2elements/Amplifier">',...
        {'AmAmAmPmTable','ConstS21NL'},...
        verobj));
        obj.appendRule(...
        slexportprevious.rulefactory.removeInstanceParameter(...
        '<SourceBlock|"simrfV2elements/IMT Mixer">',...
        {'PowerRF_Data','PowerLO_Data'},...
        verobj));
        obj.appendRule(...
        slexportprevious.rulefactory.renameInstanceParameter(...
        '<SourceBlock|"simrfV2elements/Amplifier">',...
        'SetOpFreqAsMaxS21',...
        'SpecifyOpFreq',...
        verobj));
    end

    if isR2020aOrEarlier(verobj)
        obj.removeLibraryLinksTo('simrfV2elements/Antenna');
    end

    if isR2019aOrEarlier(verobj)
        obj.removeLibraryLinksTo(sprintf('simrfV2elements/IMT\nMixer'))
        obj.removeLibraryLinksTo(sprintf(...
        'simrfV2testbenches/S-Parameter\nTestbench'))
    end

    if isR2017bOrEarlier(verobj)
        obj.removeLibraryLinksTo('simrfV2junction1/SPnT');
        obj.removeLibraryLinksTo('simrfV2systems/Demodulator');
        obj.removeLibraryLinksTo('simrfV2systems/Modulator');
        obj.removeLibraryLinksTo(sprintf(...
        'simrfV2testbenches/Transducer Gain\nTestbench'))
        obj.removeLibraryLinksTo(sprintf(...
        'simrfV2testbenches/Noise Figure\nTestbench'))
        obj.removeLibraryLinksTo(sprintf('simrfV2testbenches/IIP3\nTestbench'))
        obj.removeLibraryLinksTo(sprintf('simrfV2testbenches/OIP3\nTestbench'))
        obj.removeLibraryLinksTo(sprintf('simrfV2testbenches/IIP2\nTestbench'))
        obj.removeLibraryLinksTo(sprintf('simrfV2testbenches/OIP2\nTestbench'))
    end

    if isR2017aOrEarlier(verobj)
        obj.removeLibraryLinksTo('simrfV2elements/Power Amplifier');
        obj.removeLibraryLinksTo(sprintf('simrfV2elements/Variable\nResistor'))
    end

    if isR2016bOrEarlier(verobj)
        obj.removeLibraryLinksTo('simrfV2systems/IQ Demodulator');
        obj.removeLibraryLinksTo('simrfV2systems/IQ Modulator');
    end

    if isR2016aOrEarlier(verobj)
        obj.removeLibraryLinksTo('simrfV2elements/Attenuator');
        obj.removeLibraryLinksTo(sprintf(...
        'simrfV2elements/Variable\nPhase Shift'))
        obj.removeLibraryLinksTo(sprintf(...
        'simrfV2elements/Variable\nAttenuator'))
        obj.removeLibraryLinksTo(sprintf(...
        'simrfV2elements/Variable\nCapacitor'))
        obj.removeLibraryLinksTo(sprintf('simrfV2elements/Variable\nInductor'))
    end

    if isR2015aOrEarlier(verobj)
        obj.removeLibraryLinksTo('simrfV2elements/VGA');
        obj.removeLibraryLinksTo('simrfV2junction1/Potentiometer');
        obj.removeLibraryLinksTo('simrfV2junction1/Switch');
        obj.removeLibraryLinksTo('simrfV2junction1/SPST');
        obj.removeLibraryLinksTo('simrfV2junction1/SPDT');
    end
end
