function clearAllGraderBadges()
    try
        b=diagram.badges.get('GraderBadge','BlockNorthEast');
    catch ME
        if(strcmp(ME.identifier,'diagram_badges:badges:NonExistingBadgeKey'))

            return;
        else
            rethrow(ME)
        end
    end

    b.remove();
end
