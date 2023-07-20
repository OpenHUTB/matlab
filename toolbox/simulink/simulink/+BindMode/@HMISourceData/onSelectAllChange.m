

function success=onSelectAllChange(this,~,bindableRows,isChecked)
    success=false;
    widgetType=utils.getWidgetType(this.sourceElementHandle);
    if(strcmp(widgetType,'DashboardScope'))
        rowCount=numel(bindableRows);
        allBindableTypes=cell(1,rowCount);
        allBindableMetaData=cell(1,rowCount);
        allIsConnected=logical.empty(0,rowCount);
        for idx=1:rowCount
            row=bindableRows(idx);
            allBindableTypes{idx}=row.bindableTypeChar;
            allBindableMetaData{idx}=BindMode.utils.processForSelectionInCtxModel(...
            row.bindableMetaData,this.modelName);
            allIsConnected(idx)=isChecked;
        end
        success=utils.HMIBindMode.changeDashboardScopeBinding(...
        this.sourceElementHandle,...
        allBindableTypes,...
        allBindableMetaData,...
        allIsConnected);
    end
end