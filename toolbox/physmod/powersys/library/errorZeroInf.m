function errorZeroInf(name,block)





    pere=bdroot(block);
    block=strrep(block,char(10),' ');
    block=strrep(block,pere,'');
    block=block(2:end);
    message=['In mask of ''',block,''' block:',char(10),'Parameter ''',name,''' must be different from zero and have a finite value.'];
    Erreur.message=message;
    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
    psberror(Erreur);