function normalizedOutput=localNormCalculator(input)






    input(isnan(input))=0;
    columnSum=sqrt(sum(input.^2));
    normalizedOutput=input./columnSum;
end

