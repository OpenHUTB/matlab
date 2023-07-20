function booleanAnswer=loc_IsModelReference(system)






    booleanAnswer=false;
    if(strcmp(get_param(system,'Type'),'block')==true)

        booleanAnswer=strcmp(get_param(system,'blockType'),...
        'ModelReference');

    else


    end

end

