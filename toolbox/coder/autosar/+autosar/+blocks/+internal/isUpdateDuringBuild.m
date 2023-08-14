function[isDuringBuild,isAccelOrRAccel]=isUpdateDuringBuild(rootBd)




    isDuringBuild=false;
    isAccelOrRAccel=false;

    rtwGenSettings=get_param(rootBd,'RTWGenSettings');
    notBuilding=isempty(rtwGenSettings);
    if notBuilding
        return;
    end

    buildForAccel=isfield(rtwGenSettings,'AccelIsERTTarget');
    buildForRaccel=isfield(rtwGenSettings,'CodeFormat')&&strcmp(rtwGenSettings.CodeFormat,'RealTime')&&isfield(rtwGenSettings,'tlcTargetType')&&strcmp(rtwGenSettings.tlcTargetType,'NRT');

    isDuringBuild=~(notBuilding||buildForAccel||buildForRaccel);
    isAccelOrRAccel=buildForAccel||buildForRaccel;
end


