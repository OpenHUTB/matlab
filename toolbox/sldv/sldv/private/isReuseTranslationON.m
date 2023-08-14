


function status=isReuseTranslationON(sldv_option)%#ok<INUSD> 
    status=slavteng('feature','ReuseTranslation');



    status=status&&~sldvshareprivate('util_is_analyzing_for_fixpt_tool');

    status=status&~ModelAdvisor.isRunning;




















    status=status&&slfeature('SLDVCheckOverflowFlag');
end
