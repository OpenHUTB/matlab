function transposedDesignPoints=transposeDesignPoints(designPoints)




    numOfDesignPoints=length(designPoints);
    parameterCount=length(designPoints(1).ParameterSamples);
    transposedDesignPoints=cell(1,parameterCount);

    for designPointIdx=1:numOfDesignPoints
        for parameterCountIdx=1:parameterCount
            transposedDesignPoints{parameterCountIdx}=[transposedDesignPoints{parameterCountIdx},designPoints(designPointIdx).ParameterSamples(parameterCountIdx).Value];
        end
    end
end