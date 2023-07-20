function app=getApplication(use_current)





    try
        app=actxGetRunningServer('word.application');
    catch Mex %#ok
        if nargin>0&&use_current
            error(message('Slvnv:rmiref:DocCheckWord:WordNotRunning'));
        else
            app=actxserver('word.application');
        end
    end

end
