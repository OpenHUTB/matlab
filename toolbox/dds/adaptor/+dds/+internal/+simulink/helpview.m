function helpview(topicId)






    validateattributes(topicId,{'char'},{'nonempty'});
    helpview(fullfile(docroot,'dds','helptargets.map'),topicId);
