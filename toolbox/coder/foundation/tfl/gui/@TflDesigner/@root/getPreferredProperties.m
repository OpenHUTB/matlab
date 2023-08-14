function props=getPreferredProperties(this)%#ok




    persistent rootprops;
    if isempty(rootprops)
        rootprops={'Name'};
    end
    props=rootprops;