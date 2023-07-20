function[value,annotations]=deannotate(value)



    if isa(value,'codergui.internal.util.AnnotatedValue')
        annotations=value.Annotations;
        value=value.Value;
    else
        annotations=[];
    end
end