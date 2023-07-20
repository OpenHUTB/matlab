function saveTire(tire)




    if~isempty(tire.DIR)
        str1=[tire.DIR,filesep,tire.NAME,'.mat'];
    else
        str1=[tire.NAME,'.mat'];
    end

    str2=['save(''',str1,''',''',inputname(1),''')'];
    evalin('base',str2);
end

