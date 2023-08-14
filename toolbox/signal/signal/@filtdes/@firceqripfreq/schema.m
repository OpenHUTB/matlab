function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'firceqripfreq',findclass(pk,'abstractSpec'));


    if isempty(findtype('firceqripfreqopts'))
        schema.EnumType('firceqripfreqopts',{'cutoff','passedge','stopedge'});
    end
