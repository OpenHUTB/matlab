function bValid=isValidProperty(h,propName)




    props=h.getPreferredProperties;
    bValid=ismember(propName,props);

end

