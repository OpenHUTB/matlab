function flag=checkChangedProp(obj,prop)




    flag=~isequal(obj.(prop),obj.(['p',prop,'Old']));
    obj.(['p',prop,'Old'])=obj.(prop);
end
