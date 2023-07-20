function lutsizedisp=uniquifyLUTDetails(this,lutsizestr)





    lutsizedisp=[];
    uni_values=unique(lutsizestr);
    for n=1:length(uni_values)
        freq=sum(strcmp(lutsizestr,uni_values{n}));
        lutsizedisp=[lutsizedisp,[num2str(freq),'x',uni_values{n}]];
        if n<length(uni_values)
            lutsizedisp=[lutsizedisp,', '];
        end
    end


