function Result=ExecuteSCI(aObj)





    profileCallLib=slci.internal.Profiler('SLCI','CallSlciLib',...
    aObj.getModelName(),...
    aObj.getTargetName());


    Result=0;%#ok


    inBat=exist('qeinbat','file')&&qeinbat;
    if~inBat&&~CompilerInstalled()
        DAStudio.error('Slci:slci:ERROR_COMPILER')
    end

    slciLibName=slci.internal.getSLCILibName;

    slci.internal.loadSlciLibrary(slciLibName);


    try
        Result=calllib(slciLibName,'slciMain',aObj);
    catch ME
        aObj.HandleException(ME);
        Result=1;
    end
    slci.internal.unloadSlciLibrary(slciLibName);

    profileCallLib.stop();

end

function installed=CompilerInstalled()
    installed=false;
    c=mex.getCompilerConfigurations();
    for i=1:numel(c)
        if strcmpi(c(i).Language,'C')||strcmpi(c(i).Language,'C++')
            installed=true;
            return
        end
    end
end


