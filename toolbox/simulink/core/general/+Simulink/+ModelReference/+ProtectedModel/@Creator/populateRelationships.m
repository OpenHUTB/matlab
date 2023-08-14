function populateRelationships(obj)




    for i=1:length(obj.relationshipClasses)
        if isempty(intersect(i,obj.deferredPopulationRelationshipIndex))
            obj.relationshipClasses{i}.populate(obj);
        end
    end

end

