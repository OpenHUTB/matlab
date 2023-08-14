function makeInfo=rtwmakecfg()








    archStr=computer('arch');
    makeInfo.precompile=1;

    if(strcmp(archStr,'win32'))

        makeInfo.linkLibsObjs={fullfile(matlabroot,'toolbox','edalink','foundation',...
        'eda_extern','eda_extern_vsw32.lib')};
        try

            compilerinfo=mex.getCompilerConfigurations('C','Selected');
            if(strcmp(compilerinfo.Name,'Lcc-win32'))
                makeInfo.linkLibsObjs={fullfile(matlabroot,'toolbox','edalink','foundation',...
                'eda_extern','eda_extern_lccw32.lib')};
            end
        catch ME %#ok<NASGU>

        end
    elseif(strcmp(archStr,'win64'))
        makeInfo.linkLibsObjs={fullfile(matlabroot,'toolbox','edalink','foundation',...
        'eda_extern','eda_extern_vsw64.lib')};
    else
        makeInfo.linkLibsObjs={fullfile(matlabroot,'bin',archStr,'libmweda_extern.so')};
    end


    makeInfo.includePath={fullfile(matlabroot,'toolbox','edalink','foundation','eda_extern','export','include'),...
    fullfile(matlabroot,'toolbox','edalink','foundation','shdltovcd_core','export','include')};


