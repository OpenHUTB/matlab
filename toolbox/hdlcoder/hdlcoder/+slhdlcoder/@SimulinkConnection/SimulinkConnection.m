classdef SimulinkConnection<handle



    properties
ModelName
System
SubsystemName
Model
BlockReduction
ConditionallyExecuteInputs
SignalLogging
SignalLoggingName
InportTestPoint
InportDataLogging
InportDataLoggingNameMode
InportDataLoggingName
OutportTestPoint
OutportDataLogging
OutportDataLoggingNameMode
OutportDataLoggingName
initMode


selfCompiled


CalledForGeneratedModel
    end

    methods

        function this=SimulinkConnection(system,mode)
            narginchk(1,2);

            if nargin==2
                this.initMode=mode;
            else
                this.initMode='HDL';
            end

            if~ischar(system)


                error(message('hdlcoder:engine:invalidinputsystem'));
            end

            this.ModelName=bdroot(system);
            this.System=system;
            this.BlockReduction='off';
            this.ConditionallyExecuteInputs='off';
            this.selfCompiled=false;
            this.CalledForGeneratedModel=false;
        end

        function set.BlockReduction(this,value)
            if strcmp(value,'on')||strcmp(value,'off')
                this.BlockReduction=value;
            end
        end

        function set.ConditionallyExecuteInputs(this,value)
            if strcmp(value,'on')||strcmp(value,'off')
                this.ConditionallyExecuteInputs=value;
            end
        end

        function value=get.Model(this)
            value=this.getModel;
        end

        function set.Model(this,h)
            this.Model=[];
            if~isempty(h)&&isa(h,'handle')&&isa(h,'Simulink.BlockDiagram')
                this.Model=h;
            end
        end

        function set.CalledForGeneratedModel(this,h)
            this.CalledForGeneratedModel=h;
        end



        inportHandles=getInportHandles(this);
        inportHandles=getInportSrcHandles(this);
        v=getModel(this,v);
        outportHandles=getOutportHandles(this);
        hSrcBlkPort=getSrcBlkOutportHandle(~,hSubsystem,n);
        getTopPortBlockHandles(this);
        initModel(this);
        initModelForTBGen(this,inportNames,outportNames);
        compiled=isModelCompiled(this);
        restoreModelFromTBGen(this);
        varargout=simulateModel(this);
        termModel(this);
        restoreParams(this);
    end

    methods(Access=private)
        prepareModelForInit(this);
    end
end


