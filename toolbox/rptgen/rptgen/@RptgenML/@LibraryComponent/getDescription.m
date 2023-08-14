function d=getDescription(libC,varargin)







    if~isempty(varargin)&&...
        ischar(varargin{1})&&...
        strcmp(varargin{1},'-deferred')&&...
        ~isClassLoaded(libC)
        d=getString(message('rptgen:RptgenML_LibraryComponent:loadingDescMsg'));






        libC.ComponentInstance=libC;


        mlreportgen.utils.internal.defer(@()libC.getDescription('-update'));
        return;

    end

    try
        d=feval([libC.ClassName,'.getDescription']);
    catch ME
        errMsg=ME.message;
        crLoc=findstr(errMsg,char(10));
        if~isempty(crLoc)
            errMsg=errMsg(crLoc(1)+1:end);
        end
        d=[getString(message('rptgen:RptgenML_LibraryComponent:noDescMsg')),char(10),errMsg];
    end


    if nargin>1&&ischar(varargin{1})&&strcmp(varargin{1},'-update')

        r=RptgenML.Root;
        if~isempty(r.Editor)
            dlg=r.Editor.getDialog;
            if~isempty(dlg)
                dlg.refresh;
            end
        end
    end


    function isLoaded=isClassLoaded(this)

        isLoaded=~isempty(this.ComponentInstance);
        if~isLoaded
            dotLoc=findstr(this.ClassName,'.');
            if~isempty(dotLoc)
                pkgName=this.ClassName(1:dotLoc-1);
                clsName=this.ClassName(dotLoc+1:end);
                pkg=findpackage(pkgName);
                if~isempty(pkg)&&~isempty(pkg.Classes)
                    isLoaded=~isempty(find(pkg.Classes,'Name',clsName));
                end
            end
        end
