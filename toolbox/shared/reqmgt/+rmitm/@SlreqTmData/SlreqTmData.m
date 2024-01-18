classdef SlreqTmData<handle

    properties
reqData
    end


    methods
        function this=SlreqTmData()
            this.reqData=slreq.data.ReqData.getInstance();
        end
    end


    methods
        function out=get(this,testFile,id)
            linkset=this.reqData.getLinkSet(testFile);
            if isempty(linkset)
                linkset=this.loadFromFile(testFile);
            end

            out=[];
            if~isempty(linkset)
                source.artifact=testFile;
                source.id=id;
                source.domain='linktype_rmi_testmgr';
                links=linkset.getLinks(source);
                out=slreq.utils.linkToStruct(links);
            end
        end


        function set(~,testFile,id,newData)
            source.artifact=testFile;
            source.id=id;
            source.domain='linktype_rmi_testmgr';
            slreq.internal.setLinks(source,newData);
        end


        function writeToStorage(this,testSuite,storageName)
            linkset=this.reqData.getLinkSet(testSuite);
            if~isempty(linkset)
                linkset.filepath=storageName;
                linkset.save();
            end
        end


        function result=hasData(this,testSuite)
            linkset=this.reqData.getLinkSet(testSuite);
            result=~isempty(linkset);
        end


        function result=hasChanges(this,testSuite)
            result=false;
            linkset=this.reqData.getLinkSet(testSuite);
            if~isempty(linkset)
                result=linkset.dirty;
            end
        end


        function timestamp=getStatus(this,testSuite)
            timestamp='none';
        end


        function varargout=load(this,testSuite,reqFile)
            linkset=this.reqData.loadLinkSet(testSuite,reqFile);
            if~isempty(linkset)
                varargout{1}=true;
                varargout{2}='';
            end
        end


        function discard(this,testSuite)
            linkset=this.reqData.getLinkSet(testSuite);
            if~isempty(linkset)
                linkset.discard();
            end
        end


        function newReq=rename(this,oldTestFile,newTestFile)
            newReq='';
        end


        function storagePath=saveStorage(this,testSuite,varargin)
            if isempty(varargin)
                storagePath=rmimap.StorageMapper.getInstance.getStorageFor(testSuite);
            else
                storagePath=varargin{1};
            end
            this.writeToStorage(testSuite,storagePath);
        end


        function linkset=loadFromFile(this,testFile)
            linkset=[];
            linkFile=rmimap.StorageMapper.getInstance.getStorageFor(testFile);
            if exist(linkFile,'file')==2
                linkset=this.reqData.loadLinkSet(testFile,linkFile);
            end
        end


        function result=hasLinks(this,testSuite)
            linkset=this.reqData.getLinkSet(testSuite);
            result=~isempty(linkset.getLinkedItems());
        end


        function wasSaved=close(this,testSuite)
            wasSaved=false;
        end

    end

end

