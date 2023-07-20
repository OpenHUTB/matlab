function validateNewProjectParam(h,vstruct)




    userParam=h.mWorkflowInfo.userParam;


    if vstruct.name
        l_checkNonEmptyStr(userParam.projectName,'Project name');







        badstr=regexp(userParam.projectName,'(^[^a-zA-Z])|\W','once');
        if~isempty(badstr)
            error(message('EDALink:WorkflowManager:validateNewProjectParam:projname'));
        end
    end


    if vstruct.folder
        l_checkNonEmptyStr(userParam.projectLoc,'Project folder');



    end


    if vstruct.userfiles
    end


    if vstruct.processprop
        prop=userParam.projectProperties;

        for n=1:length(prop)
            if isempty(prop(n).name)




                if~isempty(prop(n).value)
                    p=prop(n).value;
                else
                    p=prop(n).process;
                end
                p=strrep(p,'%','%%');
                p=strrep(p,'\','\\');
                error(message('EDALink:WorkflowManager:validateNewProjectParam:emptyname',p));

            elseif isempty(prop(n).value)

                p=strrep(prop(n).name,'%','%%');
                p=strrep(p,'\','\\');
                error(message('EDALink:WorkflowManager:validateNewProjectParam:emptyvalue',p));
            end
        end

        h.mWorkflowInfo.userParam.projectProperties=prop;
    end


    function l_checkNonEmptyStr(str,prop)

        if isempty(str)||~ischar(str)
            error(message('EDALink:WorkflowManager:validateNewProjectParam:nonemptystr',prop));
        end
