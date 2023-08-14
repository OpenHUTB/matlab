function templateString=getBasicTemplateString(interpolation,spacing)



    switch interpolation


    case 'Flat'
        if spacing==0
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/flatEvenSpacing.txt'));
        elseif spacing==1
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/flatEvenPowTwoSpacing.txt'));
        else
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/flatExplicitValues.txt'));
        end

    case 'Nearest'
        if spacing==0
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/nearestEvenSpacing.txt'));
        elseif spacing==1
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/nearestEvenPowTwoSpacing.txt'));
        else
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/nearestExplicitValues.txt'));
        end

    case 'Linear'
        if spacing==0
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/linearEvenSpacing.txt'));
        elseif spacing==1
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/linearEvenPowTwoSpacing.txt'));
        else
            templateString=fileread(which('+FunctionApproximation/+internal/+luttemplate/linearExplicitValues.txt'));
        end

    otherwise
        templateString='';
    end
end
