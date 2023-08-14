function label=makeSummary(this,artifactlabel,locationLabel)%#ok<INUSL>






    label=artifactlabel;
    if length(label)>33
        label=[label(1:33),'...'];
    end
    if~isempty(locationLabel)
        label=[locationLabel,' (',label,')'];
    end
end
