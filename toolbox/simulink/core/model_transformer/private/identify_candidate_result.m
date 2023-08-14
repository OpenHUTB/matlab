function result=identify_candidate_result(m2m_obj,model,wmsg,freeze)



    [result,num_consts]=identify_constant_result(m2m_obj,model,freeze);

    candidate_blks=m2m_obj.get_variant_candidates(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    setSubTitle(ft,{DAStudio.message('sl_pir_cpp:creator:VariantCandidates')});
    Info=DAStudio.message('sl_pir_cpp:creator:TableInfoCandidate');
    if isempty(candidate_blks)&&num_consts==0
        result={DAStudio.message('sl_pir_cpp:creator:NoCandidate')};
    else
        setInformation(ft,Info);
        ft.setColTitles({'','System Constants',DAStudio.message('sl_pir_cpp:creator:Candidate_Blocks'),DAStudio.message('sl_pir_cpp:creator:Type_of_Transform')});

        for idx=1:length(candidate_blks)
            curr=~m2m_obj.is_excluded_blk(candidate_blks(idx).Handle);
            sid=Simulink.ID.getSID(candidate_blks(idx).Handle);
            operation=insertCheckboxHtml(model,'candidate',curr,idx,sid,freeze);
            if isempty(candidate_blks(idx).Constants)
                constStr=[''];
            else
                constStr=[];
                for cIdx=1:length(candidate_blks(idx).Constants)
                    constStr=[constStr,'''',candidate_blks(idx).Constants{cIdx},''' '];
                end
            end
            ft.addRow({operation,constStr,candidate_blks(idx).Block,candidate_blks(idx).Operation});
        end
        result=[result,{ft}];
    end

    if~isempty(wmsg)&&num_consts>0
        ft0=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubTitle(ft0,DAStudio.message('sl_pir_cpp:creator:WarningMessage'));
        setInformation(ft0,wmsg);
        result=[result,{ft0}];
    end
end
