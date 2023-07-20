function label=cleanGroupLabel(label)




    label=pmsl_sanitizename(sprintf(label));

    label=strrep(label,'  ',' ');


    label=strrep(label,' & ',' && ');

end