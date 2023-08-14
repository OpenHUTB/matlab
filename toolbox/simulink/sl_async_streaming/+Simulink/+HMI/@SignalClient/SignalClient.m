




classdef SignalClient<Simulink.AsyncQueue.SignalClient


    properties(Dependent=true,Access=public)

        SignalInfo;



        ReferenceModel;
    end


    methods


        function obj=SignalClient(varargin)
            narginchk(0,1);
            obj=obj@Simulink.AsyncQueue.SignalClient(varargin{:});
            if nargin>0
                opts=varargin{1};
                obj.SourceModel_=opts.SourceModel_;
                obj.SignalUUID_=opts.SignalUUID_;
                if~isempty(opts.ModelPath_)
                    obj.ModelPath_=opts.ModelPath_;
                    obj.ModelPathSID_=opts.ModelPathSID_;
                end
            end
        end


        function this=set.ReferenceModel(this,val)
            if ischar(val)||iscellstr(val)
                val=Simulink.BlockPath(val);
            end
            validateattributes(val,{'Simulink.BlockPath'},{'scalar'});
            import Simulink.HMI.BlockPathUtils;
            [this.ModelPath_,this.ModelPathSID_]=...
            BlockPathUtils.getPathMetaData(val);
        end

        function val=get.ReferenceModel(this)
            import Simulink.HMI.BlockPathUtils;
            val=BlockPathUtils.createPathFromMetaData(...
            this.ModelPath_,this.ModelPathSID_,'');
        end


        function this=set.SignalInfo(this,val)
            if isempty(val)
                this.SourceModel_='';
                this.SignalUUID_='';
                return;
            end
            validateattributes(val,{'Simulink.HMI.SignalSpecification'},{'scalar'});
            import Simulink.SimulationData.BlockPath;
            this.SourceModel_=BlockPath.getModelNameForPath(val.BlockPath_);
            this.SignalUUID_=val.UUID;
        end

        function val=get.SignalInfo(this)
            val=Simulink.HMI.SignalSpecification.empty;
            if isempty(this.SourceModel_)||isempty(this.SignalUUID_)
                return;
            end

            try
                sigs=get_param(this.SourceModel_,'InstrumentedSignals');
            catch me %#ok<NASGU>
                return;
            end

            if isempty(sigs)
                return;
            end

            len=sigs.Count;
            for idx=1:len
                obj=sigs.get(idx);
                if strcmp(obj.UUID,this.SignalUUID_)
                    val=obj;
                    return;
                end
            end
        end


        function label=getLabel(this)

            sig=this.SignalInfo;
            if isempty(sig)
                label='';
            else
                label=sig.getSignalNameFromModel();
                if isempty(label)
                    label=sprintf('%s:%d',...
                    get_param(sig.getAlignedBlockPath(),'Name'),...
                    sig.OutputPortIndex_);
                end
            end
        end


        function mdl=getTopModel(this)

            if isempty(this.ModelPath_)
                mdl=this.SourceModel_;
            else
                import Simulink.SimulationData.BlockPath;
                blk=this.ModelPath_{1};
                mdl=BlockPath.getModelNameForPath(blk);
            end
        end


        function bp=getFullSignalPath(this)

            sig=this.SignalInfo;
            if isempty(sig)
                bp=Simulink.BlockPath({});
            elseif isempty(this.ModelPath_)
                bp=sig.BlockPath;
            else
                bpath=[this.ModelPath_;{sig.BlockPath_}]';
                sid=[this.ModelPathSID_;{sig.SID_}]';
                import Simulink.HMI.BlockPathUtils;
                bp=BlockPathUtils.createPathFromMetaData(...
                bpath,sid,sig.SubPath_);
            end
        end
    end


    properties(Hidden=true)
        ModelPath_={};
        ModelPathSID_={};
        SourceModel_='';
        SignalUUID_='';
    end

end