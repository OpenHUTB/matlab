function obj=getSubCheckObject(subcheckOptions)





    nameParts=strsplit(subcheckOptions.ID,'.');

    if strcmp(nameParts{2},'SFEditTimeCheck')
        obj=slcheck.SFEditTimeCheck(subcheckOptions.InitParams);
        return;
    end


    if numel(nameParts)~=3
        error(['The subcheck ID : ',subcheckOptions.ID,' is not of the form slcheck.<standard>.<guideline sub_id>']);
    end


    if exist(subcheckOptions.ID,'class')
        if isfield(subcheckOptions,'InitParams')

            obj=feval(subcheckOptions.ID,subcheckOptions.InitParams);
        else
            obj=eval(subcheckOptions.ID);
        end
    else
        error(['We could not find a subcheck with the id: ',subcheckOptions.ID]);
    end
end
