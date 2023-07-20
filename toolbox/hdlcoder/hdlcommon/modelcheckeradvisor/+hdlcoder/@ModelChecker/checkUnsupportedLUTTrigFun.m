function flag=checkUnsupportedLUTTrigFun(this)




    flag=true;
    dut=this.m_DUT;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:UnsupportedLUTTrigFun_error');


    trigFunBlocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'BlockType','Trigonometry');

    for ii=1:numel(trigFunBlocks)
        funType=get_param(trigFunBlocks{ii},'Function');

        if strcmpi('sin',funType)||strcmpi('cos',funType)||...
            strcmpi('sincos',funType)||strcmpi('cos + jsin',funType)||...
            strcmpi('atan2',funType)
            approximationMethod=get_param(trigFunBlocks{ii},'Approximationmethod');

            if strcmpi('Lookup',approximationMethod)



                this.addCheck('warning',summary,trigFunBlocks{ii},0);
                flag=false;
            end
        end
    end
end
