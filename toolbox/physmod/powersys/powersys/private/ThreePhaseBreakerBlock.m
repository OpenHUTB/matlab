function ThreePhaseBreakerBlock(BLOCKLIST,sps)






    idx=BLOCKLIST.filter_type('Three-Phase Breaker');
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');

        SPSVerifyLinkStatus(block);

        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        Ron=getSPSmaskvalues(block,{'BreakerResistance'});

        if Ron==0&&sps.PowerguiInfo.SPID==0
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            Erreur.message=['The Ron parameter of ''',BlockNom,''' block cannot be set to zero.',newline,'You can set Ron = 0 only when the ''Continuous'' Simulation type in the Solver tab of the Powergui is selected and the ''Disable ideal switching'' option in the Preferences tab of powergui is not selected.'];
            psberror(Erreur);
        end
    end