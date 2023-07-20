function[classExists,pkgDir,pkgExists]=isComponentBuilt(this,forcePkgDir)












    pkgDir=this.PkgDir;
    if isdir(fullfile(pkgDir,['@',this.PkgName]))
        pkgExists=true;
        classExists=exist(fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],'schema.m'),'file')||...
        exist(fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],'schema.p'),'file');
        return;
    end


    dirInfo=what(['@',this.PkgName]);

    for i=1:length(dirInfo)
        if~isempty(find(strcmp(dirInfo(i).m,'schema.m')))||...
            ~isempty(find(strcmp(dirInfo(i).p,'schema.p')))
            pkgDir=fileparts(dirInfo(i).path);
            pkgExists=true;
            classExists=any(strcmp(dirInfo(i).classes,this.ClassName));
            return;
        end
    end

    classExists=false;
    pkgExists=false;

    if~isdir(pkgDir)&&nargin>1&&forcePkgDir
        pkgDir=pwd;
    end

