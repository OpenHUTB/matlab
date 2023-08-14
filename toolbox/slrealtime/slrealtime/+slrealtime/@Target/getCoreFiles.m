function corefiles=getCoreFiles(tg,varargin)






    p=inputParser;
    addParameter(p,'nodownload',false);
    parse(p,varargin{:});

    corefiles={};

    rootssh=tg.getRootSSHObj();
    res=tg.executeCommand('find /root -maxdepth 1 -name "*.core"',rootssh);

    corefullfiles=strsplit(res.Output,char(10));%#ok<CHARTEN>
    for i=1:numel(corefullfiles)
        try
            if(~isempty(corefullfiles{i}))
                [~,name,ext]=fileparts(corefullfiles{i});
                corefile=[name,ext];
                if isfile(tg,corefullfiles{i})
                    if~p.Results.nodownload
                        tg.executeCommand(['chown slrt ',corefullfiles{i}],rootssh);
                        tg.receiveFile(corefullfiles{i},fullfile(pwd,corefile));
                        cmd=sprintf('rm %s',corefullfiles{i});
                        tg.executeCommand(cmd,rootssh);
                    end
                    corefiles{end+1}=corefile;%#ok<AGROW>
                end
            end
        catch ME
            warning(message('slrealtime:target:couldNotRetrieveCoreFile',corefullfiles{i},ME.message));
        end
    end
end
