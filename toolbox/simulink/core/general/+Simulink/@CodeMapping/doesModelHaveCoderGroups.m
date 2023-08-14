function out=doesModelHaveCoderGroups(modelH)






    out=false;
    coderGroups=get_param(modelH,'CoderGroups');
    if~isempty(coderGroups)
        out=true;
    end
end
