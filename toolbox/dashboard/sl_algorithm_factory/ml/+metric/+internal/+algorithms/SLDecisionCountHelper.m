classdef SLDecisionCountHelper


    properties
        staticMap;
        dynamicMap;
    end

    methods

        function obj=SLDecisionCountHelper()
            obj.staticMap=containers.Map({'Abs','DeadZone','ForIterator','RateLimiter','Relay','Switch','Saturate','WhileIterator'},...
            {1,2,1,2,2,1,2,1});


            obj.dynamicMap=containers.Map({'DiscreteIntegrator','CombinatorialLogic','EnablePort','TriggerPort','If','MultiPortSwitch','SwitchCase','MinMax'},...
            {@DiscreteIntegrator,@CombinatorialLogic,@EnablePort,@TriggerPort,@If,@MultiPortSwitch,@SwitchCase,@MinMax});
        end

        function res=calculateSLDecisionCount(this,slHandle)
            res=0;
            if isKey(this.staticMap,get_param(slHandle,'BlockType'))
                res=values(this.staticMap,{get_param(slHandle,'BlockType')});
                res=res{1};
            elseif isKey(this.dynamicMap,get_param(slHandle,'BlockType'))
                res=values(this.dynamicMap,{get_param(slHandle,'BlockType')});
                res=res{1}(this,slHandle);
            end
        end
    end

    methods(Access=private)
        function res=DiscreteIntegrator(~,slHandle)
            res=0;
            externalReset=get_param(slHandle,'ExternalReset');
            limitOutput=get_param(slHandle,'LimitOutput');

            if~strcmp(externalReset,'none')
                res=res+1;
            end

            if~strcmp(limitOutput,'off')
                res=res+2;
            end
        end

        function res=CombinatorialLogic(~,slHandle)
            res=1;
            truthTable=get_param(slHandle,'TruthTable');
            truthTable=regexprep(truthTable,'\s','');

            if strcmp(truthTable(1),'[')

                res=length(regexp(truthTable,';'));
            end
        end


        function res=EnablePort(~,slHandle)
            res=0;

            if isa(get_param(get_param(slHandle,'Parent'),'Object'),'Simulink.BlockDiagram')
                res=1;
            else


                parent=get_param(slHandle,'Parent');
                f=Simulink.FindOptions('SearchDepth',1);
                triggerPort=Simulink.findBlocksOfType(parent,'TriggerPort',f);

                if isempty(triggerPort)
                    res=1;
                end
            end

        end


        function res=TriggerPort(~,slHandle)
            res=0;

            if isa(get_param(get_param(slHandle,'Parent'),'Object'),'Simulink.SubSystem')

                parent=get_param(slHandle,'Parent');
                f=Simulink.FindOptions('SearchDepth',1);
                enablePort=Simulink.findBlocksOfType(parent,'EnablePort',f);

                if~isempty(enablePort)
                    res=1;
                end
            end
        end

        function res=If(~,slHandle)

            res=1;

            elseifs=get_param(slHandle,'ElseIfExpressions');
            if isempty(elseifs)
                return;
            end


            res=res+length(regexp(elseifs,','))+1;
        end

        function res=MultiPortSwitch(~,slHandle)
            res=1;
            obj=get_param(slHandle,'Object');
            inportCount=numel(obj.PortHandles.Inport);


            if isequal(inportCount,2)
                return;
            end

            res=inportCount-1;
        end

        function res=SwitchCase(~,slHandle)
            obj=get_param(slHandle,'Object');
            outports=numel(obj.PortHandles.Outport);

            if strcmp(obj.ShowDefaultCase,'on')
                outports=outports-1;
            end
            res=outports;
        end

        function res=MinMax(~,slHandle)
            res=1;
            obj=get_param(slHandle,'Object');

            inputCnt=obj.Inputs;

            if~isnan(str2double(inputCnt))
                res=str2double(inputCnt)-1;
            end
        end
    end
end
