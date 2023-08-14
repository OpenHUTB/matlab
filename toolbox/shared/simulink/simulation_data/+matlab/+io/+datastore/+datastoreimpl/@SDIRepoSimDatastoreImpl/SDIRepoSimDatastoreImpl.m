


classdef SDIRepoSimDatastoreImpl<matlab.io.datastore.datastoreimpl.SimDatastoreImpl


    methods


        function this=SDIRepoSimDatastoreImpl(signalID,repo)

            validateattributes(signalID,{'numeric'},{'integer','scalar'},'','signalID',1);
            this.SignalID=signalID;


            if nargin>1
                validateattributes(repo,{'Simulink.sdi.internal.Engine'},{'scalar'},'','repo',2);
                this.Repo=repo;
            else
                this.Repo=Simulink.sdi.Instance.engine;
            end


            if~isValidSignalID(this.Repo,this.SignalID)
                error(message('SDI:sdi:InvalidSignalID'));
            end


            this.FileLocation=getSource(this.Repo);



            this.ReadSize=1;
        end

        function nSamples=getNumSamples(this)
            nSamples=getSignalNumChunks(this.Repo.sigRepository,this.SignalID);
        end

        function fn=getFileName(this)
            fn=this.FileLocation;
        end


        tf=hasdata(ds);
        data=preview(ds,num);
        reset(ds);

    end


    methods(Access='public',Hidden=true)
        frac=progress(ds);
    end


    methods(Access=protected)
        [tt,info]=readData(ds);
        [tt,info]=readAllData(ds);
    end


    methods(Access=private)
        [tt,info]=createTimetable(ds,vals,maxPts)
    end


    properties(Access=private)
        SignalID=0
        FileLocation=''
        LastReadChunkIndex=0
        currChunk=[]
        currChunkSize=0
        currChunkIdx=0
    end

    properties(Transient=true,Access=private)
Repo
    end

end


