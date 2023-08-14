

classdef jc_0009_b<slcheck.subcheck
    methods
        function obj=jc_0009_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0009_b';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();
            violations=[];

            if strcmp(get_param(obj,'Type'),'line')
                violations=checkNonPropagatedSignalPropagation(obj);
            end
            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end

function violations=checkNonPropagatedSignalPropagation(obj)
    violations=[];

    connectionBlockTypes={...
    'From',...
    'FunctionCallSplit',...
    'SignalSpecification',...
    };
    lineObj=get_param(obj,'Object');
    hiliteHandle=lineObj.Handle;

    if lineObj.SrcBlockHandle~=-1
        blkType=get_param(lineObj.SrcBlockHandle,'BlockType');


        if any(strcmp(blkType,connectionBlockTypes))
            if~isempty(lineObj.Name)

                if strcmp(lineObj.signalPropagation,'off')
                    vObj=ModelAdvisor.ResultDetail;
                    vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_UnneccSigName_warn');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_UnneccSigName_rec_action');
                    ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                    violations=vObj;
                end

            else

                propSignals=get_param(lineObj.SrcPortHandle,'PropagatedSignals');
                if strcmp(lineObj.signalPropagation,'off')

                    src_obj=get_param(lineObj.SrcBlockHandle,'object');


                    if~isempty(get_param(src_obj.PortHandles.Inport,'Name'))
                        vObj=ModelAdvisor.ResultDetail;
                        vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_NoSigNameBlock_warn');
                        vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_NoSigNameBlock_rec_action');
                        ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                        violations=[violations;vObj];
                    elseif isa(src_obj,'Simulink.From')
                        gotoBlk=src_obj.GotoBlock.handle;
                        goto=get_param(gotoBlk,'Object');
                        line=get_param(goto.PortHandles.Inport,'line');
                        if isempty(line)
                            return;
                        end
                        sigName=get_param(line,'Name');
                        if~isempty(sigName)
                            vObj=ModelAdvisor.ResultDetail;
                            vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_NoSigNameBlock_warn');
                            vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_NoSigNameBlock_rec_action');
                            ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                            violations=[violations;vObj];
                        end
                    end


                elseif isempty(propSignals)
                    vObj=ModelAdvisor.ResultDetail;
                    vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_SigPropagation_ON_warn');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_b_SigPropagation_ON_rec_action');
                    ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                    violations=[violations;vObj];
                end
            end
        end
    end
end