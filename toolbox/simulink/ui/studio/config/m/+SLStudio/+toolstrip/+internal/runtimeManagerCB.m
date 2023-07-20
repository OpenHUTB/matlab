function runtimeManagerCB(~,~)





    try
        fullpathToUtility=which('linux.RuntimeManager.open');

        if isempty(fullpathToUtility)

            error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled',...
            'Embedded Coder Support Package For Linux Applications',...
            'ECLINUX')));
        else

            linux.RuntimeManager.open();
        end
    catch e
        throwAsCaller(e);
    end
end


