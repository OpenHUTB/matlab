function updateConstellationWithBackups(~,constellation)


    idMap=evolutions.internal.BackupReader.getCurrentIds;
    xmlFiles=keys(idMap);
    bakFiles=values(idMap);
    for idx=1:numel(xmlFiles)
        xml=strcat('xml@file:',xmlFiles{idx});
        bak=strcat('xml@file:',bakFiles{idx});
        constellation.setModelURIOverride(xml,bak);
    end
end