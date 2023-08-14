function initialize(varargin)









    autosar.api.Utils.autosarlicensed(true);

    argParser=inputParser;
    argParser.addParameter('PipeDir','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.parse(varargin{:});

    if~isempty(argParser.Results.PipeDir)
        pipeDir=argParser.Results.PipeDir;
    else
        pipeDir='/tmp';
    end
    initializeDLT(pipeDir);
end

function initializeDLT(pipeDir)
    dltDaemonRunCheckCom='ps -ef | grep -i "dlt-daemon" | grep -v "grep"';
    [status,~]=system(dltDaemonRunCheckCom);
    if(status~=0)
        dltDaemonPath=fullfile(matlabroot,'bin','glnxa64',...
        'dlt-daemon','bin','dlt-daemon');
        if~isfile(dltDaemonPath)

            dltDaemonPath=fullfile(matlabshared.supportpkg.getSupportPackageRoot,'bin','glnxa64',...
            'dlt-daemon','bin','dlt-daemon');
            if~isfile(dltDaemonPath)

                error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled',...
                'Embedded Coder Support Package For Linux Applications',...
                'ECLINUX')));
            end
        end

        dltDaemonLaunchCom=['nohup "',dltDaemonPath,'" -t "',pipeDir,'" &'];
        system(dltDaemonLaunchCom);
    end
end


