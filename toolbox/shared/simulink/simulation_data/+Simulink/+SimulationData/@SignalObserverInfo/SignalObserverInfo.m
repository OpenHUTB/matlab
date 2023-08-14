









classdef SignalObserverInfo


    properties(Dependent=true,Access=public)



        BlockPath;


        OutputPortIndex;



        LoggingInfo;


        PropagatedName;

    end


    methods


        function this=SignalObserverInfo(varargin)



            narginchk(0,2);


            if~isempty(varargin)
                try
                    this.BlockPath=varargin{1};
                catch me
                    throwAsCaller(me);
                end
            else
                this.blockPath_=Simulink.BlockPath;
            end


            if length(varargin)>1
                try
                    this.OutputPortIndex=varargin{2};
                catch me
                    throwAsCaller(me);
                end
            else
                this.outputPortIndex_=1;
            end


            this.loggingInfo_=Simulink.SimulationData.LoggingInfo;


            this.propagatedName_='';

        end


        function this=set.BlockPath(this,val)





            if isa(val,'Simulink.SimulationData.BlockPath')&&...
                isscalar(val)





                this.blockPath_=...
                Simulink.BlockPath(val.convertToCell,val.SubPath);
            else


                this.blockPath_=Simulink.BlockPath(val);
            end

        end

        function val=get.BlockPath(this)
            val=this.blockPath_;
        end


        function this=set.OutputPortIndex(this,val)




            if~isnumeric(val)||~isscalar(val)||val<=0||...
                ~isequal(val,int64(val))
                DAStudio.error('Simulink:Logging:SigLogInfoInvalidPortIndex');
            end


            this.outputPortIndex_=double(val);
        end

        function val=get.OutputPortIndex(this)
            val=this.outputPortIndex_;
        end


        function this=set.LoggingInfo(this,val)


            if~isscalar(val)
                DAStudio.error('Simulink:Logging:SigLogInfoInvalidLoggingInfo');
            end
            this.loggingInfo_=Simulink.SimulationData.LoggingInfo(val);
        end

        function val=get.LoggingInfo(this)
            val=this.loggingInfo_;
        end


        function this=set.PropagatedName(this,val)
            assert(ischar(val),'PropagatedName value should be a char.');
            this.propagatedName_=val;
        end

        function val=get.PropagatedName(this)
            val=this.propagatedName_;
        end

    end


    methods(Hidden=true)


        function signalName=getSignalNameFromPort(this,...
            bUseCache,...
            bNeverLoadModel)








            len=this.blockPath_.getLength();
            if len<1||...
                isempty(this.blockPath_.getBlock(len))
                DAStudio.error(...
                'Simulink:Logging:SigLogInfoSigNameEmptyPath');
            end


            if nargin<2
                bUseCache=true;
            end
            if nargin<3
                bNeverLoadModel=false;
            end



            if~isempty(this.blockPath_.SubPath)
                signalName=this.blockPath_.SubPath;
                return;
            end


            if bUseCache&&ischar(this.signalName_)
                signalName=this.signalName_;
                return;
            end



            if~bNeverLoadModel
                closeMdlObj=...
                Simulink.SimulationData.ModelCloseUtil;%#ok<NASGU>
            end




            blk=this.blockPath_.getBlock(len);
            if~bNeverLoadModel
                mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(blk);
                try
                    load_system(mdl);
                catch me
                    id='Simulink:Logging:SigLogInfoSigNameInvalidModel';
                    err=MException(id,DAStudio.message(id,mdl));
                    err=err.addCause(me);
                    throw(err);
                end
            end


            try
                ph=get_param(blk,'PortHandles');
            catch me
                id='Simulink:Logging:SigLogInfoSigNameInvalidBlk';
                err=MException(id,DAStudio.message(id,blk));
                err=err.addCause(me);
                throw(err);
            end


            if length(ph.Outport)<this.outputPortIndex_
                DAStudio.error(...
                'Simulink:Logging:SigLogInfoSigNameInvalidPort',...
                blk,...
                length(ph.Outport),...
                this.outputPortIndex_);
            end


            signalName=...
            get_param(ph.Outport(this.outputPortIndex_),'Name');


            signalName=...
            Simulink.SimulationData.BlockPath.manglePath(signalName);
        end


        function this=updateSettingsFromPort(this,bNeverLoadMdl)




            if nargin<2
                bNeverLoadMdl=false;
            end

            for idx=1:length(this)

                this(idx).loggingInfo_=...
                Simulink.SimulationData.LoggingInfo;


                depth=this(idx).blockPath_.getLength();
                if depth<1
                    DAStudio.warning(...
                    'Simulink:Logging:SigLogInfoUpdateFromPortEmptyPath');
                    continue;
                end


                if~isempty(this(idx).blockPath_.SubPath)
                    this=this.updateSettingsFromChart();
                    continue;
                end


                bpath=this(idx).blockPath_.getBlock(depth);
                try
                    ports=get_param(bpath,'PortHandles');
                catch me %#ok<NASGU>





                    continue;
                end
                ph=ports.Outport(this(idx).outputPortIndex_);


                setting=get_param(ph,'DataLogging');
                if strcmpi(setting,'off')
                    this(idx).loggingInfo_.dataLogging_=false;
                end
                setting=get_param(ph,'DataLoggingDecimateData');
                if strcmpi(setting,'on')
                    this(idx).loggingInfo_.decimateData_=true;
                end
                setting=get_param(ph,'DataLoggingLimitDataPoints');
                if strcmpi(setting,'on')
                    this(idx).loggingInfo_.limitDataPoints_=true;
                end
                setting=get_param(ph,'DataLoggingNameMode');
                if strcmpi(setting,'custom')
                    this(idx).loggingInfo_.nameMode_=true;
                end

                if strcmp(get_param(ph,'ShowPropagatedSignals'),'on')
                    this(idx).propagatedName_=get_param(ph,'PropagatedSignals');
                end



                this(idx).signalName_=...
                this(idx).getSignalNameFromPort(false,bNeverLoadMdl);


                this(idx).loggingInfo_.loggingName_=...
                get_param(ph,'DataLoggingName');


                setting=get_param(ph,'DataLoggingDecimation');
                try
                    val=slResolve(setting,bpath);
                    if~isempty(val)
                        this(idx).loggingInfo_.decimation_=double(val);
                    end
                catch me
                    DAStudio.warning(...
                    'Simulink:Logging:MdlLogInfoCreateFromModelSetValFailure',...
                    'Decimation',...
                    bpath,...
                    me.message);
                end


                ports=get_param(bpath,'PortHandles');
                ph=ports.Outport(this(idx).outputPortIndex_);

                setting=get_param(ph,'DataLoggingMaxPoints');
                try
                    val=slResolve(setting,bpath);
                    if~isempty(val)
                        this(idx).loggingInfo_.maxPoints_=double(val);
                    end
                catch me
                    DAStudio.warning(...
                    'Simulink:Logging:MdlLogInfoCreateFromModelSetValFailure',...
                    'MaxPoints',...
                    bpath,...
                    me.message);
                end

            end
        end


        function this=updateSettingsFromChart(this)


            assert(~isempty(this.blockPath_.SubPath));


            if this.blockPath_.getLength()<2
                mdlBlock={};
                blk=this.blockPath_.getBlock(1);
            else
                mdlBlock=this.blockPath_.convertToCell;
                blk=mdlBlock{end};
                mdlBlock=Simulink.BlockPath(mdlBlock(1:end-1));
            end
            sigs=Simulink.SimulationData.ModelLoggingInfo.getDefaultChartSignals(...
            mdlBlock,...
            blk,...
            true,...
            Simulink.SimulationData.SignalObserverInfo.empty);


            for idx=1:length(sigs)
                if strcmp(sigs(idx).blockPath_.SubPath,...
                    this.blockPath_.SubPath)
                    this.loggingInfo_=sigs(idx).loggingInfo_;
                    return;
                end
            end


            this.loggingInfo_.dataLogging_=false;

        end


        function display(this,bDispPathPortOnly)



            if nargin<2
                bDispPathPortOnly=false;
            end


            if length(this)~=1
                builtin('disp',this);
                return
            end

            if~bDispPathPortOnly

                mc=metaclass(this);
                bHotLinks=feature('hotlinks');
                if bHotLinks
                    fprintf('  <a href="matlab: help %s">%s</a>\n',mc.Name,mc.Name);
                else
                    fprintf('  %s\n',mc.Name);
                end


                fprintf('  Package: %s\n\n',mc.ContainingPackage.Name);
            else
                bHotLinks=false;
            end


            fprintf('  BlockPath:\n');
            this.blockPath_.disp(true);


            if isempty(this.blockPath_.SubPath)
                fprintf('  OutputPortIndex: %d\n\n',this.outputPortIndex_);
            end


            if~bDispPathPortOnly
                fprintf('  LoggingInfo:\n');
                disp(this.loggingInfo_.get_struct);
            end


            if bDispPathPortOnly
                fprintf('\n');
            elseif bHotLinks
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>\n\n',mc.Name);
            else
                fprintf('\n\n');
            end
        end


        function res=matchesSignal(this,bpath,portIdx)



            if portIdx~=this.outputPortIndex_
                res=false;
            else
                res=bpath.pathIsLike(this.blockPath_);
            end

        end


        function res=signalIsDuplicate(sig1,sig2)



            res=false;
            if sig1.outputPortIndex_==sig2.outputPortIndex_
                if sig1.blockPath_.pathIsLike(sig2.blockPath_)||...
                    sig2.blockPath_.pathIsLike(sig1.blockPath_)
                    res=true;
                end
            end
        end


        function transId=getValidateErrorID(~,erId)


            transId=erId;
        end


        function this=validate(this,...
            modelName,...
            modelObjIdx,...
            bValidateHier,...
            bReqLoggedPorts,...
            bAllowTestpoints)





















            if this.blockPath_.getLength()<1||...
                isempty(this.blockPath_.getBlock(1))
                DAStudio.warning(...
                this.getValidateErrorID('Simulink:Logging:SigLogInfoEmptyBlockPath'),...
                modelName,...
                modelObjIdx);
                return;
            end


            try
                this.blockPath_=this.blockPath_.validate();
            catch me
                id=this.getValidateErrorID('Simulink:Logging:SigLogInfoValidateBlkPath');
                err=MException(id,DAStudio.message(id,modelName,modelObjIdx));



                expID=Simulink.SimulationData.errorID(...
                'InvalidBlockPathInvalidBlock');
                if~strcmp(me.identifier,expID)
                    err=err.addCause(me);
                end

                throw(err);
            end



            len=this.blockPath_.getLength();
            bpath=this.blockPath_.getBlock(len);
            ports=[];
            if isempty(this.blockPath_.SubPath)
                ports=get_param(bpath,'PortHandles');
                if this.outputPortIndex_>numel(ports.Outport)
                    DAStudio.error(...
                    this.getValidateErrorID('Simulink:Logging:SigLogInfoValidateBlkPortIdx'),...
                    modelName,...
                    modelObjIdx,...
                    bpath,...
                    numel(ports.Outport),...
                    this.outputPortIndex_);
                end
            elseif this.outputPortIndex_>1
                DAStudio.error(...
                this.getValidateErrorID('Simulink:Logging:SigLogInfoValidateBlkPortIdx'),...
                modelName,...
                modelObjIdx,...
                bpath,...
                1,...
                this.outputPortIndex_);
            end



            if bValidateHier





                pathTopMdl=...
                Simulink.SimulationData.BlockPath.getModelNameForPath(...
                this.blockPath_.getBlock(1));




                if~strcmp(pathTopMdl,modelName)
                    mdls=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.allVariants,...
                    'IncludeCommented','on');
                    refMdl=...
                    Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
                    if sum(strcmp(mdls,refMdl))==0
                        DAStudio.error(...
                        this.getValidateErrorID('Simulink:Logging:SigLogInfoValidateRefModel'),...
                        modelName,...
                        modelObjIdx,...
                        bpath);
                    end
                end
            end


            if this.loggingInfo_.dataLogging_&&bReqLoggedPorts&&...
                isempty(this.blockPath_.SubPath)
                if isempty(ports)
                    ports=get_param(bpath,'PortHandles');
                end
                ph=ports.Outport(this.outputPortIndex_);
                if~strcmpi(get_param(ph,'DataLogging'),'on')
                    if bAllowTestpoints
                        if strcmpi(get_param(ph,'TestPoint'),'on')



                            return;
                        end
                    end
                    DAStudio.error(...
                    this.getValidateErrorID('Simulink:Logging:SigLogInfoValidateLoggingOff'),...
                    modelName,...
                    modelObjIdx,...
                    this.outputPortIndex_,...
                    bpath);
                end
            end
        end


        function this=cacheSSIDs(this,bOpenMdl)




            for idx=1:length(this)
                this(idx).blockPath_=...
                this(idx).blockPath_.cacheSSIDs(bOpenMdl);
            end

        end


        function this=refreshFromSSIDcache(this,bOpenMdl)




            for idx=1:length(this)
                this(idx).blockPath_=...
                this(idx).blockPath_.refreshFromSSIDcache(bOpenMdl);
            end

        end


        function this=updateTopModelName(this,origName,newName)

            this.blockPath_=...
            this.blockPath_.updateTopModelName(origName,newName);
        end

    end


    properties(Hidden=true)
        blockPath_;
        outputPortIndex_;
        loggingInfo_;
        propagatedName_;
        signalName_=0;
    end
end




