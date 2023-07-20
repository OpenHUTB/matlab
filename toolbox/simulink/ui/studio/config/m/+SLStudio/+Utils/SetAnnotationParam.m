function SetAnnotationParam(notes,param,value)




    for i=1:length(notes)
        set_param(notes(i),param,value);
    end
end
