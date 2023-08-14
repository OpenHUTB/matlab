classdef(Sealed)jc_0797_b<slcheck.subcheck
    methods
        function obj=jc_0797_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0797_b';
        end

        function result=run(this)

            result=false;

            obj=this.getEntity();

            if((isa(obj,'Stateflow.State')&&~strcmp(obj.Type,'AND'))||isa(obj,'Stateflow.Junction'))&&isempty(obj.sinkedTransitions)
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            elseif(isa(obj,'Stateflow.SimulinkBasedState')||isa(obj,'Stateflow.AtomicSubchart'))&&isempty(getSinkedTransitions(obj))
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end

        end
    end
end

function allTxn=getSinkedTransitions(SimStateObj)
    chart=SimStateObj.Chart;
    allTxn=chart.find('-isa','Stateflow.Transition','-and','Destination',SimStateObj);
end