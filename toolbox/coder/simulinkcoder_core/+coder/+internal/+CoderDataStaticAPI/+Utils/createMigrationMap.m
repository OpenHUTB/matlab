function out=createMigrationMap()
    categoryMap=containers.Map;
    categoryMap('MemSecDataConstants')={'Constants'};
    categoryMap('MemSecDataIO')={'Inports','Outports'};
    categoryMap('MemSecDataInternal')={'InternalData'};
    categoryMap('MemSecDataParameters')={'LocalParameters','GlobalParameters'};
    categoryMap('MemSecFuncInitTerm')={'InitializeTerminate'};
    categoryMap('MemSecFuncExecute')={'Execution'};
    categoryMap('MemSecFuncSharedUtil')={'SharedUtility'};
    out=categoryMap;
end