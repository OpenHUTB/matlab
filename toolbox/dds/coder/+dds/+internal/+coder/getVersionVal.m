function versionval=getVersionVal(verstr)










    strs=regexp(verstr,'\d+','match');
    if numel(strs)<1
        versionval=0;
        return;
    end
    versionval=str2double(strs{1})*10000;
    if numel(strs)>1
        versionval=versionval+str2double(strs{2})*100;
        if numel(strs)>2
            versionval=versionval+str2double(strs{3});
        end
    end
