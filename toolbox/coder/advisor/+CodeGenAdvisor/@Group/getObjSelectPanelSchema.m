function objSelect=getObjSelectPanelSchema(this,grouprow)



    objSelect.Type='panel';
    objSelect.Name='objselect';
    objSelect.RowSpan=[grouprow,grouprow];
    objSelect.ColSpan=[1,10];
    objSelect.LayoutGrid=[1,2];
    objSelect.ColStretch=[0,1];

    ertTarget=false;
    cs=this.getConfigSet;
    try
        ertTarget=strcmpi(get_param(cs,'IsERTTarget'),'on');
    catch
    end


    if ertTarget~=this.isERT
        this.isERT=ertTarget;
        this.Objectives=cs.get_param('ObjectivePriorities');
        this.refreshCheckList;
    end


    if~ertTarget
        grtObjCombo_entries={DAStudio.message('RTW:configSet:sanityCheckUnspecified'),...
        DAStudio.message('RTW:configSet:sanityCheckDebugging'),...
        DAStudio.message('RTW:configSet:sanityCheckEfficiencyspeed')};
        grtObjCombo.Type='combobox';
        grtObjCombo.Entries=grtObjCombo_entries;
        grtObjCombo.Values=[0,1,2];
        if strcmpi(this.Objectives,'Debugging')
            grtObjCombo.Value=1;
        elseif strcmpi(this.Objectives,'Execution efficiency')
            grtObjCombo.Value=2;
        elseif isempty(this.Objectives)
            grtObjCombo.Value=0;
        else
            disp('Should not be here');
        end

        grtObjCombo.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesDescrName2');
        grtObjCombo.Tag='tag_grtObjCombo';
        grtObjCombo.Source=this;
        grtObjCombo.ObjectMethod='grtObjChange';
        grtObjCombo.MethodArgs={'%dialog'};
        grtObjCombo.ArgDataTypes={'handle'};
        grtObjCombo.DialogRefresh=true;
        grtObjCombo.Mode=1;
        grtObjCombo.RowSpan=[1,1];
        grtObjCombo.ColSpan=[1,1];
        objGroup=grtObjCombo;


        if~isempty(this.ERTObj)
            this.ERTObj=[];
        end
    else
        if isempty(this.ERTObj)
            hErtObj=Simulink.ConfigSetObjectives;
            hErtObj.opCopy=this.Objectives;
            hErtObj.base=this;
            this.ERTObj=hErtObj;
        else
            hErtObj=this.ERTObj;
        end
        ertObjSchema=hErtObj.getObjectiveDialogSchema;
        ertObjGroup.Type='group';
        ertObjGroup.LayoutGrid=[9,3];
        ertObjGroup.Items=ertObjSchema.Items;
        ertObjGroup.RowSpan=[1,1];
        ertObjGroup.ColSpan=[1,1];
        objGroup=ertObjGroup;
    end

    dummy.Type='text';
    dummy.Name=' ';
    dummy.RowSpan=[1,1];
    dummy.ColSpan=[2,2];

    objSelect.Items={objGroup,dummy};


