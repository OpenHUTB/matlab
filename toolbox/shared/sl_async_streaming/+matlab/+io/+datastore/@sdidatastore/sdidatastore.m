classdef(Sealed=true)sdidatastore<matlab.io.datastore.TabularDatastore&matlab.mixin.Copyable


    properties(Dependent=true,GetAccess='public',SetAccess='immutable')
Name
Signal
    end


    methods


        function obj=sdidatastore(signalID,repo)

            validateattributes(signalID,{'numeric'},{'integer','scalar'},'','signalID',1);
            obj.SignalID=signalID;


            if nargin>1
                if isobject(repo)&&isprop(repo,'sigRepository')
                    repo=repo.sigRepository;
                end
                validateattributes(repo,{'sdi.Repository'},{'scalar'},'','repo',2);
                obj.Repo=repo;
            else
                obj.Repo=sdi.Repository(1);
            end


            if~isValidSignal(obj.Repo,obj.SignalID)
                error(message('SDI:sdi:InvalidSignalID'));
            end


            obj.FileLocation=getSource(obj.Repo);
        end


        function ret=get.Name(this)
            ret=getSignalLabel(this.Repo,this.SignalID);
        end


        function ret=get.Signal(this)
            ret=Simulink.sdi.Signal(this.Repo,this.SignalID);
        end


        tf=hasdata(ds);
        data=preview(ds);
        reset(ds);
    end


    methods(Access='public',Hidden=true)
        frac=progress(ds);
    end


    methods(Access=protected)
        [tt,info]=readData(ds);
        [tt,info]=readAllData(ds);
        [tt,info]=createTimetable(ds,vals,maxPts)
    end


    properties(Access=private)
        SignalID=0
        FileLocation=''
        LastReadChunkIndex=0
    end

    properties(Transient=true,Access=private)
Repo
    end
end