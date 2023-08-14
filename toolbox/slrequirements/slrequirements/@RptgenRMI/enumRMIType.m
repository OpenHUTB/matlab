function e=enumRMIType(varargin)






    e='RptgenRMI_RMIType';

    if isempty(findtype(e))
        rptgen.enum(e,{
'Stateflow'
'System'
'Block'
        },{
        getString(message('Slvnv:RptgenRMI:getType:xlate_Stateflow'))
        getString(message('Slvnv:RptgenRMI:getType:xlate_System'))
        getString(message('Slvnv:RptgenRMI:getType:xlate_Block'))
        });
    end
