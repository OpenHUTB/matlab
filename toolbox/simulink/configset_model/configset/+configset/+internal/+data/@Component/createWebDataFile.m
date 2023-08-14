function createWebDataFile(obj,dirName)



    disp(['  building ',obj.Name,' web data ...']);

    n=length(obj.ParamList);
    s=cell(n,1);

    for i=1:n
        p=obj.ParamList{i};
        s{i}=p.getInfo;
    end

    a.comp_class=obj.Class;
    a.comp_key=obj.NameKey;
    a.comp_name=obj.Name;
    if strcmp(obj.Class,'Simulink.CPPComponent')
        a.comp_type='Base';
    else
        a.comp_type=obj.Type;
    end
    a.params=s;

    json=jsonencode(a);

    fileName=[obj.Class,'.json'];
    file=fullfile(dirName,fileName);
    fid=fopen(file,'w');
    fprintf(fid,'%s',json);
    fclose(fid);






