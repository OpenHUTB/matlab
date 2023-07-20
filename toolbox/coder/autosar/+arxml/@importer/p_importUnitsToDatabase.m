function p_importUnitsToDatabase(importerObj,filename)







    p_update_read(importerObj);


    m3iModel=importerObj.arModel;

    unitsImporter=autosar.units.UnitsImporter(m3iModel);
    unitsImporter.importUnitsToDatabase(filename);

end
