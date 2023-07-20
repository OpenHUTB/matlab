
function targetLanguageChanged(newobj)



    hGbl=newobj.INI.getPropSet('Global');
    hGC=hGbl.getPropSet('Common');
    if strcmpi(hGbl.getProp('target_language'),'VHDL')
        hGC.comment_char='--';
        hGC.base_data_type='std_logic';
        hGC.reg_data_type='std_logic';
        hGC.assign_prefix='';
        hGC.assign_op='<=';
        hGC.array_deref='()';
        hGC.loop_unrolling=true;
        hGC.split_entity_arch=false;
    else
        hGC.comment_char='//';
        hGC.base_data_type='wire';
        hGC.reg_data_type='reg ';
        hGC.assign_prefix='assign ';
        hGC.assign_op='=';
        hGC.array_deref='[]';
        hGC.loop_unrolling=true;
        hGC.split_entity_arch=false;
    end
end
