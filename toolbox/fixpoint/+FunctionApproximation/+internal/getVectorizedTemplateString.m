function templateString=getVectorizedTemplateString(interpolation,spacing)



    switch interpolation


    case 'Flat'
        if spacing==0
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/flatVectorizedEvenSpacing.txt'));
        elseif spacing==1
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/flatVectorizedEvenPowTwoSpacing.txt'));
        else
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/flatVectorizedExplicitValues.txt'));
        end

    case 'Nearest'
        if spacing==0
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/nearestVectorizedEvenSpacing.txt'));
        elseif spacing==1
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/nearestVectorizedEvenPowTwoSpacing.txt'));
        else
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/nearestVectorizedExplicitValues.txt'));
        end

    case 'Linear'
        if spacing==0
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/linearVectorizedEvenSpacing.txt'));
        elseif spacing==1
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/linearVectorizedEvenPowTwoSpacing.txt'));
        else
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/linearVectorizedExplicitValues.txt'));
        end
    otherwise
        templateString='';
    end
end
