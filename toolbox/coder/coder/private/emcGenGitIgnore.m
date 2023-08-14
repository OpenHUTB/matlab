function emcGenGitIgnore(dir)




    ignoreFileName='.gitignore';
    fullPath=fullfile(dir,ignoreFileName);
    if isfile(fullPath)
        return;
    end

    ignores=[
"*.asv"
"*.m~"
"*.mex*"
"*.o"
"*.obj"
"*.dll"
"*.so"
"*.dylib"
"*.a"
"*.lib"
"*.exe"
"*.map"
"*.rsp"
"*.tmw"
"*.mat"
"sil/"
"interface/_coder_*_info.*"
"coderassumptions/"
"target/"
"build/"
"debug/"
"*.slxc"
    ];

    fid=fopen(fullPath,'w');

    fprintf(fid,'%s\n',ignores.join(newline));

    fclose(fid);


