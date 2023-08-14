function e=enumSimulinkTypeAuto(varargin)





    e='rptgen_sl_SlTypeAuto';

    if isempty(findtype(e))
        rptgen.enum(e,{
'model'
'system'
'block'
'signal'
'annotation'
'auto'
        },{
        getString(message('RptgenSL:rptgen_sl:modelLabel'))
        getString(message('RptgenSL:rptgen_sl:systemLabel'))
        getString(message('RptgenSL:rptgen_sl:blockLabel'))
        getString(message('RptgenSL:rptgen_sl:signalLabel'))
        getString(message('RptgenSL:rptgen_sl:annotationLabel'))
        getString(message('RptgenSL:rptgen_sl:automaticLabel'))
        });
    end
