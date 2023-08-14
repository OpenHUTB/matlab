function buildMwtle(s,dispflag)










    assert(ispc)
    if nargin<2
        dispflag=false;
    end
    delete(fullfile(s.tle_wrapper_dir,'library','*.c'));
    delete(fullfile(s.tle_wrapper_dir,'library','*.h'));

    tempDir=tempname;
    mkdir(tempDir);
    mkdir(fullfile(tempDir,'codegen'))
    if dispflag
        disp('Calling mwtle_coder_function')
    end
    rf.internal.wline.mwtle_coder_function(tempDir,dispflag);
    if dispflag
        disp('Done with mwtle_coder_function')
    end

    unzip(fullfile(tempDir,'mwtle.zip'),fullfile(tempDir,'library'));
    copyfile(fullfile(matlabroot,'toolbox','rf','rf','+rf','+internal','+wline','mwtle.vcxproj'),tempDir);
    copyfile(fullfile(matlabroot,'toolbox','rf','rf','+rf','+internal','+wline','mwtle.c'),tempDir);
    copyfile(fullfile(matlabroot,'toolbox','rf','rf','+rf','+internal','+wline','mwtle.h'),tempDir);

    copyfile(fullfile(tempDir,'library','*.c'),fullfile(s.tle_wrapper_dir,'library'),'f');
    copyfile(fullfile(tempDir,'library','*.h'),fullfile(s.tle_wrapper_dir,'library'),'f');
    copyfile(fullfile(tempDir,'mwtle.c'),s.tle_wrapper_dir,'f');
    copyfile(fullfile(tempDir,'mwtle.h'),s.tle_wrapper_dir,'f');
    if dispflag
        disp('Calling msbuild.exe')
    end
    buildStr=[s.msBuildStr,' ',s.solution_file,'/t:Rebuild /p:Configuration=SiSoftRxDbg;Platform=Win32'];
    system(buildStr);
    system(buildStr);
    rmdir(tempDir,"s");
end

