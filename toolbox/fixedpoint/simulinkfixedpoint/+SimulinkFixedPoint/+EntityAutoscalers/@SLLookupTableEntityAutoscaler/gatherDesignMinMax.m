function[minValue,maxValue]=gatherDesignMinMax(h,blkObj,pathItem)









    minValue=[];
    maxValue=[];
    if~any(contains(pathItem,{'Intermediate Results','Fraction'}))
        outputPathItem=h.getPortMapping([],[],1);
        baseParameterName=pathItem;
        if strcmp(pathItem,outputPathItem{1})
            baseParameterName='Out';
        end

        minParamName=[baseParameterName,'Min'];
        maxParamName=[baseParameterName,'Max'];



        if~strcmpi(blkObj.(minParamName),'[]')
            minValue=slResolve(blkObj.(minParamName),blkObj.Handle);
        end



        if~strcmpi(blkObj.(maxParamName),'[]')
            maxValue=slResolve(blkObj.(maxParamName),blkObj.Handle);
        end
    end
end
