function showStateDescription(this,d,sect,state)





    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:description')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    elem=createElement(d,'para',getStateDescription(this,state));
    appendChild(sect,elem);
end