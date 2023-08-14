function asbhmihelp(doc_tag)









    narginchk(0,1);


    if~(builtin('license','checkout','Aerospace_Toolbox')&&...
        builtin('license','checkout','Aerospace_Blockset'))


        error(message('aeroblksHMI:aeroblkhmi:licenseFailAeroDoc'));
    end

    mapfile_location=fullfile(docroot,'toolbox','aeroblks','aeroblks.map');




    helpview(mapfile_location,doc_tag);
