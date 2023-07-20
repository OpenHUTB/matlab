function[LoggedProps,NonDefaultCheckOnlyProps]=getPropertiesForLogging(this)







    persistent PropsToLog NonDefaultCheckOnlyPropsToLog
    if isempty(PropsToLog)
        excludedStrings={'directory','name','path','comment','file','prefix','suffix','postfix','cmd','label'};

        f=fieldnames(this);
        PropsToLog={};
        NonDefaultCheckOnlyPropsToLog={};
        for indx=1:length(f)
            p=findprop(this,f{indx});
            if strcmp(p.Name,'HDLSubsystem')

                continue
            end
            if(~strcmp(p.DataType,'ustring')&&~strcmp(p.DataType,'nestring'))||...
                strcmp(p.Visible,'off')||~contains(lower(p.Name),excludedStrings)




                PropsToLog{end+1}=f{indx};%#ok<AGROW>
            else


                NonDefaultCheckOnlyPropsToLog{end+1}=f{indx};%#ok<AGROW> 
            end
        end
    end

    LoggedProps=PropsToLog;
    NonDefaultCheckOnlyProps=NonDefaultCheckOnlyPropsToLog;
