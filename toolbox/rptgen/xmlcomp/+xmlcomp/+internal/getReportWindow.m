function r=getReportWindow(filename1,filename2)












    r=[];
    desktop=com.mathworks.mde.desk.MLDesktop.getInstanceNoCreate;
    if isempty(desktop)
        return
    end
    reports=desktop.getGroupMembers('File Comparisons');


    for i=1:numel(reports)
        if isa(reports(i),'com.mathworks.comparisons.gui.report.ComparisonReport')

            title=char(reports(i).getShortTitle);


            if~isempty(regexp(title,filename1,'once'))&&...
                ~isempty(regexp(title,filename2,'once'))
                r=reports(i);
                break;
            end
        end
    end

