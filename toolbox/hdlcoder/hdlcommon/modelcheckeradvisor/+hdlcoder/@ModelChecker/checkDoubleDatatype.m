function flag=checkDoubleDatatype(this)






    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)
        if strcmpi('NativeFloatingPoint',targetConfig.Library)



            blocks=find_system(dut,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','off','RegExp','On','Type','Block');

            for i=1:numel(blocks)

                pHandles=get_param(blocks{i},'PortHandles');
                names=fieldnames(pHandles);

                for ii=1:numel(names)
                    if~isempty(pHandles.(names{ii}))

                        dType=get_param(pHandles.(names{ii}),'CompiledPortDataType');


                        if iscell(dType)
                            x=1:numel(dType);
                            if strcmpi([dType{x}],'Double')
                                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_double_datatype_unsupported_NFP'),blocks{i},0);
                                flag=false;
                            end
                        else
                            if strcmpi(dType,'Double')
                                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_double_datatype_unsupported_NFP'),blocks{i},0);
                                flag=false;
                            end
                        end
                    end
                end
            end
        end
    end
end
