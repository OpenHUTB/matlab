
function newSource=tryToAdjustFilePaths(source,errorIfFileNotFound)

    pathName=pwd;
    newSource=cell(size(source));
    for i=1:numel(source)



        newSourceName=regexprep(source{i},'[\\/]',filesep);
        if~isempty(newSourceName)
            [~,fileName,ext]=fileparts(newSourceName);

            fileName=strcat(fileName,ext);
            absoluteFileName=fullfile(pathName,fileName);
            newSource{i}=vision.internal.uitools.tryToAdjustPath(source{i},...
            pathName,absoluteFileName,'FileNotFoundError',errorIfFileNotFound);
        end
    end
end
