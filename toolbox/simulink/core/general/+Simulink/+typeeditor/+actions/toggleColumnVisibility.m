function toggleColumnVisibility(colName,~)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    try
        if~isempty(ed.getStudio)&&ed.isVisible
            lc=ed.getListComp;
            colConfig=lc.getColumnWidths;
            colNames={jsondecode(colConfig).columns.name};
            strIdx=strcmp(colName,colNames);
            isVisible=any(strIdx);
            if isVisible
                newProps=colNames;
                newProps(strIdx)=[];
            else
                if slfeature('TypeEditorStudio')>0
                    listProps=Simulink.typeeditor.app.Editor.getColumnsForView(ed.getColumnView);
                else
                    listProps=Simulink.typeeditor.app.Editor.getHeterogeneousColumns;
                end
                origIdx=find(strcmp(colName,listProps));
                if length(colNames)>=origIdx
                    newProps=[colNames(1:origIdx-1),colName,colNames(origIdx:end)];
                else
                    newProps=[colNames,colName];
                end
            end
            lc.setColumns(newProps,'','',false);
            lc.update(true);
        end
    catch ME
        Simulink.typeeditor.utils.reportError(ME.message);
    end