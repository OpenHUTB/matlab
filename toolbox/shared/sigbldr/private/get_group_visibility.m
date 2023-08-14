function visibility=get_group_visibility(UD)






    SBSigSuite=UD.sbobj;
    grpCount=SBSigSuite.NumGroups;
    sigCount=SBSigSuite.Groups(1).NumSignals;

    visibility=zeros(sigCount,grpCount);

    for grp=1:grpCount

        visibility(UD.dataSet(grp).activeDispIdx,grp)=1;
    end

end

