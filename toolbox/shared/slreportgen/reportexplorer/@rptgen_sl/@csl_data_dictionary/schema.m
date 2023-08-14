function schema




    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    lic='SIMULINK_Report_Gen';







    this=schema.class(pkg,'csl_data_dictionary',pkgRG.findclass('rptcomponent'));



    rptgen.prop(this,'IncludeChildDictionaries','bool',true,...
    msg('WdgtLblIncludeChildDictionaries'),lic);

    rptgen.prop(this,'MakeSeparateTableForChild','bool',false,...
    msg('WdgtLblMakeSeparateTableForChild'),lic);

    rptgen.prop(this,'IncludeChildDictionariesList','bool',false,...
    msg('WdgtLblIncludeChildDictionariesList'),lic);

    rptgen.prop(this,'IncludeDesignDataSection','bool',true,...
    msg('WdgtLblIncludeDesignDataSection'),lic);

    rptgen.prop(this,'IncludeConfigurationsSection','bool',false,...
    msg('WdgtLblIncludeConfigurationsSection'),lic);

    rptgen.prop(this,'IncludeOtherDataSection','bool',false,...
    msg('WdgtLblIncludeOtherDataSection'),lic);

    rptgen.prop(this,'ShowDataType','bool',true,...
    msg('WdgtLblShowDataType'),lic);

    rptgen.prop(this,'ShowLastModified','bool',true,...
    msg('WdgtLblShowLastModified'),lic);

    rptgen.prop(this,'ShowLastModifiedBy','bool',true,...
    msg('WdgtLblShowLastModifiedBy'),lic);

    rptgen.prop(this,'ShowStatus','bool',true,...
    msg('WdgtLblShowStatus'),lic);

    rptgen.prop(this,'ShowDataSource','bool',true,...
    msg('WdgtLblShowDataSource'),lic);



    label=msg('WdgtLblTableTitleStyleName');
    rptgen.makeProp(this,'TableTitleStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',label);

    rptgen.prop(this,'TableTitleStyleName','ustring','rgTableTitle');


    p=rptgen.prop(this,'ParsedTableTitleStyleName','ustring','');
    p.GetFunction=@getParsedTableTitleStyleName;
    p.SetFunction=@setParsedTableTitleStyleName;
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.Visible='off';



    label=msg('WdgtLblTableStyleName');
    rptgen.makeProp(this,'TableStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',label);


    rptgen.prop(this,'TableStyleName','ustring','rgUnruledTable');


    p=rptgen.prop(this,'ParsedTableStyleName','ustring','');
    p.GetFunction=@getParsedTableStyleName;
    p.SetFunction=@setParsedTableStyleName;
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.Visible='off';




    rptgen.makeStaticMethods(this,{
    },{
'getDialogSchema'
    });

    function translation=msg(key)
        translation=getString(message(['RptgenSL:csl_data_dictionary:',key]));


        function parsedTableTitleStyleName=getParsedTableTitleStyleName(this,~)
            parsedTableTitleStyleName=rptgen.parseExpressionText(this.TableTitleStyleName);


            function acceptedValue=setParsedTableTitleStyleName(this,newValue)
                this.TableTitleStyleName=newValue;
                acceptedValue=newValue;


                function parsedTableStyleName=getParsedTableStyleName(this,~)
                    parsedTableStyleName=rptgen.parseExpressionText(this.TableStyleName);


                    function acceptedValue=setParsedTableStyleName(this,newValue)
                        this.TableStyleName=newValue;
                        acceptedValue=newValue;