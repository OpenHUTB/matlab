classdef QueryHistoryMgr<handle






    properties(Access=private)
historyFile
queryHistory

    end

    methods(Access=private)

        function this=QueryHistoryMgr()
            this.historyFile=this.getHistoryFilePath();
            this.loadFromFile();
        end

        function out=getHistoryFilePath(~)
            out=fullfile(prefdir,'oslcQueryHist.mat');
        end

        function loadFromFile(this)
            if exist(this.historyFile,'file')
                loaded=load(this.historyFile);
                this.queryHistory=loaded.history;
            else
                this.queryHistory=containers.Map('KeyType','char','ValueType','any');
            end
        end

        function clear(this,rmStored)
            this.queryHistory=containers.Map('KeyType','char','ValueType','any');
            if nargin>1
                if rmStored
                    delete(this.historyFile);
                else
                    this.loadFromFile();
                end
            end
        end

        function reset(this)
            this.loadFromFile();
        end

        function writeToFile(this)
            try
                history=this.queryHistory;
                if exist(this.historyFile,'file')
                    save(this.historyFile,'history','-mat','-append');
                else
                    save(this.historyFile,'history','-mat');
                end
            catch Mex
                warning(message('Slvnv:reqmgt:history:CommitFailed',Mex.message));
            end
        end

        function updateHistory(this,projName,queryString)
            if isKey(this.queryHistory,projName)

                storedHistory=this.queryHistory(projName);
                matchedIdx=find(strcmp(storedHistory,queryString));
                if~isempty(matchedIdx)
                    storedHistory(matchedIdx)=[];
                end
                this.queryHistory(projName)=[{queryString},storedHistory];
            else
                this.queryHistory(projName)={queryString};
            end
        end

        function history=getHistory(this,projName)
            if isKey(this.queryHistory,projName)
                history=this.queryHistory(projName);
            else
                history={};
            end
        end

    end

    methods(Static,Access=private)

        function instance=getInstance()
            persistent singleInstance;
            if isempty(singleInstance)
                singleInstance=slreq.import.QueryHistoryMgr();
            end
            instance=singleInstance;
        end

    end

    methods(Static)



        function update(projName,queryString)
            mgr=slreq.import.QueryHistoryMgr.getInstance();
            mgr.updateHistory(projName,queryString);
            mgr.writeToFile();
        end

        function history=get(projName)
            mgr=slreq.import.QueryHistoryMgr.getInstance();
            history=mgr.getHistory(projName);
        end

    end

    methods(Static,Hidden)




        function filepath=getHistoryFileLocation()
            mgr=slreq.import.QueryHistoryMgr.getInstance();
            filepath=mgr.getHistoryFilePath();
        end

        function storedHistory=getAll()
            mgr=slreq.import.QueryHistoryMgr.getInstance();
            storedHistory=mgr.queryHistory;
        end

        function clearAll(varargin)
            mgr=slreq.import.QueryHistoryMgr.getInstance();
            mgr.clear(varargin{:});
        end

        function resetAll()
            mgr=slreq.import.QueryHistoryMgr.getInstance();
            mgr.reset();
        end
    end

end

