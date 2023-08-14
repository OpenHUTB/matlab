function flag=checkHDLRecip(this)





    flag=true;
    dut=this.m_DUT;
    recipBlk_summary=DAStudio.message('HDLShared:hdlmodelchecker:deprecateHDLRecipSupport');
    mathBlk_summary=DAStudio.message('HDLShared:hdlmodelchecker:divShiftAddArch');
    des_Summary=DAStudio.message('HDLShared:hdlmodelchecker:desc_RecipBlk');

    recipBlocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'BlockType','Reciprocal');
    mathBlocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'BlockType','Math');

    for ii=1:numel(mathBlocks)
        archType=hdlget_param(mathBlocks{ii},'Architecture');
        if strcmpi(archType,'Math')||strcmpi(archType,'Reciprocal')
            flag=false;
            this.addCheck('warning',des_Summary,mathBlocks{ii},0,mathBlk_summary);
        end
    end

    for ii=1:numel(recipBlocks)
        this.addCheck('warning',des_Summary,recipBlocks{ii},0,recipBlk_summary);
        flag=false;
    end
end
