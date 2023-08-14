function flag=checkNFPRelop(this)




    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:NFPRelopCheck_error');


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)
        if strcmpi('NativeFloatingPoint',targetConfig.Library)
            relopBlocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'BlockType','RelationalOperator');
            for ii=1:numel(relopBlocks)
                inputIsFloat=hdlcoder.ModelChecker.port_is_type_MAWrapper(relopBlocks{ii},'input',1,@isfloat);
                outputIsBool=hdlcoder.ModelChecker.port_is_type_MAWrapper(relopBlocks{ii},'output',1,@islogical);
                if inputIsFloat&&~outputIsBool


                    this.addCheck('warning',summary,relopBlocks{ii},0);
                    flag=false;
                end
            end
        end
    end
end
