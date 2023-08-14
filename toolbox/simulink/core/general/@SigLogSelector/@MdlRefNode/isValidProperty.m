function bValid=isValidProperty(~,propName)




    switch propName
    case{'logAsSpecifiedInMdl'}
        bValid=true;
    otherwise
        bValid=false;
    end

end

