function uuid=removeComment(this,review)







    uuid=review.getUuid;
    modelObj=review.getModelObj();
    modelObj.destroy;
    review.delete;
end
