function flag=checkNFPDTC(this)




    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:NFPDTCCheck_error');


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)
        if strcmpi('NativeFloatingPoint',targetConfig.Library)
            dtcBlocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'BlockType','DataTypeConversion');
            for ii=1:numel(dtcBlocks)
                inputIsFloat=hdlcoder.ModelChecker.port_is_type_MAWrapper(dtcBlocks{ii},'input',1,@isfloat);
                outputIsFloat=hdlcoder.ModelChecker.port_is_type_MAWrapper(dtcBlocks{ii},'output',1,@isfloat);
                convertMode=get_param(dtcBlocks{ii},'ConvertRealWorld');
                if xor(inputIsFloat,outputIsFloat)&&strcmpi(convertMode,'Stored Integer (SI)')

                    this.addCheck('warning',summary,dtcBlocks{ii},1,DAStudio.message('HDLShared:hdlmodelchecker:desc_NFPDTCSICheck'));
                    flag=false;
                end
            end
        end
    end
end
