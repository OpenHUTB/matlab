function makeInfo=rtwmakecfg()

    archStr=computer('arch');
    makeInfo.precompile=1;

    if(strcmp(archStr,'win32'))

        makeInfo.linkLibsObjs={fullfile(matlabroot,'toolbox','shared','eda',...
        'fil','lib','win32','libmwfilcommon.lib')};

    elseif(strcmp(archStr,'win64'))
        compilerInfo=mex.getCompilerConfigurations('C','Selected');


        if isempty(compilerInfo)||~strcmp(compilerInfo.ShortName,'mingw64')
            makeInfo.linkLibsObjs={fullfile(matlabroot,'toolbox','shared','eda',...
            'fil','lib','win64','libmwfilcommon.lib')};
        else

            makeInfo.linkLibsObjs={fullfile(matlabroot,'extern','lib','win64',...
            'mingw64','libmwfilcommon.lib')};
        end
    else
        makeInfo.linkLibsObjs={fullfile(matlabroot,'bin',archStr,'libmwfilcommon.so')};
    end


    makeInfo.includePath={fullfile(matlabroot,'toolbox','shared','eda','fil','include','filcommon')};


