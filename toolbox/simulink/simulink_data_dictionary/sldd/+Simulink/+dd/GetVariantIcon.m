function iconpath=GetVariantIcon(ddConn,baseIcon,variantCondition)

    [path,name,ext]=fileparts(baseIcon);


    active=false;
    if~isempty(variantCondition)
        try
            active=evalin(ddConn,variantCondition);
        catch
            active=false;
        end
    end

    if active
        iconpath=[path,filesep,'activevariants',filesep,name,ext];
    else
        iconpath=[path,filesep,'variants',filesep,name,ext];
    end

end
