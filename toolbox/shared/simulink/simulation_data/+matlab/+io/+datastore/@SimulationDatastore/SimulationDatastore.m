




classdef(AllowedSubclasses=?DatastoreLoadTester)...
    SimulationDatastore<matlab.io.datastore.TabularDatastore&...
    matlab.mixin.Copyable




























    properties(Dependent,Access=public)
        ReadSize=100;
    end

    properties(Dependent,SetAccess=private)
        NumSamples;
        FileName;
    end

    properties(Constant,Access=protected,Transient)

        CurrentVersion_=2;
    end

    properties(SetAccess=protected,Hidden)
        Version=matlab.io.datastore.SimulationDatastore.CurrentVersion_
    end

    properties(Hidden)
SimDatastoreImpl
ImplType
    end

    methods
        function this=SimulationDatastore(varargin)


















            if nargin>0
                if isequal(nargin,3)
                    this.SimDatastoreImpl=...
                    matlab.io.datastore.datastoreimpl.MATFileSimDatastoreImpl(...
                    varargin{:});
                    this.ImplType='MATFile';
                elseif isequal(nargin,1)
                    this.ImplType=varargin{1};
                end
            else
                Simulink.SimulationData.utError('SimulationDatastoreNoDefaultConstructor');
            end
        end

        function set.ReadSize(this,RS)
            validateattributes(RS,{'numeric'},{'integer','positive','scalar'});


            this.SimDatastoreImpl.ReadSize=RS;
        end

        function rs=get.ReadSize(this)
            rs=this.SimDatastoreImpl.ReadSize;
        end

        function fn=get.FileName(this)
            fn=this.SimDatastoreImpl.getFileName();
        end

        function nSamples=get.NumSamples(this)
            nSamples=this.SimDatastoreImpl.getNumSamples();
        end

        function disp(this)
            try

                Simulink.SimulationData.utNonScalarDisp(this);
                if length(this)~=1
                    return;
                end
                this.resolve();
                this.SimDatastoreImpl.disp();
            catch me
                fprintf('  %s\n',me.message);
            end
        end

        function data=preview(this,varargin)

            this.verifyDatastoreIsScalar;
            if isempty(varargin)
                data=this.SimDatastoreImpl.preview();
            else
                data=this.SimDatastoreImpl.preview(varargin);
            end
        end

        function reset(this)

            this.verifyDatastoreIsScalar;
            this.SimDatastoreImpl.reset();
        end

        function tf=hasdata(this)


            this.verifyDatastoreIsScalar;
            tf=this.SimDatastoreImpl.hasdata();
        end

        function p=progress(this)



            this.verifyDatastoreIsScalar;
            p=this.SimDatastoreImpl.progress();
        end
    end

    methods(Access=protected)
        function[data,info]=readData(this)
            this.verifyDatastoreIsScalar;
            try
                [data,info]=this.SimDatastoreImpl.readData();
            catch me
                throwAsCaller(me);
            end
        end

        function data=readAllData(this)
            this.verifyDatastoreIsScalar;
            try
                data=this.SimDatastoreImpl.readAllData();
            catch me
                throwAsCaller(me);
            end
        end
    end

    methods(Access=private)
        function verifyDatastoreIsScalar(this)
            if~isscalar(this)
                Simulink.SimulationData.utError('NonScalarSimulationDatastore');
            end
        end

        function resolve(this)
            this.SimDatastoreImpl.resolve();
        end
    end

    methods(Hidden=true)
        function fullatt=getFullAttributes(this)
            fullatt=this.SimDatastoreImpl.getFullAttributes();
        end

        function props=getSimImplProps(this)
            props=this.SimDatastoreImpl.getSimImplProps();
        end

        function strct=saveobj(this)
            strct.ImplType=this.ImplType;
            strct.FileName=this.FileName;
            strct.ReadSize=this.ReadSize;
            strct.Version=this.Version;


            if isequal(this.ImplType,'MATFile')
                strct.FullAttributes=this.SimDatastoreImpl.getFullAttributes();
                strct.StorageVersion=this.getSimImplProps().StorageVersion_;
            end
        end
    end

    methods(Static=true,Hidden=true)
        function obj=loadobj(var)
            if var.Version>matlab.io.datastore.SimulationDatastore.CurrentVersion_
                Simulink.SimulationData.utError('LoadingNewerVersionNotAllowed',...
                'Simulink.SimulationData.Datastore');
            end

            if var.Version<2
                obj=matlab.io.datastore.SimulationDatastore(...
                var.FileName_,...
                var.FullAttributes,...
                var.StorageVersion_);
                obj.ReadSize=var.ReadSize;
            else
                if isequal(var.ImplType,'MATFile')
                    obj=matlab.io.datastore.SimulationDatastore(...
                    var.FileName,...
                    var.FullAttributes,...
                    var.StorageVersion);
                    obj.ReadSize=var.ReadSize;
                else
                    assert(isequal(var.ImplType,'SDIRepo'));

                end
            end

            try
                obj.resolve();
            catch




            end
        end
    end

    methods(Static,Hidden=true)
        function dst=createForMATFile(...
            fileName,...
            fullAttributes,...
            storage_version)
            dst=matlab.io.datastore.SimulationDatastore(...
            fileName,...
            fullAttributes,...
            storage_version);
            dst.resolve();
        end

        function dst=createForSDIRepo(varargin)
            dst=matlab.io.datastore.SimulationDatastore(...
            'SDIRepo');
            dst.SimDatastoreImpl=...
            matlab.io.datastore.datastoreimpl.SDIRepoSimDatastoreImpl(...
            varargin{:});
        end
    end

end



