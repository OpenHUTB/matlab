function[status]=power_openblockproxy(option)























    skipOpen=false;

    narginchk(0,1);
    if(nargin<1)
        option='mask';
    elseif(strcmpi(option,'secondary'))
        skipOpen=true;
    end

    licenseGood=power_checklicense('true');
    if(licenseGood==1&&skipOpen==false)
        open_system(gcbh,option);
    end

    status=licenseGood;
end