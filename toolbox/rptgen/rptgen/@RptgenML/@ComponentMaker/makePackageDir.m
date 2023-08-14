function makePackageDir(this)





    if isempty(this.PkgName)
        error(message('rptgen:RptgenML_ComponentMaker:missingPackageName'));
    end

    [~,pkgDir,pkgExists]=isComponentBuilt(this,true);

    if~pkgExists

        [ok,errMsg]=mkdir(pkgDir,['@',this.PkgName]);
        if ok==0
            error(message('rptgen:RptgenML_ComponentMaker:makePkgDirError',errMsg));
        end

        schemaFileName=fullfile(pkgDir,['@',this.PkgName],'schema.m');
        fid=fopen(schemaFileName,'w');
        if fid==0
            error(message('rptgen:RptgenML_ComponentMaker:missingConstructor'));
        end

        fprintf(fid,'function schema\n%%SCHEMA creates the %s user object package\n',...
        this.PkgName);

        this.writeHeader(fid);

        fprintf(fid,'%% ***************************************************** \n');
        fprintf(fid,'%% * This SCHEMA file format will change in a future   * \n');
        fprintf(fid,'%% * version of MATLAB.  Modifying this file could     * \n');
        fprintf(fid,'%% * prevent automatic conversion of this package      * \n');
        fprintf(fid,'%% * in the future.                                    * \n');
        fprintf(fid,'%% ***************************************************** \n\n');

        fwrite(fid,sprintf('schema.package(''%s'');\n',this.PkgName));

        fclose(fid);

        if~this.isWriteHeader
            try
                pcode(schemaFileName,'-inplace');
            catch ME
                warning(ME.message);
            end
            delete(schemaFileName);
        end
    end

    this.PkgDir=pkgDir;
