function showStateWhenCondition(this,d,sect,state)






    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:whenCondition')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    elem=...
    createElement(d,'programlisting',getStateWhenCondition(this,state));
    appendChild(sect,elem);
end