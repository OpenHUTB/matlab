function parseDefaultConfigs(this,hImplDatabase)




    if nargin<2
        hImplDatabase=this.ImplDB;
    end

    defaultConfigFiles=hImplDatabase.getConfigurationFiles;









    this.mergeConfigFiles(defaultConfigFiles,true);

    if isempty(this.MergedConfigContainer.defaults)
        error(message('hdlcoder:engine:DefaultConfigNotFound'));
    end



    defaultTable=this.DefaultTable;
    for ii=1:length(this.MergedConfigContainer.defaults)
        curB=this.MergedConfigContainer.defaults(ii);

        blockLibPath=curB.BlockType;
        impl=curB.Implementation;
        params=curB.ImplParams;


        if~hImplDatabase.isRegistered(blockLibPath,impl)
            error(message('hdlcoder:engine:unregistered',blockLibPath,impl));
        end

        defaultTable.addImplementation(this.ModelName,blockLibPath,impl,params);
    end
