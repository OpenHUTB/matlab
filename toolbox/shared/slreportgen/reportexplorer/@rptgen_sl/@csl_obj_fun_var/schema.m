function schema







    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_obj_fun_var',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';








    p=rptgen.prop(h,'isShowParentBlock','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:parentBlockLabel')),lic);
    p.Visible='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction={@getMulti,'FunctionTableParentBlock','VariableTableParentBlock'};
    p.SetFunction={@setMulti,'FunctionTableParentBlock','VariableTableParentBlock'};





    p=rptgen.prop(h,'isShowCallingString','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:callingStringLabel')),lic);
    p.Visible='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction={@getMulti,'FunctionTableCallingString','VariableTableCallingString'};
    p.SetFunction={@setMulti,'FunctionTableCallingString','VariableTableCallingString'};



    p=rptgen.prop(h,'isBorder','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:tableBorderLabel')),lic);
    p.Visible='off';





    rptgen.prop(h,'isFunctionTable','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:includeFunctionTableLabel')),lic);


    rptgen.prop(h,'FunctionTableTitle',rptgen.makeStringType,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:functionListLabel')),...
    '',lic);


    rptgen.prop(h,'FunctionTableTitleType',rptgen.enumAutoManual,'auto',...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:tableTitleLabel')),lic);


    rptgen.prop(h,'FunctionTableParentBlock','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:parentBlockLabel')),lic);


    rptgen.prop(h,'FunctionTableCallingString','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:callingStringLabel')),lic);


    p=rptgen.prop(h,'ShowFixptFunctions','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:includeFixedPointFunctionsLabel')),lic);
    p.Visible='off';





    rptgen.prop(h,'isVariableTable','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:includeVariableTableLabel')),lic);


    rptgen.prop(h,'VariableTableTitleType',rptgen.enumAutoManual,...
    'auto',getString(message('RptgenSL:rsl_csl_obj_fun_var:tableTitleLabel')),lic);


    rptgen.prop(h,'VariableTableTitle',rptgen.makeStringType,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:variableListLabel')),'',lic);


    rptgen.prop(h,'VariableTableParentBlock','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:parentBlockLabel')),lic);


    rptgen.prop(h,'VariableTableCallingString','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:callingStringLabel')),lic);


    rptgen.prop(h,'isWorkspaceIO','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:includeWorkspaceIOParamsLabel')),lic);


    rptgen.prop(h,'isShowVariableSize','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:variableSizeLabel')),lic);


    rptgen.prop(h,'isShowVariableMemory','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:memorySizeLabel')),lic);


    rptgen.prop(h,'isShowVariableClass','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:variableClassLabel')),lic);


    rptgen.prop(h,'isShowVariableValue','bool',true,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:workspaceValueLabel')),lic);


    rptgen.prop(h,'isShowTunableProps','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:rtwStorageClassLabel')),lic);


    rptgen.prop(h,'ParameterProps','MATLAB array',{},...
    getString(message('RptgenSL:rsl_csl_obj_fun_var:dataObjectPropertiesLabel')),lic);



    rptgen.makeStaticMethods(h,{
    },{
'makeFunctionList'
'makeFunctionTable'
'makeVariableList'
'makeVariableTable'
'makeWordList'
    });



    function returnedValue=getMulti(this,storedValue,prop1,prop2)%#ok

        returnedValue=get(this,prop1)||get(this,prop2);



        function valueStored=setMulti(this,proposedValue,prop1,prop2)

            set(this,prop1,proposedValue,prop2,proposedValue);

            valueStored=proposedValue;




