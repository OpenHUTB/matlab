function theRowVec=getRowVectorOfGpuarrayMethods()








    persistent theMethods;

    if isempty(theMethods)
        theMethods=methods('gpuArray');
        if~isrow(theMethods)


            theMethods=theMethods';
        end
    end

    theRowVec=theMethods;
end
