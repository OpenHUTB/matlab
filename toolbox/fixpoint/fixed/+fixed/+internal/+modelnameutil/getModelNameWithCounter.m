function modelName=getModelNameWithCounter(baseName)






    if nargin<1
        baseName=['model_',datestr(now,'yyyymmddTHHMMSSFFF')];
    end

    i=1;
    modelName=baseName;
    while(exist(modelName,'file')==4)
        i=i+1;
        modelName=[baseName,'_',int2str(i)];
    end
end
