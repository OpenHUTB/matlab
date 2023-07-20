function b=isPropertyCascaded(this,property)






    list=getCascadedProperties(this);

    b=~isempty(strmatch(lower(property),lower(list)));


