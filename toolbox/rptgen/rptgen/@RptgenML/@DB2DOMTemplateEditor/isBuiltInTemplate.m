function tf=isBuiltInTemplate(this)




    [path,~,~]=fileparts(this.TemplatePath);
    path=strrep(path,'\\','/');
    toolboxDir=fullfile(matlabroot,'toolbox');
    toolboxDir=strrep(toolboxDir,'\\','/');

    tf=~isempty(strfind(path,toolboxDir));

