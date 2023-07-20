


classdef(Sealed=true)RmiSlData<rmidata.RmiData

    properties



    end

    events
RmiSlDataUpdate
    end

    methods(Static=true)

        function singleObj=getInstance(varargin)
            mlock;
            persistent localRMIData;
            if isempty(localRMIData)||~isvalid(localRMIData)
                if nargin==0
                    localRMIData=rmidata.RmiSlData();
                end
            end
            singleObj=localRMIData;
        end

        function reset()


            if rmidata.RmiSlData.isInitialized()
                data=rmidata.RmiSlData.getInstance;
                delete(data);
            end
        end

        function result=isInitialized()
            result=~isempty(rmidata.RmiSlData.getInstance('dontinit'));
        end





        function ids=getNestedIDs(mdlName,parentId)
            ids=rmimap.RMIRepository.getInstance.getChildIds(mdlName,parentId);
        end

        function ids=getSubrootIDs(mdlName,varargin)
            ids=rmimap.RMIRepository.getInstance.getSubrootIds(mdlName,varargin{:});
        end

    end

    methods(Access='private')

        function obj=RmiSlData
            obj=obj@rmidata.RmiData();
            obj.statusMap=containers.Map('KeyType','double','ValueType','logical');
        end
    end

    methods

        clearSubIds(this,sid)
        copyToModel(this,modelH,varargin)
        out=get(this,objH,varargin)
        [reqs,groups]=getSubIds(this,varargin)
        wasSaved=promptToSave(this,modelH)
        storagePath=saveStorage(this,modelH,varargin)
        set(this,objH,newData,varargin)
        setDirty(this,mdlName,state)


        function register(this,slModel)
            if ischar(slModel)
                modelH=get_param(slModel,'Handle');
            else
                modelH=slModel;
            end
            this.statusMap(modelH)=false;
        end

        function unregister(this,slModelH)
            if isKey(this.statusMap,slModelH)
                remove(this.statusMap,slModelH);
            end
        end

        function[perGroupCounts,groups,reqs]=getSubGroups(this,objH)
            [host,id]=rmidata.getRmiKeys(objH,false);
            if isempty(host)
                perGroupCounts=-1;groups=-1;reqs=[];
                return;
            end
            [reqs,groups]=this.getSubIds(host,id);
            if isempty(reqs)
                perGroupCounts=[];
            else
                lastGroup=max(groups);
                perGroupCounts=zeros(1,lastGroup);
                for i=1:lastGroup
                    perGroupCounts(i)=sum(groups==i);
                end
            end
        end

        function setSubGroups(this,sigbH,reqs,grps)

            uniqueGroups=unique(grps);
            for i=1:length(uniqueGroups)
                myGroup=uniqueGroups(i);
                myReqs=reqs(grps==myGroup);
                this.set(sigbH,myReqs,myGroup);
            end
        end

        function writeToStorage(this,modelH,storageName)


            this.repository.saveRoot(modelH,storageName);
            this.statusMap(modelH)=false;
        end

        function result=hasData(this,modelH)
            if isKey(this.statusMap,modelH)
                result=true;
            else
                result=false;
            end
        end

        function result=hasChanges(this,modelH)
            if isKey(this.statusMap,modelH)
                result=this.statusMap(modelH);
            else
                result=false;
            end
        end

        function result=removeItem(this,modelH,sid)
            if ischar(modelH)
                [~,modelName]=fileparts(modelH);
            else
                modelName=get_param(modelH,'Name');
            end
            result=this.repository.removeNode(modelName,sid);
        end

        function varargout=load(this,modelH,reqFile)
            try


                this.repository.addRoot(modelH,reqFile);
                this.statusMap(modelH)=false;
                varargout{1}=true;


                this.notify('RmiSlDataUpdate',rmidata.RmiSlDataEvent(modelH,0));


                if strcmp(get_param(modelH,'ReqHilite'),'on')
                    rmisl.highlight(modelH,true);
                end
                if nargout>1
                    varargout{2}='';
                end
            catch Mex
                warning(message('Slvnv:rmidata:RmiSlData:FailedToLoad',...
                get_param(modelH,'Name'),reqFile,Mex.message));
                varargout{1}=false;
                if nargout>1
                    varargout{2}=Mex.message;
                end
            end
        end

        function discard(this,modelH,force)
            if nargin<3
                force=false;
            end
            if isKey(this.statusMap,modelH)
                try
                    modelName=get_param(modelH,'Name');
                    this.repository.removeRoot(modelName,force);
                catch


                end
                remove(this.statusMap,modelH);
            end
        end

        function[result,hasLinkedBlocks]=modelHasLinks(this,modelH)
            if this.hasData(modelH)
                [result,hasLinkedBlocks]=this.repository.rootHasLinks(modelH);
            else
                result=false;
                hasLinkedBlocks=false;
            end
        end

        function close(this,modelH)
            this.promptToSave(modelH);
            this.discard(modelH);
        end

        function data=getRawData(this,sid)



            [mdlName,id]=strtok(sid,':');
            try
                data=this.repository.getData(mdlName,id);
            catch %#ok<CTCH>
                data=[];
            end
        end

        function setRawData(this,sid,data)
            [mdlName,id]=strtok(sid,':');
            try
                this.repository.setData(mdlName,id,data);

                try
                    modelH=get_param(mdlName,'Handle');
                    this.statusMap(modelH)=true;
                catch
                    warning('Modifying data for %s while system is not loaded',sid);
                end
            catch %#ok<CTCH>
                error('ERROR in RmiSlData: Unable to setRawData for %s',sid);
            end
        end

        function clearRawData(this,sid)
            [mdlName,id]=strtok(sid,':');
            try
                this.repository.setData(mdlName,id,[]);
            catch %#ok<CTCH>
                error('ERROR in RmiSlData: Unable to clearRawData for %s',sid);
            end
        end

        function varargout=diagProp(this,modelH,varargin)
            mdlName=get_param(modelH,'Name');
            varargout{1}=this.repository.rootProp(mdlName,varargin{:});
        end

    end

end

