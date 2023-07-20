function[symbols,conflicts]=parseSymbols(self,scopes,simIndex,modelName,prevSymbolsInfo)
    unscoped=isempty(scopes);
    conflicts=struct();
    symbols=struct();
    prevSymbolsDefined=nargin>=5;

    if simIndex==1
        symbolsInfo=self.symbolsInfo;
    else
        symbolsInfo=self.symbolsInfo2;
    end

    for symbolInfo=symbolsInfo
        name=symbolInfo.value;
        if isfield(symbols,name)||isfield(conflicts,name)
            symbols=rmfield(symbols,name);
            conflicts.(name)=1;
        elseif strcmp(symbolInfo.scope,'UseMapping1')
            if isfield(prevSymbolsInfo,name)
                symbols.(name)=replaceModelInMetaData(prevSymbolsInfo.(name),modelName);
            end
        elseif unscoped||ismember(symbolInfo.scope,scopes)
            if isempty(modelName)
                symbols.(name)=symbolInfo;
            else
                symbols.(name)=replaceModelInMetaData(symbolInfo,modelName);
            end
        end

        if prevSymbolsDefined&&isfield(prevSymbolsInfo,name)
            prevSymbolsInfo=rmfield(prevSymbolsInfo,name);
        end
    end


    if prevSymbolsDefined
        prevSymbolNames=fieldnames(prevSymbolsInfo);
        for i=1:length(prevSymbolNames)
            symbols.(prevSymbolNames{i})=replaceModelInMetaData(prevSymbolsInfo.(prevSymbolNames{i}),modelName);
        end
    end

    conflicts=fieldnames(conflicts)';
end

function result=replaceModelInMetaData(symbolInfo,modelName)
    result=symbolInfo;
    if~isfield(symbolInfo.children,'bindableMetaData')||isempty(modelName)
        return;
    end

    if isfield(symbolInfo.children.bindableMetaData.value,'blockPathStr')
        if~isfield(symbolInfo.children.bindableMetaData.value,'hierarchicalPathArr')||length(symbolInfo.children.bindableMetaData.value.hierarchicalPathArr)==2


            symbolInfo.children.bindableMetaData.value.blockPathStr=replaceModel(symbolInfo.children.bindableMetaData.value.blockPathStr,modelName);
        end
    end

    if isfield(symbolInfo.children.bindableMetaData.value,'hierarchicalPathArr')
        symbolInfo.children.bindableMetaData.value.hierarchicalPathArr{1}=replaceModel(symbolInfo.children.bindableMetaData.value.hierarchicalPathArr{1},modelName);
        symbolInfo.children.bindableMetaData.value.hierarchicalPathArr{2}=replaceModel(symbolInfo.children.bindableMetaData.value.hierarchicalPathArr{2},modelName);
    end

    symbolInfo.children.Path.value=replaceModel(symbolInfo.children.Path.value,modelName);
    result=symbolInfo;
end

function result=replaceModel(path,modelName)
    tmp=strfind(path,'/');
    result=[modelName,path(tmp(1):end)];
end
