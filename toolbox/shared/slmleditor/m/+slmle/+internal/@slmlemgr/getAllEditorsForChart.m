function editors=getAllEditorsForChart(obj,chartId)


    editors={};
    values=obj.MLFBEditorMap.values;
    for i=1:length(values)
        val=values{i};
        for j=1:length(val)
            ed=val{j};
            if ed.chartId==chartId
                editors{end+1}=ed;%#ok<AGROW> 
            end
        end
    end

