function parameters=parseParameters(self,simIndex,modelName,prevSymbolsInfo)
    parameters=self.parseSymbols({'Variable','Parameter'},simIndex,modelName,prevSymbolsInfo);
    if~isempty(fieldnames(parameters))
        parameters=structfun(@(p)struct('Name',p.children.Name,'Path',p.children.bindableMetaData.value.hierarchicalPathArr{1}),parameters,'UniformOutput',false);
    end
end