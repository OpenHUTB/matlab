function loadComponent(this,existingComponent)





    exCompClass=existingComponent.classhandle;

    pkgName=exCompClass.Package.Name;

    if(~this.isWriteHeader)


        tbxDir=toolboxdir('');
        pkgDir=what(['@',pkgName]);

        if(~isempty(pkgDir))
            pkgDir=pkgDir(1).path;




            if(ispc())
                pkgDir=lower(pkgDir);
            end


            if(~isempty(findstr(tbxDir,pkgDir)))
                pkgName=[pkgName,getString(message('rptgen:RptgenML_ComponentMaker:customLabel'))];
            end
        end
    end

    this.PkgName=pkgName;

    whatInfo=what(['@',this.PkgName]);
    if(~isempty(whatInfo))
        this.PkgDir=whatInfo(1).path;
    end

    this.ClassName=exCompClass.Name;

    this.DisplayName=existingComponent.getName;
    this.Description=existingComponent.getDescription;


    sClass=findclass(findpackage('rptgen'),'rptcomponent');
    sProps=get(sClass.Properties,'Name');

    for i=1:length(exCompClass.Properties)
        thisProp=exCompClass.Properties(i);


        isRptComponent=isa(existingComponent.(thisProp.Name),'rptgen.rptcomponent');

        if(~any(strcmp(sProps,thisProp.Name))&&...
            strcmp(thisProp.Visible,'on')&&...
            ~isRptComponent)

            this.addProperty(thisProp);
        end
    end

    this.Type=existingComponent.getType;
    this.Parentable=existingComponent.getParentable;
