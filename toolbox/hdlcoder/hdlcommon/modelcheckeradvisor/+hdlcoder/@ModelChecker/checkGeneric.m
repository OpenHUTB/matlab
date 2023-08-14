function flag=checkGeneric(this)





    flag=true;

    sys_name=this.m_sys;
    dut=this.m_DUT;
    targetLanguage=hdlget_param(sys_name,'TargetLanguage');

    if strcmpi(targetLanguage,'VHDL')
        maskParamAsGeneric=hdlget_param(sys_name,'MaskParameterAsGeneric');

        if strcmpi(maskParamAsGeneric,'on')

            maskBlks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'SearchDepth','1','RegExp','On','BlockType','SubSystem');
            for ii=1:numel(maskBlks)
                maskStatus=get_param(maskBlks{ii},'Mask');

                if strcmpi(maskStatus,'on')
                    flag=false;
                    message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_generic_error');
                    this.addCheck('warning',message,sys_name,0);
                    break;
                end
            end
        end
    end
end

