function path=slrealtimeroot






    if isdeployed
        path=fullfile(ctfroot,'toolbox','slrealtime');
    else
        path=fullfile(matlabroot,'toolbox','slrealtime');
    end
