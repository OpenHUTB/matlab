function[actiterflag_chk]=getActFlagWidget(this)






    actiterflag_chk.Name=DAStudio.message('Simulink:dialog:ForEachActiveIterPromp');
    actiterflag_chk.Type='checkbox';
    actiterflag_chk.Value=isequal(this.DialogData.NeedActiveIterationSignal,'on');
    actiterflag_chk.Enabled=~this.isHierarchySimulating;
    actiterflag_chk.DialogRefresh=1;

    actiterflag_chk.Source=this;
    actiterflag_chk.ObjectMethod='ParamWidgetCallback';
    actiterflag_chk.MethodArgs={'%dialog','NeedActiveIterationSignal',true,'%value'};
    actiterflag_chk.ArgDataTypes={'handle','string','bool','mxArray'};

    actiterflag_chk.Tag='_Need_Active_Iteration_Signal_';
    actiterflag_chk.RowSpan=[1,1];
    actiterflag_chk.ColSpan=[1,1];

end
