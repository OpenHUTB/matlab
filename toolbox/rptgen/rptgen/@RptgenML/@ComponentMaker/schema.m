function schema





    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    clsH=schema.class(pkg,...
    'ComponentMaker',...
    pkgRG.findclass('DAObject'));

    p=rptgen.prop(clsH,'PkgName','ustring','RptgenCustom',...
    getString(message('rptgen:RptgenML_ComponentMaker:packageDirLabel')));
    p.SetFunction={@setSafeString,p.Name};

    p=rptgen.prop(clsH,'PkgDir','ustring',getenv('HOME'),...
    getString(message('rptgen:RptgenML_ComponentMaker:parentDirLabel')));

    p=rptgen.prop(clsH,'ClassName','ustring','CUserDefined',...
    getString(message('rptgen:RptgenML_ComponentMaker:classDirLabel')));
    p.SetFunction={@setSafeString,p.Name};

    p=rptgen.prop(clsH,'ClassDir','ustring');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';

    p=rptgen.prop(clsH,'DisplayName','ustring',getString(message('rptgen:RptgenML_ComponentMaker:newComponentLabel')),...
    getString(message('rptgen:RptgenML_ComponentMaker:displayNameLabel')));

    p=rptgen.prop(clsH,'Description','ustring','',...
    getString(message('rptgen:RptgenML_ComponentMaker:descriptionLabel')));






    p=rptgen.prop(clsH,'Type','ustring',getString(message('rptgen:RptgenML_ComponentMaker:customComponentsLabel')),...
    getString(message('rptgen:RptgenML_ComponentMaker:catNameLabel')));

    p=rptgen.prop(clsH,'Parentable','bool',false,...
    getString(message('rptgen:RptgenML_ComponentMaker:mayHaveChildrenLabel')));

    p=rptgen.prop(clsH,'v1ExecuteFile','ustring');
    p.Visible='off';

    p=rptgen.prop(clsH,'v1OutlinestringFile','ustring');
    p.Visible='off';

    p=rptgen.prop(clsH,'v1ClassName','ustring');
    p.Visible='off';

    p=rptgen.prop(clsH,'isWriteHeader','bool',false,...
    getString(message('rptgen:RptgenML_ComponentMaker:writeStandardHeaderLabel')));
    p.Visible='off';

    p=rptgen.prop(clsH,'ViewFiles','int32',1);
    p.Visible='off';


    p=rptgen.prop(clsH,'Safe','bool',true,'',2);

    p=rptgen.prop(clsH,'TypeHelpFile','ustring','','',2);

    p=rptgen.prop(clsH,'DlgCurrentPropertyIdx','int32',0,'',2);











    m=schema.method(clsH,'areChildrenOrdered');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(clsH,'canAcceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};












    function proposedValue=setSafeString(this,proposedValue,propName)



        absStr=abs(proposedValue);


        alphaIdx=(...
        (absStr>=abs('a')&...
        absStr<=abs('z'))|...
        (absStr>=abs('A')&...
        absStr<=abs('Z'))...
        );
        alphanumIdx=(...
        (absStr>=abs('0')&...
        absStr<=abs('9'))|...
        alphaIdx|...
        absStr==abs('_')...
        );


        proposedValue(~alphanumIdx)='_';


        proposedValue=proposedValue(min(find(alphaIdx)):max(find(alphanumIdx)));


        this.updateErrorState(propName,proposedValue);





