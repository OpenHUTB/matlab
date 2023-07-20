function[statetype_popup,statereset_popup]=getStateWidgets(this)






    statetype_popup=this.initWidget('StateHandling',false);
    statetype_popup.Tag='_State_Type_';
    statetype_popup.RowSpan=[1,1];
    statetype_popup.ColSpan=[1,1];


    block=this.getBlock;
    statereset_popup.Name='State Reset:';
    statereset_popup.Type='combobox';
    statereset_popup.Entries=block.getPropAllowedValues('StateReset')';
    statereset_popup.Value=this.getEnumValFromStr(this.DialogData.StateReset,...
    statereset_popup.Entries);
    statereset_popup.Enabled=~this.isHierarchySimulating;
    statereset_popup.DialogRefresh=1;

    statereset_popup.Source=this;
    statereset_popup.ObjectMethod='ParamWidgetCallback';
    statereset_popup.MethodArgs={'%dialog','StateReset',true,'%value'};
    statereset_popup.ArgDataTypes={'handle','string','bool','mxArray'};

    statereset_popup.Tag='_State_Reset_';
    statereset_popup.RowSpan=[1,1];
    statereset_popup.ColSpan=[1,1];

end
