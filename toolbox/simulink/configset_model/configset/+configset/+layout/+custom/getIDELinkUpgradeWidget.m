function out=getIDELinkUpgradeWidget(~,varargin)









    upgradeText=[message('codertarget:setup:UARealtime2CoderTarget_modelNotCompliant').getString,' '...
    ,message('codertarget:setup:CoderTargetMsgForIdelink').getString];

    group.Type='group';
    group.LayoutGrid=[5,6];
    group.Items={};

    textwidget.Type='text';
    textwidget.Name=upgradeText;
    textwidget.WordWrap=true;
    textwidget.MinimumSize=[600,20];
    textwidget.Tag='IDELINK_upgrademodel_message';
    textwidget.ColSpan=[1,6];
    textwidget.RowSpan=[1,2];
    group.Items{end+1}=textwidget;

    buttonwidget.Type='pushbutton';
    buttonwidget.Name=message('codertarget:setup:FixButton').getString;
    buttonwidget.Tag='IDELINK_Fix_Button';
    buttonwidget.ColSpan=[1,1];
    buttonwidget.RowSpan=[4,4];
    buttonwidget.MatlabMethod='UpgradeAdvisor.openFromBanner';
    buttonwidget.Visible=true;
    buttonwidget.Enabled=true;
    group.Items{end+1}=buttonwidget;

    out.Items{1}=group;
end

