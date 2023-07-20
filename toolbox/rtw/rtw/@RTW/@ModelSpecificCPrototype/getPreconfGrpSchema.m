function grp=getPreconfGrpSchema(hSrc)



    listFcnClass=[];
    listFcnClass.Name=DAStudio.message('RTW:fcnClass:functionClass');
    listFcnClass.Type='combobox';
    listFcnClass.Entries={DAStudio.message('RTW:fcnClass:fcnprotoctlAuto'),...
    DAStudio.message('RTW:fcnClass:modelSpecific')};

    theClass=0;
    if~isempty(hSrc)
        if isa(hSrc,'RTW.FcnDefault')
            theClass=0;
        elseif isa(hSrc,'RTW.ModelSpecificCPrototype')
            theClass=1;
        end
        listFcnClass.Visible=1;
    end

    listFcnClass.Value=theClass;
    listFcnClass.MultiSelect=0;
    listFcnClass.Mode=1;
    listFcnClass.DialogRefresh=1;
    listFcnClass.Tag='listbox';
    listFcnClass.ObjectMethod='FunctionClassChanged';
    listFcnClass.MethodArgs={'%value','%dialog'};
    listFcnClass.ArgDataTypes={'double','handle'};
    listFcnClass.RowSpan=[1,1];
    listFcnClass.ColSpan=[1,2];
    listFcnClass.ToolTip=DAStudio.message('RTW:fcnClass:funcSpecTip');

    tFuncDescription.Type='text';
    tFuncDescription.WordWrap=true;
    tFuncDescription.Name=hSrc.description;
    tFuncDescription.RowSpan=[2,2];
    tFuncDescription.ColSpan=[1,4];

    bPreConfig.Name=DAStudio.message('RTW:fcnClass:preConfig');
    bPreConfig.Tag='Tag_fcnproto_preconfig';
    bPreConfig.Visible=~isa(hSrc,'RTW.FcnDefault');
    bPreConfig.Enabled=bPreConfig.Visible;
    bPreConfig.Type='pushbutton';
    bPreConfig.ToolTip=DAStudio.message('RTW:fcnClass:preConfigTip');
    bPreConfig.MinimumSize=[20,15];
    bPreConfig.ObjectMethod='preConfig';
    bPreConfig.MethodArgs={'%dialog'};
    bPreConfig.ArgDataTypes={'handle'};
    bPreConfig.RowSpan=[3,3];
    bPreConfig.ColSpan=[1,1];
    bPreConfig.Mode=true;
    bPreConfig.DialogRefresh=true;

    txtInvokesUpdateDiagram2.Type='text';
    txtInvokesUpdateDiagram2.Visible=bPreConfig.Visible;
    txtInvokesUpdateDiagram2.Name=DAStudio.message('RTW:fcnClass:invokesUpdateDiagram');
    txtInvokesUpdateDiagram2.WordWrap=false;
    txtInvokesUpdateDiagram2.RowSpan=[3,3];
    txtInvokesUpdateDiagram2.ColSpan=[2,2];

    grp.Name=DAStudio.message('RTW:fcnClass:setFunctionClassAndName');
    grp.Type='group';
    grp.Items={listFcnClass,tFuncDescription,bPreConfig,txtInvokesUpdateDiagram2};
    grp.LayoutGrid=[3,4];
    grp.RowStretch=[0,0,0];
