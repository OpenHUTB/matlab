function ret=isEcInstalled()













    ret=false;

    eCoderVersion=ver('embeddedcoder');

    if~isempty(eCoderVersion)
        ret=true;
    end


