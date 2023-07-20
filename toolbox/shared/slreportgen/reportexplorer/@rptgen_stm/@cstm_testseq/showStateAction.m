function showStateAction(this,d,sect,state)





    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:action')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    elem=createElement(d,'programlisting',getStateAction(this,state));
    appendChild(sect,elem);
end