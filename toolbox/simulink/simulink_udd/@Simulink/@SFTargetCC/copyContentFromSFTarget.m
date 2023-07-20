function copyContentFromSFTarget(hObj,hSFTarget)



    fields=hSFTarget.fields;

    for i=1:length(fields)
        prop=findprop(hSFTarget,fields{i});
        if~isempty(prop)
            try
                set(hObj,fields{i},get(hSFTarget,fields{i}));
            catch




            end
        end
    end


