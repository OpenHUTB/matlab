function err=checkName(name)




    err=[];
    if~isvarname(name)
        err=MException(message('Simulink:Variants:InvalidModelName'));
    end
end
