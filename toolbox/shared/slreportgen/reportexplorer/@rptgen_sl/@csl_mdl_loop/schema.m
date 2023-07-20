function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    clsH=schema.class(pkg,'csl_mdl_loop',pkgRG.findclass('rpt_looper'));



    pkg.findclass('rpt_mdl_loop_options');
    p=rptgen.prop(clsH,'LoopList',...
    'rptgen_sl.rpt_mdl_loop_options vector');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.SetFunction=@setLoopList;
    p.GetFunction=@getLoopList;




    rptgen.prop(clsH,'DlgLoopListIdx','mxArray',0,...
    getString(message('RptgenSL:rsl_csl_mdl_loop:modelsToIncludeLabel')),2);









    m=schema.method(clsH,'dlgAdd');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'dlgMoveDown');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgMoveUp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgSelect');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgDelete');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    rptgen.makeStaticMethods(clsH,{
'dlgDeleteStatic'
    },{
'addModel'
'dlgAdd'
'dlgMoveDown'
'dlgSelect'
'dlgDelete'
'dlgMoveUp'
'findOptionsObject'
'loop_getDialogSchema'
'loop_getContextString'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });


    function returnedValue=getLoopList(this,storedValue)

        returnedValue=find(this,...
        '-depth',1,...
        '-isa','rptgen_sl.rpt_mdl_loop_options');

        if isempty(returnedValue)
            if~isempty(storedValue)
                setLoopList(this,storedValue);
                returnedValue=storedValue;

            else

                returnedValue=rptgen_sl.rpt_mdl_loop_options(this,...
                'MdlName','$current');
            end
        end


        function storedValue=setLoopList(this,proposedValue)

            existingValues=find(this,...
            '-depth',1,...
            '-isa','rptgen_sl.rpt_mdl_loop_options');

            for i=1:length(existingValues)
                disconnect(existingValues(i));
            end

            for i=1:length(proposedValue)
                if isa(proposedValue(i),'rptgen_sl.rpt_mdl_loop_options')
                    connect(proposedValue(i),this,'up');
                else
                    error(message('Simulink:rptgen_sl:InvalidLoopList'));
                end
            end

            storedValue=[];

