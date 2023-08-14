function makeSchema(h,fileName)




    if nargin<2
        fileName='schema.m';
    end

    fid=h.openFile(fileName);

    fprintf(fid,'function schema\n%%SCHEMA defines object properties\n');

    h.writeHeader(fid);

    fprintf(fid,'%% ***************************************************** \n');
    fprintf(fid,'%% * This SCHEMA file format will change in a future   * \n');
    fprintf(fid,'%% * version of MATLAB.  Modifying this file could     * \n');
    fprintf(fid,'%% * prevent automatic conversion of this class        * \n');
    fprintf(fid,'%% * in the future.                                    * \n');
    fprintf(fid,'%% ***************************************************** \n\n');

    fprintf(fid,'pkg = findpackage(''%s'');\n',h.PkgName);
    fprintf(fid,'pkgRG = findpackage(''rptgen'');\n\n');
    fprintf(fid,'h=schema.class(pkg,''%s'',pkgRG.findclass(''rptcomponent''));\n',h.ClassName);

    thisProp=h.down;
    while~isempty(thisProp)
        fwrite(fid,thisProp.toString);
        thisProp=thisProp.right;
    end

    fprintf(fid,'%%------ designate static methods -------\nrptgen.makeStaticMethods(h,{\n},{\n});\n');

    fclose(fid);

    if h.isWriteHeader

        h.viewFile(fileName);
    else
        try
            pcode(fullfile(h.ClassDir,fileName),'-inplace');
        catch ME
            warning('rptgen:ComponentMaker:PcodeFailure',ME.message);
        end
        delete(fullfile(h.ClassDir,fileName));
    end
