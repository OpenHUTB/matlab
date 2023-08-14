classdef na_0002_b<slcheck.subcheck



    methods
        function obj=na_0002_b()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0002_b';
        end

        function result=run(this)
            result=false;
            ents=this.getEntity();
            obj=get_param(ents,'object');
            system=bdroot(ents);
            mdlAdv=Simulink.ModelAdvisor.getModelAdvisor(system);
            checkObj=mdlAdv.getCheckObj('mathworks.jmaab.na_0002');
            checkInp=checkObj.getInputParameters;
            LogicalIpBlocks=checkInp{6}.Value;

            if~isempty(obj.CompiledPortDataTypes)


                if isInBlockList(ents,LogicalIpBlocks)


                    if~isValidTriggerEnablePort(obj,system)&&~(Stateflow.SLUtils.isChildOfStateflowBlock(obj.getParent.Handle))
                        vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',get_param(ents,'Parent'));
                        result=this.setResult(vObj);
                    elseif~isempty(obj.CompiledPortDataTypes.Inport)&&any(~contains(Advisor.Utils.Simulink.outDataTypeStr2baseType(system,obj.CompiledPortDataTypes.Inport),'boolean'))
                        vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',ents);
                        result=this.setResult(vObj);
                    end
                end
            end
        end
    end
end

function bResult=isInBlockList(Object,BlockList)
    bResult=false;
    [numRows,~]=size(BlockList);
    for i=1:numRows
        if~strcmp(get_param(Object,'Type'),'block_diagram')&&isequal({get_param(Object,'BlockType'),get_param(Object,'MaskType')},BlockList(i,:))
            bResult=true;
            return;
        end
    end
end

function bResult=isValidTriggerEnablePort(portObj,system)

    bResult=true;
    if isa(portObj.getParent,'Simulink.BlockDiagram')
        return;
    end

    if isempty(portObj.getParent.CompiledPortDataTypes)
        return;
    end

    if(isa(portObj,'Simulink.EnablePort')&&~isempty(portObj.getParent.CompiledPortDataTypes.Enable)&&~contains(Advisor.Utils.Simulink.outDataTypeStr2baseType(system,portObj.getParent.CompiledPortDataTypes.Enable),'boolean'))||...
        (isa(portObj,'Simulink.TriggerPort')&&~isempty(portObj.getParent.CompiledPortDataTypes.Trigger)&&~contains(Advisor.Utils.Simulink.outDataTypeStr2baseType(system,portObj.getParent.CompiledPortDataTypes.Trigger),{'boolean','fcn_call'}))
        bResult=false;
    end
end
