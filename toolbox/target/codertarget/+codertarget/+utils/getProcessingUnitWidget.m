function info=getProcessingUnitWidget(hObj,varargin)





    label=DAStudio.message('codertarget:ui:ProcessingUnitLabel');
    info.ParameterGroups={};
    info.Parameters={};
    info.ParameterGroups={label};
    rowSpan=[1,1];
    if nargin>1
        rowSpan=varargin{1};
    end
    toolTip=DAStudio.message('codertarget:ui:ProcessingUnitToolTip');
    entries=codertarget.targethardware.getProcessingUnitEntries(hObj.getConfigSet);
    if isempty(entries)
        entries={'None'};
    end
    p=codertarget.parameter.ParameterInfo.getDefaultParameter();
    p.Name=label;
    p.ToolTip=toolTip;
    p.Tag='SOCB_ProcessingUnit';
    p.Type='combobox';
    p.Callback='processingUnitChangedCallback';
    p.Entries=entries;
    p.Value=entries{1};
    p.Visible=true;
    p.Enabled=true;
    p.RowSpan=rowSpan;
    p.ColSpan=[1,2];
    p.Storage=DAStudio.message('codertarget:ui:ProcessingUnitStorage');
    p.DoNotStore=false;
    p.SaveValueAsString=true;
    p.DialogRefresh=0;
    p.Data={};
    p.Alignment=0;
    info.Parameters{1}{1}=p;
end