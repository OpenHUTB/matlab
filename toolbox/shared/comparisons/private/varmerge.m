function varmerge(srcfile,dstfile,varname,report_id)





    try
        if~isempty(figwhos('-file',dstfile,varname))


            backupname=[dstfile,'~'];
            figureCleanup=createFigureCleanup();
            value=load(dstfile,'-mat',varname);%#ok<NASGU>
            if exist(backupname,'file')
                save(backupname,'-struct','value','-append');
            else
                save(backupname,'-struct','value');
            end
            delete(figureCleanup);
        end
    catch E

        disp(E.message);
    end

    try
        figureCleanup=createFigureCleanup();
        if isempty(figwhos('-file',srcfile,varname))

            deletevar(dstfile,varname);
        else

            value=load(srcfile,'-mat',varname);%#ok<NASGU>
            save(dstfile,'-struct','value','-append');
        end
        delete(figureCleanup);
    catch E

        if nargin>3&&~isempty(report_id)
            c=com.mathworks.comparisons.compare.concr.MatDataComparison.getComparison(report_id);
            if~isempty(c)
                c.doErrorDialog(E.message);
                return;
            end
        end
        throw(E);
    end


    if nargin>3&&~isempty(report_id)
        c=com.mathworks.comparisons.compare.concr.MatDataComparison.getComparison(report_id);
        if~isempty(c)
            c.doRefresh;
        end
    end
end




