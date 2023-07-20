



classdef(Sealed=true)RmiDeData<rmidata.RmiData

    properties



    end

    methods(Static=true)


        function singleObj=getInstance(varargin)
            mlock;
            persistent localRMIData;
            if isempty(localRMIData)||~isvalid(localRMIData)
                if nargin==0
                    localRMIData=rmide.RmiDeData();

                    rmide.registerCallback();
                end
            end
            singleObj=localRMIData;
        end


        function result=isInitialized()
            result=~isempty(rmide.RmiDeData.getInstance('dontinit'));
        end



        function reset()
            if rmide.RmiDeData.isInitialized()
                data=rmide.RmiDeData.getInstance;
                delete(data);
            end
        end

    end


    methods(Access='private')


        function obj=RmiDeData
            obj=obj@rmidata.RmiData();
            obj.statusMap=containers.Map('KeyType','char','ValueType','char');
        end

    end

    methods

        function out=get(this,fPath,id)

            if~this.hasData(fPath)



                if isempty(fPath)
                    out=[];
                    return;
                end
                storageFile=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
                if exist(storageFile,'file')==2
                    if~this.load(fPath,storageFile);
                        error(message('Slvnv:rmide:FailedToLoadFrom',storageFile));
                    end
                else
                    out=[];
                    return;
                end
            end
            out=this.repository.getData(fPath,id);
        end


        function set(this,dName,id,newData)

            this.repository.setData(dName,id,newData);
            this.statusMap(dName)=num2str(now);
        end

        function writeToStorage(this,dName,storageName)

            disp(getString(message('Slvnv:rmide:SavingTo',storageName)));
            this.repository.saveRoot(dName,storageName);
            this.statusMap(dName)='saved';
        end

        function result=hasData(this,dName)

            result=isKey(this.statusMap,dName);
        end

        function result=hasChanges(this,dName)

            if isKey(this.statusMap,dName)
                result=any(this.statusMap(dName)=='.');
            else
                result=false;
            end
        end

        function timestamp=getStatus(this,dName)

            if isKey(this.statusMap,dName)
                timestamp=this.statusMap(dName);
            else
                timestamp='none';
            end
        end

        function varargout=load(this,dName,reqFile)

            try
                disp(getString(message('Slvnv:rmide:LoadingFrom',reqFile)));
                this.repository.addRoot(dName,reqFile);
                this.statusMap(dName)='loaded';
                varargout{1}=true;
                if nargout>1
                    varargout{2}='';
                end
            catch Mex
                warning(message('Slvnv:rmide:FailedToLoad',dName,reqFile,Mex.message));
                varargout{1}=false;
                if nargout>1
                    varargout{2}=Mex.message;
                end
            end
        end

        function discard(this,dName)

            if isKey(this.statusMap,dName)
                this.repository.removeRoot(dName);
                remove(this.statusMap,dName);
            end

            ReqMgr.rmidlg_mgr('close',dName);
        end

        function storagePath=saveStorage(this,fPath,varargin)
            if isempty(varargin)

                storagePath=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
            else

                storagePath=varargin{1};
                this.statusMap(fPath)=num2str(now);
            end


            if any(this.statusMap(fPath)=='.')
                this.writeToStorage(fPath,storagePath);
            end
        end

        function loadFromFile(this,fPath)

            hasLoadedData=this.hasData(fPath);
            if hasLoadedData
                prevStorage=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
            else
                prevStorage='';
            end

            if~isempty(prevStorage)&&this.hasChanges(fPath)




            end



            fileToLoadFrom=rmimap.StorageMapper.getInstance.promptForReqFile(fPath,true);
            if~isempty(fileToLoadFrom)
                if hasLoadedData
                    this.repository.removeRoot(fPath);
                end
                [success,msg]=this.load(fPath,fileToLoadFrom);
                if~success
                    errordlg(msg,...
                    getString(message('Slvnv:rmide:ErrorLoadingFromFile')),...
                    'modal');

                    if~strcmp(fileToLoadFrom,prevStorage)
                        rmimap.StorageMapper.getInstance.forget(fPath,false);
                        if~isempty(prevStorage)
                            this.load(fPath,prevStorage);
                        end
                    end
                end
            end
        end

        function result=hasLinks(this,dName)
            if this.hasData(dName)
                result=this.repository.rootHasLinks(dName);
            else
                result=false;
            end
        end

        function close(this,fPath,force)
            if nargin<3
                force=false;
            end
            if~force&&this.hasChanges(fPath)
                if rmide.promptToSave(fPath)
                    storageName=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
                    this.writeToStorage(fPath,storageName);
                end
            end
            this.discard(fPath);
        end

        function dictionaries=closeAll(this)
            dictionaries=keys(this.statusMap);
            for i=1:length(dictionaries)
                if this.hasChanges(dictionaries{i})
                    this.close(dictionaries{i});
                else
                    this.discard(dictionaries{i});
                end
            end
        end

    end

end

