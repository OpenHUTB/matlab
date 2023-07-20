





function allGrpNames=groupNamesUpdate(this,newGrpNames)
    curGrpCnt=this.NumGroups;
    newGrpCnt=length(newGrpNames);
    allGrpNames={this.Groups.Name};
    allGrpNames=[allGrpNames,newGrpNames];
    for i=1:newGrpCnt

        allGrpNames{curGrpCnt+i}=uniqueify_str_with_number(newGrpNames{i},0,allGrpNames{1:(curGrpCnt+i-1)});
    end
end