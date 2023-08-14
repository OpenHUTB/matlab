function booleanAnswer=sLSGIsModelReference(system)






    booleanAnswer=false;
    if(strcmp(get_param(system,'Type'),'block')==true)

        booleanAnswer=strcmp(get_param(system,'blockType'),...
        'ModelReference');

    else


    end

end

