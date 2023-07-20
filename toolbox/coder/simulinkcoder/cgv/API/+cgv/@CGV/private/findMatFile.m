
function fullFileName=findMatFile(this,fileName)



    if~ischar(fileName)
        stk=dbstack;
        DAStudio.error('RTW:cgv:FileParamToFcnMustBeString',stk(2).name);
    end
    [~,~,ext]=fileparts(fileName);
    if isempty(ext)
        nameWithExt=[fileName,'.mat'];
    elseif strcmp(ext,'.mat')
        nameWithExt=fileName;
    else
        DAStudio.error('RTW:cgv:BadExtension',fileName);
    end
    fullFileName=findFile(this,nameWithExt);
end

