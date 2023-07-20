function flag=checkNFPSuggestion(this)





    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if isempty(targetConfig)||~strcmpi('NativeFloatingPoint',targetConfig.Library)

        blocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'RegExp','On','Type','Block');

        for i=1:numel(blocks)

            pHandles=get_param(blocks{i},'PortHandles');
            names=fieldnames(pHandles);
            for ii=1:numel(names)
                if~isempty(pHandles.(names{ii}))

                    dType=get_param(pHandles.(names{ii}),'CompiledPortDataType');


                    if iscell(dType)
                        x=1:numel(dType);
                        if strcmpi([dType{x}],'single')
                            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_single_datatype_suggest_NFP'),blocks{i},0);
                            flag=false;
                        end
                    else
                        if strcmpi(dType,'single')
                            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_single_datatype_suggest_NFP'),blocks{i},0);
                            flag=false;
                        end
                    end
                end
            end
        end
    end
end
