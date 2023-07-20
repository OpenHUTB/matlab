function blockExplore(block,var)








    model=bdroot(block);

    msg='';
    [simlog,varName]=simscape.logging.sli.internal.getModelLog(model);
    if~isempty(simlog)
        [isValid,sourcePath]=simscape.logging.findPath(simlog,block);
        if isValid

            paren=strfind(var,'(');
            if~isempty(paren)
                var=var(1:paren(1)-1);
            end
            varPath=[sourcePath,'.',var];
            if hasPath(simlog,varPath)
                simscape.logging.internal.explore(simlog,varPath,varName);
            else
                msg=pm_message('physmod:simscape:logging:sli:kernel:SparkLinesChildNotFound',...
                getfullname(block),varPath);
            end
        else
            msg=pm_message('physmod:simscape:logging:sli:kernel:SparkLinesSourceNotFound',...
            varName,getfullname(block));
        end
    else
        msg=pm_message('physmod:simscape:logging:sli:kernel:SparkLinesVariableNotFound',...
        getfullname(model),varName,varName);
    end

    if~isempty(msg)
        errordlg(msg);
    end

end
