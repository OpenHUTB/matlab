function generateTempName(h)




    if(isempty(h.TempName))
        [~,name]=fileparts(tempname);
        h.TempName=name;

        new_system(h.TempName,'FromTemplate','factory_default_model');
    end

end