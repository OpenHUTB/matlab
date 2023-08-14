function xmlFiles=getXmlFiles(obj)




    xmlFiles=cell.empty;
    if isfolder(obj.ArtifactRootFolder)
        folders=dir(obj.ArtifactRootFolder);

        for idx=1:numel(folders)
            fullFile=fullfile(obj.ArtifactRootFolder,folders(idx).name,...
            sprintf('%s%s',folders(idx).name,'.xml'));
            if isfile(fullFile)
                xmlFiles{end+1}=convertStringsToChars(fullFile);%#ok<AGROW>
            end
        end
    end
