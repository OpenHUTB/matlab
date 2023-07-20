





function groupRename(this,groupIdx,newNames)
    allGrpNames={this.Groups.Name};
    grpCnt=length(groupIdx);

    for gidx=1:grpCnt
        m=groupIdx(gidx);
        allGrpNames{m}=uniqueify_str_with_number(newNames{gidx},m,allGrpNames{:});
        this.Groups(m).Name=allGrpNames{m};
    end

end