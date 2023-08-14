function[summaryLine,xyzLabelCode]=generateNoLegend(chartName,varNames,zVar)












    chartString=['`',chartName,'`'];
    firstVar=varNames{1};
    secondVar='';
    if numel(varNames)>1
        secondVar=varNames{2};
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryTwoData";
        if isempty(zVar)
            summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar,secondVar));
        else
            summaryLine=getString(message(summaryMsgCatalog,chartString,[firstVar,', ',secondVar,','],zVar));
        end
    else
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryOneData";
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar));
    end

    xyzLabelCode=getXYLabelCode(firstVar,secondVar,zVar);
end

function xyLabelCode=getXYLabelCode(firstVar,secondVar,zVar)
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(firstVar);
    secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(secondVar);
    zVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(zVar);
    titleCode='';
    xyLabelCode='';
    commentCode='';
    if~isempty(secondVar)
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel, ylabel','title'))];
        xyLabelCode=[newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''',secondVar,''')'];
        titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    elseif~isempty(firstVar)&&isempty(zVar)
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'ylabel','title'))];
        xyLabelCode=[newline,'ylabel(''',firstVar,''')'];
        titleCode=[newline,'title(''',firstVar,''')'];
    end
    if~isempty(zVar)
        if isempty(titleCode)
            titleCode=[newline,'title(''',zVar,''')'];
        else
            if~isempty(secondVar)&&~isempty(firstVar)
                titleCode=[newline,'title(''',zVar,' vs. ',firstVar,' and ',secondVar,''')'];
            elseif isempty(secondVar)&&~isempty(firstVar)
                titleCode=[newline,'title(''',zVar,' vs. ',firstVar,''')'];
            end
        end
        if isempty(commentCode)
            commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'zlabel','title'))];
        else
            commentCode=replace(commentCode,'ylabel','ylabel, zlabel');
        end
        xyLabelCode=[xyLabelCode,newline,'zlabel(''',zVar,''')'...
        ,titleCode];
    elseif~isempty(titleCode)
        xyLabelCode=[xyLabelCode...
        ,titleCode];
    end
    xyLabelCode=[commentCode...
    ,xyLabelCode];
end