function map=getParamCSHMap(obj,name)


    map='';
    path=obj.getParamCSHPath(name);
    if~isempty(path)&&iscell(path)
        last=path{end};
        if~endsWith(last,'.map')

            pageTag=obj.getParamPageTag(name);
            path{end+1}=['Simulink.ConfigSet@',pageTag,'.map'];
        end
        map=fullfile(docroot,strjoin(path,filesep));
    end