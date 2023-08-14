function NotAllowedForPhasorSimulation(Mode,BlockName,Type)





    if Mode
        message=['The following block is not supported in Phasor simulation method:',...
        newline,...
        'Block : ',strrep(BlockName,newline,' '),...
        newline,...
        'Type  : ',Type];
        Erreur.message=char(message);
        Erreur.identifier='SpecializedPowerSystems:NotAllowedForPhasorSimulation';
        psberror(Erreur);
    end