function shorter=shortPath(original)





    shorter=original;
    if length(original)>66
        [dPath,dName,dExt]=fileparts(original);
        if~isempty(dPath)
            if original(1)=='/'
                prefix='/...';
            else
                prefix=[original(1:3),'...'];
            end
            file=[dName,dExt];
            if length(file)>22
                shorter=[prefix,file];
            else
                shorter=[prefix,original(end-22:end)];
            end
        end
    end

end