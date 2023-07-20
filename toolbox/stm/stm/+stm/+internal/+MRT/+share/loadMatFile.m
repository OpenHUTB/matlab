


function[varsLoaded,vars]=loadMatFile(filePath)
    vars=load(filePath);
    varsLoaded=fieldnames(vars);
    cellfun(@(field)assignin('base',field,vars.(field)),varsLoaded);
end
