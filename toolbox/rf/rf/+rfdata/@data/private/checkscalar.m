function checkscalar(h,a_param,lcounter,blocktype,description)




    if~isscalar(a_param)
        error(message('rf:rfdata:data:checkscalar:onlyscalarallowed',description,blocktype,lcounter));
    end