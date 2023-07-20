function flag=checkNFPHDLRecip(this)




    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:NFPHDLRecipCheck_error');


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)
        if strcmpi('NativeFloatingPoint',targetConfig.Library)
            recipBlocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'BlockType','Reciprocal');
            for ii=1:numel(recipBlocks)
                inputIsFloat=hdlcoder.ModelChecker.port_is_type_MAWrapper(recipBlocks{ii},'input',1,@isfloat);
                if inputIsFloat

                    this.addCheck('warning',summary,recipBlocks{ii},0);
                    flag=false;
                end
            end
        end
    end
end
