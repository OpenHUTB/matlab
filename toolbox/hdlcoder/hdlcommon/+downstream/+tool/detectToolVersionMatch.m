function[isMatch,matchedVer2]=detectToolVersionMatch(ver1,ver2List)




    isMatch=false;
    matchedVer2='';

    for ii=1:length(ver2List)
        ver2=ver2List{ii};
        matchToolVer=downstream.tool.isToolVersionMatch(ver1,ver2);
        if matchToolVer
            isMatch=true;
            matchedVer2=ver2;
            return;
        end
    end

end