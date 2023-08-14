function generateRtwProjFile(lModelName,templateMakefile,...
    buildFolder,...
    lStartDirToRestore,...
    lRelativePathToAnchor,...
    varargin)







    persistent p
    if isempty(p)
        p=inputParser;
        addParameter(p,'InfoMATFileName','',@ischar)
    end
    parse(p,varargin{:});
    rtwinfomatfilename=p.Results.InfoMATFileName;


    rtwProjFile=fullfile(buildFolder,'rtw_proj.tmw');
    simStructDirInfo=dir(fullfile(matlabroot,'simulink','include','simstruc.h'));
    rtwProjFileContents1=['Simulink Coder project for ',lModelName,...
    ' using ',templateMakefile,...
    '. MATLAB root = ',matlabroot,...
    '. SimStruct date: ',simStructDirInfo.date];
    rtwProjFileContents2=['This file is generated by Simulink Coder ',...
    'for use by the make utility\nto determine when to ',...
    'rebuild objects when the name of the current Simulink ',...
    'Coder project changes.\n'];

    if~isempty(rtwinfomatfilename)


        if strncmp(lStartDirToRestore,rtwinfomatfilename,length(lStartDirToRestore))
            rtwinfomatfilename=fullfile(lRelativePathToAnchor,...
            rtwinfomatfilename(length(lStartDirToRestore)+1:end));
        end
    end
    rtwProjFileContents3=['The rtwinfomat located at: ',rtwinfomatfilename];

    rtmDefMexp='';
    if~isempty(dir(rtwProjFile))
        fid=fopen(rtwProjFile,'rt');
        if fid==-1
            DAStudio.error('RTW:utility:fileIOError',rtwProjFile,'open');
        end

        line1=fgetl(fid);




        for i=1:3
            line4=fgetl(fid);
        end
        fclose(fid);

        dowrite=(~strcmp(line1,rtwProjFileContents1))||...
        (~strcmp(line4,rtwProjFileContents3));
    else
        dowrite=1;
    end

    if dowrite
        fid=fopen(rtwProjFile,'wt');
        if fid==-1
            DAStudio.error('RTW:utility:fileIOError',rtwProjFile,'open');
        end
        fprintf(fid,'%s\n',rtwProjFileContents1);
        fprintf(fid,rtwProjFileContents2);
        fprintf(fid,'%s\n',rtwProjFileContents3);
        fprintf(fid,rtmDefMexp);
        fclose(fid);
    end
