function absolutePath=getAbsoluteFolderPath(folderPath)





    pathParts=split(folderPath,filesep);


    pathParts=cellfun(@replaceEmpties,pathParts,'UniformOutput',false);
    if strcmp(pathParts{1},filesep)

        absolutePath=folderPath;
    elseif isfolder(fullfile(pathParts{1},filesep))
        [~,message,~]=fileattrib(fullfile(pathParts{1},filesep));


        absolutePath=fullfile(message.Name,pathParts{2:end});
    else



        absolutePath=fullfile(pwd,folderPath);
    end



end

function newPathPart=replaceEmpties(pathPart)

    if isempty(pathPart)
        newPathPart=filesep;
    else
        newPathPart=pathPart;
    end
end
