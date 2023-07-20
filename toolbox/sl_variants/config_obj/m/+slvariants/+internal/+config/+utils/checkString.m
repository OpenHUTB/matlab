function err=checkString(s)



    err=[];
    if~Simulink.variant.utils.isCharOrString(s)
        err=MException(message('Simulink:Variants:ValueNotString'));
    end
end
