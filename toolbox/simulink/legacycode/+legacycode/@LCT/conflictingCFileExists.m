function bool=conflictingCFileExists(lctSpec)






    bool=0;


    if strcmp(lctSpec.Options.language,'C')
        fext='.c';
    else
        fext='.cpp';
    end
    sfcnName=char(lctSpec.SFunctionName);
    cFile=fullfile(pwd,[sfcnName,fext]);

    if exist(cFile,'file')

        [fid,msg]=fopen(cFile,'r');
        if fid==-1
            error(message('Simulink:tools:LCTErrorCannotOpenFile',...
            sfcnName,fext,['(',msg,')']));
        end
        cFileContents=fread(fid,[1,inf],'*char');
        fclose(fid);


        s1=regexp(cFileContents,...
        ['(#define\s+S_FUNCTION_NAME\s+',sfcnName,')'],'once');

        s2=regexp(cFileContents,'(#define\s+S_FUNCTION_LEVEL\s+2)','once');



        if isempty(s1)||isempty(s2)
            bool=1;
        end
    end

    if nargout==0&&bool==1
        error(message('Simulink:tools:LCTWarnFileConflict',cFile));
    end

