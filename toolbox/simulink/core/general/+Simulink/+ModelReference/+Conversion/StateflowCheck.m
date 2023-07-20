classdef StateflowCheck<handle




    properties(Transient,SetAccess=private,GetAccess=private)
Model
Systems
        Force=false;
Logger
ConversionData
ConversionParameters
        InvalidSubsystems=[]
    end


    methods(Static,Access=public)
        function check(params)
            this=Simulink.ModelReference.Conversion.StateflowCheck(params);
            this.exec;
            if~isempty(this.InvalidSubsystems)
                this.createExceptions;
            end
        end
        function checkRCB(params)
            this=Simulink.ModelReference.Conversion.StateflowCheck(params);
            this.execRCB;
            if~isempty(this.InvalidSubsystems)
                this.createExceptions;
            end
        end
    end


    methods(Access=private)
        function this=StateflowCheck(params)
            this.ConversionParameters=params.ConversionParameters;
            this.Model=this.ConversionParameters.Model;
            this.Systems=this.ConversionParameters.Systems;
            this.Force=this.ConversionParameters.Force;
            this.Logger=params.Logger;
            this.ConversionData=params;
        end


        function exec(this)





            modelName=get_param(this.Model,'Name');
            if this.modelHasExportedFunctions(modelName)




                mask=arrayfun(@(ss)~isempty(find_system(ss,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','on','MaskType','Stateflow')),this.Systems);
                this.InvalidSubsystems=vertcat(this.InvalidSubsystems,this.Systems(mask));
            elseif this.machineHasDataOrEvents(modelName)




                mask=arrayfun(@(ss)~isempty(find_system(ss,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','MaskType','Stateflow','ReferenceBlock','')),this.Systems);
                this.InvalidSubsystems=vertcat(this.InvalidSubsystems,this.Systems(mask));
            end
        end

        function execRCB(this)





            modelName=get_param(this.Model,'Name');
            if~this.modelHasExportedFunctions(modelName)&&this.machineHasDataOrEvents(modelName)




                mask=arrayfun(@(ss)~isempty(find_system(ss,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','MaskType','Stateflow','ReferenceBlock','')),this.Systems);
                if slfeature('RightClickBuild')
                    if this.ConversionParameters.SS2mdlForPLC
                        this.InvalidSubsystems=vertcat(this.InvalidSubsystems,this.Systems(mask));
                    end
                else
                    this.InvalidSubsystems=vertcat(this.InvalidSubsystems,this.Systems(mask));
                end
            end
        end


        function hasFuncs=modelHasExportedFunctions(this,modelName)
            hasFuncs=0;

            sf('Private','machine_bind_sflinks',modelName);
            machines=sf('Private','get_link_machine_list',modelName,'sfun');

            if this.hasExportedFunctions(modelName)
                hasFuncs=1;
                return;
            end

            numberOfMachines=length(machines);
            for i=1:numberOfMachines
                if this.hasExportedFunctions(machines{i})
                    hasFuncs=1;
                    return;
                end
            end
        end


        function createExceptions(this)
            subsys=unique(this.InvalidSubsystems);
            results=arrayfun(@(ss)message('Simulink:modelReferenceAdvisor:InvalidSubsystemStateflow',...
            this.ConversionData.beautifySubsystemName(ss)),subsys,'UniformOutput',false);
            if this.Force
                cellfun(@(msg)warning(msg),results);
            else
                subsysNames=arrayfun(@(ss)this.ConversionData.beautifySubsystemName(ss),subsys,'UniformOutput',false);
                nameString=Simulink.ModelReference.Conversion.Utilities.cellstr2str(subsysNames,'','');
                me=MException(message('Simulink:modelReferenceAdvisor:CannotConvertSubsystem',nameString));
                N=numel(subsys);
                for idx=1:N
                    me=me.addCause(MException(results{idx}));
                end
                throw(me);
            end
        end
    end


    methods(Static,Access=private)
        function hasDataOrEvents=machineHasDataOrEvents(modelName)
            modelH=get_param(modelName,'uddobject');
            dataH=modelH.find('-depth',1,'-isa','Stateflow.Data');
            eventH=modelH.find('-depth',1,'-isa','Stateflow.Event');
            hasDataOrEvents=~isempty(dataH)|~isempty(eventH);
        end


        function hasFuncs=hasExportedFunctions(modelName)
            hasFuncs=0;
            modelH=get_param(modelName,'uddobject');
            charts=modelH.find('-isa','Stateflow.Chart');
            if(~isempty(charts))
                charts=find(charts,'ExportChartFunctions',1);
            end

            numberOfCharts=length(charts);
            for i=1:numberOfCharts
                chart=charts(i);
                functions=chart.find('-depth',1,'-isa','Stateflow.Function');
                if~isempty(functions)
                    hasFuncs=1;
                    return;
                end
            end
        end
    end
end
