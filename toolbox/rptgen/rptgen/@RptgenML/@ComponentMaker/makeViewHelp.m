function makeViewHelp(thisCM)




    fileName='viewHelp';
    fid=thisCM.openFile([fileName,'.m']);

    fprintf(fid,'function %s(thisComp)\n%%%s Opens a help viewer for the component\n',...
    fileName,upper(fileName));

    thisCM.writeHeader(fid);

    fprintf(fid,'pkgDir = what(''@%s'');\n',thisCM.PkgName);
    fprintf(fid,'if ~isempty(pkgDir)\n');
    fprintf(fid,'    helpFile = fullfile(pkgDir(1).path,''@%s'',''_help.html'');\n',thisCM.ClassName);
    fprintf(fid,'    helpview(helpFile);\n');
    fprintf(fid,'else\n');
    fprintf(fid,'    error(''rptgen:NoHelpFile'',''Could not find help file'');\n');
    fprintf(fid,'end\n');

    helpFile=strrep(fullfile(thisCM.ClassDir,'_help.html'),...
    '''','''''');

    fprintf(fid,'\n%% (optional) Call help with a mapfile\n%% For more information on mapfiles, type HELP HELPVIEW\n');
    fprintf(fid,'%% helpview(fullfile(matlabroot,''custom_mapfile.map''),[''obj.'',class(thisCM)]);\n');
    fprintf(fid,'%% Add a line to your mapfile:\n%% obj.%s.%s   %s\n',thisCM.PkgName,thisCM.ClassName,helpFile);

    fclose(fid);

    thisCM.viewFile([fileName,'.m'],3);
