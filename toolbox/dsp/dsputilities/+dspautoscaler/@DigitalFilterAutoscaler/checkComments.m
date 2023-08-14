function comments=checkComments(h,blkObj,pathItem)




    comments={};
    if~strcmpi(pathItem,'Denominator coefficients')



        comments=checkComments@dvautoscaler.DspEntityAutoscaler(h,blkObj,pathItem);
    end
end