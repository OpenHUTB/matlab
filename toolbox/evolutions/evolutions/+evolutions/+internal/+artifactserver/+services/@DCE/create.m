function tf=create(obj,data)





    key=data.Id;



    if obj.iskeyInDB(key)
        tf=true;
        return;
    end


    [~,name,ext]=fileparts(data.File);
    ext=convertStringsToChars(ext);

    if(isequal(ext,'.slx')||isequal(ext,'.mdl'))

        storedCost=obj.runCostAnalysis(name);


        obj.addToDb(key,storedCost);

    end

    tf=true;
end


