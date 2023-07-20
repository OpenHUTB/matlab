function updateBackend(this)

    manager=slcheck.getAdvisorFilterManager(this.model);
    manager.clear();


    for idx=1:numel(this.TableData)

        item=this.TableData{idx};
        type=item{2};
        reason=item{3};
        checks=item{4}.checks;
        if strcmp(checks,'{All Checks}')
            checks={'.*'};
        else
            checks=strtrim(strsplit(checks(2:end-1),','));
        end

        id=item{1}.sid;

        manager.addAdvisorFilterSpecificationArray(slcheck.getsid(id),...
        slcheck.getFilterTypeEnum(type),...
        slcheck.getFilterModeEnum('Exclude'),...
        reason,checks);
    end
end

