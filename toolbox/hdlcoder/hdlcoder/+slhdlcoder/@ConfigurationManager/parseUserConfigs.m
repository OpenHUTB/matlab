function parseUserConfigs(this,hImplDatabase,configFiles)




    this.mergeConfigFiles(configFiles,false);

    configStmts=this.MergedConfigContainer.statements;

    this.parseConfigStatements(hImplDatabase,configStmts);