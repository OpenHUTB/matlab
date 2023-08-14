classdef SessionDataSerializer<handle

    properties
filename
session
    end

    properties(Access=private)
safemovecommand
ephemeralSessionDir
        droolCheckTimeInSeconds=600;
logger
    end

    methods

        function this=SessionDataSerializer(session,filename,asyncCmd)
            this.session=session;
            this.filename=filename;
            this.logger=connector.internal.Logger('connector::session_m');
            this.safemovecommand=fullfile(matlabroot,'toolbox',...
            'matlab','connector2','session',asyncCmd);
            this.ephemeralSessionDir=fullfile(...
            tempdir,'SESSION_CACHE',asyncCmd);
        end

        function result=hasFolder(this)
            result=exist(this.session.sessionDir,'dir');
        end

        function result=hasFile(this)
            result=exist(this.getPermanentFile(),'file');
        end

        function clear(this)
            if this.hasFile()
                delete(this.getPermanentFile());
            end
            if this.hasEphemeralFile()
                delete(this.getEphemeralFile());
            end
        end

        function save(this,state)
            this.ensureFolderCreated();
            save(this.getPermanentFile(),'state');
        end

        function saveasync(this,state)
            this.ensureFolderCreated();
            this.ensureEphemeralFolderCreated();

            if~isProcessRunning(getFileName(this.safemovecommand))

                ephemeralSaveStartTime=tic;
                save(this.getEphemeralFile(),'state');
                ephemeralSaveEndTime=toc(ephemeralSaveStartTime);

                this.logger.info(['SaveSession: Time taken to save'...
                ,'ephemeral session file at ',this.getEphemeralFile()...
                ,': ',num2str(ephemeralSaveEndTime)]);

                this.clearDroolFiles(this.droolCheckTimeInSeconds);

                [suffix,~]=getSuffixUsedBySafemv();
                unix(['"',this.safemovecommand,'" "',...
                this.getEphemeralFile(),'" "',...
                this.getPermanentFile(),'" ',...
                suffix,' &']);
            else
                this.logger.info(['SaveSession: Busy moving previous '...
                ,'session file']);
            end
        end

        function[state,loaded]=load(this)
            state=struct;
            loaded=false;

            if~this.hasFolder()
                error('Session directory does not exist: %s',...
                this.session.sessionDir);
            end

            if this.hasFile
                this.ensureEphemeralFolderCreated();
                this.clearDroolFiles(0);
                data=load(this.getPermanentFile(),'state');
                state=data.state;
                loaded=true;
            end
        end


    end

    methods(Access=private)

        function f=getPermanentFile(this)
            f=fullfile(this.session.sessionDir,this.filename);
        end

        function f=getEphemeralFile(this)
            f=fullfile(this.ephemeralSessionDir,this.filename);
        end

        function result=hasEphemeralFolder(this)
            result=exist(this.ephemeralSessionDir,'dir');
        end

        function result=hasEphemeralFile(this)
            result=exist(this.getEphemeralFile(),'file');
        end

        function ensureFolderCreated(this)
            if~this.hasFolder()
                [success,message]=mkdir(this.session.sessionDir);
                if(success==false)
                    error('Invalid session directory: %s',message);
                end
            end
        end

        function ensureEphemeralFolderCreated(this)
            if~this.hasEphemeralFolder()
                [success,message]=mkdir(this.ephemeralSessionDir);
                if(success==false)
                    error('Invalid ephemeral directory: %s',message);
                end
            end
        end



        function clearDroolFiles(this,staleTime)
            stateFile=this.getPermanentFile();
            [pathstr,name,ext]=fileparts(stateFile);
            [~,droolSuffixPattern]=getSuffixUsedBySafemv();
            deleteStaleFiles(...
            pathstr,...
            [name,ext,droolSuffixPattern],...
staleTime...
            );
        end

    end

end



function processRunning=isProcessRunning(processName)
    command=['ps cax | grep -c ',processName];
    [~,cmdout]=system(command);
    processRunning=str2double(cmdout);
end


function filename=getFileName(path)
    [~,name,ext]=fileparts(path);
    filename=[name,ext];
end


function deleteStaleFiles(path,filename,staleTime)
    files=fullfile(path,filename);
    dirInfo=dir(files);


    warnState(1)=warning('off','MATLAB:DELETE:FileNotFound');
    warnState(2)=warning('off','MATLAB:DELETE:Permission');

    for i=1:size(dirInfo,1)
        createdTime=datevec(dirInfo(i).datenum);
        if(etime(clock,createdTime)>staleTime)
            delete(fullfile(path,dirInfo(i).name));
        end
    end


    warning(warnState);
end





function[suffixValue,suffixPattern]=getSuffixUsedBySafemv()
    [~,suffix,~]=fileparts(tempname);
    suffixValue=['.eph',suffix];
    suffixPattern='.eph*';
end

