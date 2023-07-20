function distance=getEditDistanceStrings(stringA,stringB)





    stringA=char(stringA);
    stringB=char(stringB);
    m=length(stringA);
    n=length(stringB);
    levenshteinMatrix=zeros(m+1,n+1);
    levenshteinMatrix(:,1)=(0:m)';
    levenshteinMatrix(1,:)=(0:n);
    for i=1:m
        for j=1:n
            c=stringA(i)~=stringB(j);
            levenshteinMatrix(i+1,j+1)=min([levenshteinMatrix(i,j+1)+1
            levenshteinMatrix(i+1,j)+1
            levenshteinMatrix(i,j)+c]);
        end
    end
    distance=levenshteinMatrix(m+1,n+1);
end
