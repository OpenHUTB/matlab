function varargout=viewAllFiles(this,filePriority)







    if nargin<2
        filePriority=2;
    end

    [canView,pkgDir]=isComponentBuilt(this,false);

    mFiles=[];
    if canView
        try
            mFiles=dir(fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],'*.m'));
        end
    end

    if isempty(mFiles)
        if nargout>0;varargout{1}=canView;end;return;
    else
        canView=true;
        if filePriority<0
            if nargout>0;varargout{1}=canView;end;return;
        else

            hFiles=dir(fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],'*.html'));
            for i=1:length(hFiles)
                edit(fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],hFiles(i).name));
            end

            xFile=fullfile(pkgDir,['@',this.PkgName],'rptcomps2.xml');
            if exist(xFile,'file')
                edit(xFile);
            end

            for i=1:length(mFiles)
                edit(fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],mFiles(i).name));
            end

            eFile=fullfile(pkgDir,['@',this.PkgName],['@',this.ClassName],'execute.m');
            if exist(eFile,'file')


                edit(eFile);
            end
        end
    end