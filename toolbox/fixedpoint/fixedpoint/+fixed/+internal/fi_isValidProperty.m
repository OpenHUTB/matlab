function t=fi_isValidProperty(this,propName)




    props=getPossibleProperties(this);
    switch propName
    case props
        t=true;
    otherwise
        t=false;
    end
end