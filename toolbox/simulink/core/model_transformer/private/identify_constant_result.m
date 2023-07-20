function[m2m_result,num_consts]=identify_constant_result(m2m_obj,model,freeze)



    num_consts=0;
    constants=m2m_obj.get_variant_constants;
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(ft,{DAStudio.message('sl_pir_cpp:creator:SystemConsts')});
    Info=DAStudio.message('sl_pir_cpp:creator:TableInfoSysConst');
    setInformation(ft,Info);
    setTableTitle(ft,{DAStudio.message('sl_pir_cpp:creator:TableTitleSysConst')});
    if isempty(constants)
        m2m_result={DAStudio.message('sl_pir_cpp:creator:NoSysConst')};
    else

        ft.setColTitles({DAStudio.message('sl_pir_cpp:creator:SystemConst')});
        const_list=['{'];
        for ii=1:length(constants)




            const_list=[const_list,'''',constants{ii},''', '];
        end
        ft.addRow({[const_list(1:end-2),'}']});
        num_consts=length(constants);
        m2m_result={ft};
    end









end


