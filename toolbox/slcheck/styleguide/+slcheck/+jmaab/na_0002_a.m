classdef na_0002_a<slcheck.subcheck



    methods
        function obj=na_0002_a()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0002_a';
        end

        function result=run(this)
            result=false;
            ents=this.getEntity();
            obj=get_param(ents,'object');
            system=bdroot(ents);
            mdlAdv=Simulink.ModelAdvisor.getModelAdvisor(system);
            checkObj=mdlAdv.getCheckObj('mathworks.jmaab.na_0002');
            checkInp=checkObj.getInputParameters;
            NumericalIpBlocks=checkInp{5}.Value;

            if~isempty(obj.CompiledPortDataTypes)


                if isInBlockList(ents,NumericalIpBlocks)


                    if~isempty(obj.CompiledPortDataTypes.Inport)&&any(contains(Advisor.Utils.Simulink.outDataTypeStr2baseType(system,obj.CompiledPortDataTypes.Inport),'boolean'))
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