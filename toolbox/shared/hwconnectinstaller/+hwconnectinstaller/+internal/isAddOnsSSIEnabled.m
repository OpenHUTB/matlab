function enabled=isAddOnsSSIEnabled()








    if~isempty(getenv('MW_SSI_CLIENT'))&&strcmp(getenv('MW_SSI_CLIENT'),'SPILEGACYTEST')
        enabled=false;
    else
        enabled=true;
    end

end