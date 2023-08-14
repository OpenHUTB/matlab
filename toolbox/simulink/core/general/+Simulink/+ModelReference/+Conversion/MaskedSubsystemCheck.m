classdef MaskedSubsystemCheck<handle
    properties(Transient,SetAccess=private,GetAccess=private)
Systems
ConversionData
Graph
Logger
Force

        InvalidPairs={}
        InvalidSubsystems=[]
    end

    methods(Static,Access=public)
        function checkRCB(params)
            this=Simulink.ModelReference.Conversion.MaskedSubsystemCheck(params);
            arrayfun(@(ss)this.exec(ss),this.Systems);
            if~isempty(this.InvalidPairs)


                params.MustCopySubsystem=true;
            end
        end

        function check(params)
            this=Simulink.ModelReference.Conversion.MaskedSubsystemCheck(params);
            arrayfun(@(ss)this.exec(ss),this.Systems);
            if~isempty(this.InvalidPairs)
                this.createExceptions;
            end
        end
    end


    methods(Access=private)
        function this=MaskedSubsystemCheck(params)
            this.ConversionData=params;
            this.Graph=params.Graph;
            this.Logger=params.Logger;
            inputParams=params.ConversionParameters;
            this.Systems=inputParams.Systems;
            this.Force=inputParams.Force;
        end


        function exec(this,subsys)
            vid=this.Graph.VertexMap(subsys);




            g=this.Graph.Graph;
            while(true)

                if(vid==0)||isempty(vid)
                    return;
                end
                vertex=g.vertex(vid);

                if vertex.Data.HasMask
                    blkH=vertex.Data.ID;
                    hasDlgParams=~isempty(get_param(blkH,'MaskNames'));
                    hasMaskInit=~isempty(deblank(get_param(blkH,'MaskInitialization')));
                    if(hasMaskInit)
                        this.InvalidPairs{end+1}=[subsys,blkH,hasDlgParams,hasMaskInit];
                        this.InvalidSubsystems(end+1)=subsys;
                    end
                end


                edges=vertex.edges;
                idx=find(arrayfun(@(e)e.TargetID==vid,edges));
                if isempty(idx)
                    return;
                else
                    vid=edges(idx).SourceID;
                end
            end
        end
    end


    methods(Access=private)
        function createExceptions(this)
            msgs={};
            N=numel(this.InvalidPairs);
            for idx=1:N
                aPair=this.InvalidPairs{idx};
                nameString=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(aPair(1)),aPair(1));
                if(aPair(1)==aPair(2))
                    if this.ConversionData.ConversionParameters.CopySubsystemMaskToNewModel
                        if aPair(4)
                            msgs{end+1}=message('Simulink:modelReferenceAdvisor:InvalidMaskedSubsystem',nameString);%#ok
                        end
                    else
                        msgs{end+1}=message('Simulink:modelReferenceAdvisor:InvalidMaskedSubsystem',nameString);%#ok
                    end
                else
                    msgs{end+1}=message('Simulink:modelReferenceAdvisor:InvalidSubsystemUnderMask',nameString,...
                    Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(aPair(2)),aPair(2)));%#ok
                end
            end


            if~isempty(msgs)
                if this.Force
                    cellfun(@(msg)this.Logger.addWarning(msg),msgs);
                else
                    subsysNames=arrayfun(@(subsys)this.ConversionData.beautifySubsystemName(subsys),...
                    unique(this.InvalidSubsystems),'UniformOutput',false);
                    nameString=Simulink.ModelReference.Conversion.Utilities.cellstr2str(subsysNames,'','');
                    me=MException(message('Simulink:modelReferenceAdvisor:CannotConvertSubsystem',nameString));
                    N=numel(msgs);
                    for idx=1:N
                        me=me.addCause(MException(msgs{idx}));
                    end
                    throw(me);
                end
            end
        end
    end
end
