function[result,subtype]=isSysArchObject(arg)






    subtype='';

    if sysarch.isLinkableViewElement(arg)
        result=true;
    elseif sysarch.isLinkableCompositionElement(arg)
        result=true;
    elseif isa(arg,'autosar.arch.CompPort')


        result=true;
        subtype='autosar';
    else
        result=false;
    end
end
