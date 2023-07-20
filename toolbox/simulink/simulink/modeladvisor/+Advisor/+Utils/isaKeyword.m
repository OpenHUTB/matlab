function[bKeyword,bFileExist,sFilePath]=isaKeyword(sIdentifier)











    persistent xmlNames;
    if isempty(xmlNames)
        xmlNames=Advisor.Utils.Naming.getReservedNames();
    end

    bFileExist=false;
    sFilePath=[];

    bKeyword=ismember(lower(sIdentifier),lower(xmlNames));
    if~bKeyword

        if exist(sIdentifier,'builtin')
            bKeyword=true;
        elseif exist(sIdentifier,'file')
            bFileExist=true;
            sFilePath=which(sIdentifier);
            if contains(sFilePath,'is a Java method')
                bKeyword=true;
            else
                bKeyword=contains(sFilePath,matlabroot)&&~contains(sFilePath,[matlabroot,filesep,'test',filesep])&&(endsWith(sFilePath,'.m')||endsWith(sFilePath,'.p'));
            end
        end
    end
end

