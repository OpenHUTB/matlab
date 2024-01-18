classdef(Sealed=true)RmiTmData<rmidata.RmiData

    properties

    end
    events
ReqUpdate
    end


    methods(Static=true)

        function singleObj=getInstance(varargin)
            mlock;
            persistent localRMIData;
            persistent localSlreqTmData;
            if isempty(localRMIData)||~isvalid(localRMIData)
                if nargin==0
                    localRMIData=rmitm.RmiTmData();
                    if~isempty(which('slreq.datamodel.RequirementData'))
                        localSlreqTmData=rmitm.SlreqTmData();
                    end
                end
            end
            singleObj=localSlreqTmData;
        end


        function result=isInitialized()
            result=~isempty(rmitm.RmiTmData.getInstance('dontinit'));
        end


        function reset()
            if rmitm.RmiTmData.isInitialized()
                data=rmitm.RmiTmData.getInstance;
                delete(data);
            end
        end
    end


    methods(Access='private')

        function obj=RmiTmData
            obj=obj@rmidata.RmiData();
            obj.statusMap=containers.Map('KeyType','char','ValueType','char');
        end

    end


    methods

        function out=get(this,testSuite,id)

            if~this.hasData(testSuite)
                if isempty(testSuite)
                    out=[];
                    return;
                end
                storageFile=rmimap.StorageMapper.getInstance.getStorageFor(testSuite);
                if exist(storageFile,'file')==2
                    if~this.load(testSuite,storageFile)
                        error(message('Slvnv:rmitm:FailedToLoad',storageFile));
                    end
                else
                    out=[];
                    return;
                end
            end
            out=this.repository.getData(testSuite,id);
        end


        function set(this,testSuite,id,newData)
            this.repository.setData(testSuite,id,newData);
            this.statusMap(testSuite)=num2str(now);
            notify(this,'ReqUpdate',rmitm.RmiTmEvent(testSuite,id));
        end


        function writeToStorage(this,testSuite,storageName)
            this.repository.saveRoot(testSuite,storageName);
            this.statusMap(testSuite)='saved';
        end


        function result=hasData(this,testSuite)

            result=isKey(this.statusMap,testSuite);
        end


        function result=hasChanges(this,testSuite)

            if isKey(this.statusMap,testSuite)
                result=any(this.statusMap(testSuite)=='.');
            else
                result=false;
            end
        end


        function timestamp=getStatus(this,testSuite)

            if isKey(this.statusMap,testSuite)
                timestamp=this.statusMap(testSuite);
            else
                timestamp='none';
            end
        end


        function varargout=load(this,testSuite,reqFile)

            try
                this.repository.addRoot(testSuite,reqFile);
                this.statusMap(testSuite)='loaded';
                varargout{1}=true;
                if nargout>1
                    varargout{2}='';
                end
            catch Mex
                warning(message('Slvnv:rmitm:FailedToLoadFor',testSuite,reqFile,Mex.message));
                varargout{1}=false;
                if nargout>1
                    varargout{2}=Mex.message;
                end
            end
        end


        function discard(this,testSuite)

            if isKey(this.statusMap,testSuite)
                if this.repository.removeRoot(testSuite)

                    remove(this.statusMap,testSuite);
                end
            end
        end


        function newReq=rename(this,oldTestFile,newTestFile)
            if~isKey(this.statusMap,oldTestFile)

                newReq='';
            else
                this.repository.renameRoot(oldTestFile,newTestFile,'linktype_rmi_testmgr');
                this.statusMap(newTestFile)=num2str(now);
                remove(this.statusMap,oldTestFile);
                newReq=this.saveStorage(newTestFile);
            end
        end


        function storagePath=saveStorage(this,testSuite,varargin)
            if isempty(varargin)
                storagePath=rmimap.StorageMapper.getInstance.getStorageFor(testSuite);
            else

                storagePath=varargin{1};
                this.statusMap(testSuite)=num2str(now);
            end

            if any(this.statusMap(testSuite)=='.')
                this.writeToStorage(testSuite,storagePath);
            end
        end


        function loadFromFile(this,testSuite)
            hasLoadedData=this.hasData(testSuite);
            if hasLoadedData
                prevStorage=rmimap.StorageMapper.getInstance.getStorageFor(testSuite);
            else
                prevStorage='';
            end
            if~isempty(prevStorage)&&this.hasChanges(testSuite)

            end
            fileToLoadFrom=rmimap.StorageMapper.getInstance.promptForReqFile(testSuite,true);
            if~isempty(fileToLoadFrom)
                if hasLoadedData
                    this.repository.removeRoot(testSuite);
                end
                [success,msg]=this.load(testSuite,fileToLoadFrom);
                if~success
                    errordlg(msg,...
                    getString(message('Slvnv:rmitm:ErrorLoadingData')),...
                    'modal');

                    if~strcmp(fileToLoadFrom,prevStorage)
                        rmimap.StorageMapper.getInstance.forget(testSuite,false);
                        if~isempty(prevStorage)
                            this.load(testSuite,prevStorage);
                        end
                    end
                end
            end
        end


        function result=hasLinks(this,testSuite)
            if this.hasData(testSuite)
                result=this.repository.rootHasLinks(testSuite);
            else
                result=false;
            end
        end


        function wasSaved=close(this,testSuite)
            wasSaved=false;
            if this.hasChanges(testSuite)
                storageName=rmimap.StorageMapper.getInstance.getStorageFor(testSuite);
                displayName=strrep(storageName,matlabroot,'...');
                reply=questdlg(getString(message('Slvnv:rmitm:YouHaveModified',displayName)),...
                getString(message('Slvnv:rmitm:TraceabilityLinksModified')),...
                getString(message('Slvnv:rmitm:Save')),...
                getString(message('Slvnv:rmitm:Discard')),...
                getString(message('Slvnv:rmitm:Save')));
                if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmitm:Save')))
                    this.writeToStorage(testSuite,storageName);
                    wasSaved=true;
                end
            end
            this.discard(testSuite);
        end

    end

end

