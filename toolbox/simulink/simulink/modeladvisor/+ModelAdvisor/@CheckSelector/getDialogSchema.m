function dlg=getDialogSchema(this)





    checkIDSelector.Type='group';
    checkIDSelector.Name='';
    checkIDSelector.LayoutGrid=[1,1];
    checkIDSelector.Flat=true;

    blkInfo=this.cbinfo.userdata.prop.value;
    if~isempty(blkInfo)
        blkInfo=['',blkInfo,''];
        if length(blkInfo)>50
            blkInfo=['.../',blkInfo(end-50:end)];
        end
    end
    exclusionDescription=this.cbinfo.userdata.prop.propDesc;
    if~isempty(strfind(exclusionDescription,'%s'))
        exclusionDescription=sprintf(exclusionDescription,this.cbinfo.userdata.prop.name);
    end
    exclusionInfo=exclusionDescription;
    exclusionInfo=DAStudio.message('ModelAdvisor:engine:ForSelectedChecks',exclusionInfo);


    checkIDList.Name=exclusionInfo;
    checkIDList.Type='listbox';
    checkIDList.Entries=this.getCheckNameList();
    checkIDList.MinimumSize=[450,350];
    checkIDList.ListDoubleClickCallback=@clicklistUnSel;
    checkIDList.Tag='checkIDListTag';
    checkIDList.WidgetId='checkIDListWidget';
    checkIDList.FontPointSize=10;


    checkIDTextWidget.Name='';
    checkIDTextWidget.Tag='checkIDTextWidget';
    checkIDTextWidget.Type='text';
    checkIDTextWidget.Value='';

    checkIDSelector.Items={checkIDList,checkIDTextWidget};


    dlg.Items={checkIDSelector};
    dlg.DialogTag=this.getDialogTag;
    dlg.StandaloneButtonSet={'OK'};
    dlg.DialogTitle=[DAStudio.message('ModelAdvisor:engine:CheckSelectorHeading'),' - ',blkInfo];
    dlg.DialogRefresh=true;
    dlg.Sticky=1;
    dlg.PostApplyMethod='postApply';
    dlg.DisplayIcon=fullfile('toolbox','simulink','simulink','modeladvisor','resources','ma.png');
end



function clicklistUnSel(h,~,index)
    if(~isempty(index))
        checkSelector=h.getSource;
        checkIDList=checkSelector.getCheckIDList;
        index=index+1;
        h.setWidgetValue('checkIDTextWidget',checkIDList{index});
    end
end