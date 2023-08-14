function e=enumSimulinkType(varargin)






    e='rptgen_sl_SlType';

    if isempty(findtype(e))
        rptgen.enum(e,{
'Model'
'System'
'Block'
'Signal'
'Annotation'
        },{
        getString(message('RptgenSL:rptgen_sl:modelLabel'))
        getString(message('RptgenSL:rptgen_sl:systemLabel'))
        getString(message('RptgenSL:rptgen_sl:blockLabel'))
        getString(message('RptgenSL:rptgen_sl:signalLabel'))
        getString(message('RptgenSL:rptgen_sl:annotationLabel'))
        });
    end
