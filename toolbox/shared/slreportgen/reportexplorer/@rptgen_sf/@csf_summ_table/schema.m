function schema






    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'csf_summ_table',pkgRG.findclass('rptsummtable'));

    p=rptgen.prop(this,'LoopType',rptgen_sf.enumStateflowType,'Chart',getString(message('RptgenSL:rsf_csf_summ_table:objectTypeLabel')));
    p.GetFunction=@getLoopType;


    rptgen.makeStaticMethods(this,{
'summ_getTypeList'
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
    },{
    });


    function returnedValue=getLoopType(this,storedValue)




        summsrc=this.find(...
        '-depth',1,...
        '-isa','rptgen.summsrc',...
        '-nocase',...
        'Type',storedValue);

        if~isempty(summsrc)&&isa(summsrc.LoopComp,'rptgen_sf.csf_state_loop')
            summsrc.LoopComp.setObjectType(storedValue);
        end
        returnedValue=storedValue;

