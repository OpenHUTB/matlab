function features(feature,state)











    if strcmpi(feature,'alignmenttool')
        feature='alignmentTools';
    end

    evt.feature=feature;
    evt.state=state;
    message.publish('/SimBiology/features',evt);
end
