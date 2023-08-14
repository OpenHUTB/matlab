function totalRecAdded=getDTConstraintRecords(~,runObj,curDTConstraintsSet)







    totalNumAdded=0;
    totalRecAdded={};

    for i=1:length(curDTConstraintsSet)
        constraint=curDTConstraintsSet{i};
        if isempty(constraint)

            continue;
        end
        uniqueId=constraint{1};
        constraintToAdd=constraint{2};
        if~isempty(uniqueId)
            [targetRecord,addedRecNum]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',uniqueId});
            if addedRecNum>0
                totalNumAdded=totalNumAdded+addedRecNum;
                totalRecAdded{end+1}=targetRecord;%#ok
            end
            if targetRecord.hasDTConstraints
                newConstraint=targetRecord.getConstraints{1}+constraintToAdd;
                targetRecord.setDTConstraints({newConstraint});
            else
                targetRecord.setDTConstraints({constraintToAdd});
            end
        end
    end
end
