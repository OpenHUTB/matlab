function proc=qxx(product,filesAndOptions)

    validateattributes(product,{'char','string'},{'nonempty'})
    product=validatestring(product,["parallelLinkDesigner","serialLinkDesigner",...
    "siViewer"]);
    import si.utilities.*
    product=string(product);
    pld=product=="parallelLinkDesigner";
    sld=product=="serialLinkDesigner";

    engineName=startEngine;%#ok<NASGU>

    [cmd,args,classpath]=launchCommand(product);
    setenv("CLASSPATH",classpath)
    if~isempty(filesAndOptions)&&(isstring(filesAndOptions)||ischar(filesAndOptions))
        filesAndOptions=string(filesAndOptions);
        for idx=1:length(filesAndOptions)
            fileOrOption=string(filesAndOptions{idx});
            if~startsWith(fileOrOption,"-")
                if pld||sld
                    [~,~,ext]=fileparts(fileOrOption);
                    if pld
                        interfaceExt=".edk";
                    else
                        interfaceExt=".qcd";
                    end
                    exts=[".script",interfaceExt];
                    if~any(strcmp(ext,exts))
                        oldWarnState=warning('off','backtrace');
                        warning(message('si:apps:FileExtRequired',fileOrOption,interfaceExt))
                        warning(oldWarnState.state,'backtrace')
                        proc=[];
                        return
                    end
                end


                scriptOrInterfaceFile=java.io.File(fileOrOption);
                if~scriptOrInterfaceFile.isAbsolute
                    scriptOrInterfaceFile=java.io.File(pwd,fileOrOption);
                    fileOrOption=string(scriptOrInterfaceFile.getCanonicalPath);
                end
                if~isfile(fileOrOption)
                    oldWarnState=warning('off','backtrace');
                    warning(message('si:apps:FileNotExist',fileOrOption))
                    warning(oldWarnState.state,'backtrace')
                    proc=[];
                    return
                end
            end
            filesAndOptions(idx)=fileOrOption;
        end
    else
        filesAndOptions="";
    end

    cmdArgs=[cmd,args];
    for idx=1:numel(filesAndOptions)
        cmdArgs(end+1)=filesAndOptions(idx);%#ok<AGROW>
    end


    if ispc
        pathVarName='PATH';
    else
        pathVarName='LD_LIBRARY_PATH';
    end
    savePath=getenv(pathVarName);
    setenv(pathVarName,[savePath,pathsep...
    ,fullfile(matlabroot,['extern/bin/',computer('arch')])]);

    si.utilities.updatePrefs
    try
        pb=java.lang.ProcessBuilder(cmdArgs);
        proc=pb.start;
    catch ex
        if(isa(ex,'matlab.exception.JavaException'))
            oldWarnState=warning('off','backtrace');
            warning(message('si:apps:CommandTooLong'))
            warning(oldWarnState.state,'backtrace')
            proc=[];
            return
        end

        setenv(pathVarName,savePath);
        rethrow ex;
    end




    setenv(pathVarName,savePath);

end
