function headNamedType=getHeadNamedType(this)







    resolutionQueue=getResolutionQueueForNamedType(this);
    headNamedType=resolutionQueue{1};
end
