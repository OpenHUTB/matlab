function parseConfiguration(this,hImplDatabase,startNodeName,files)

    if nargin<4
        files={};
    end


    this.clearTables;

    this.parseDefaultConfigs(hImplDatabase);

    if~isempty(startNodeName)
        this.parseUserBlockSettings(hImplDatabase,startNodeName);
    end

    if~isempty(files)
        this.parseUserConfigs(hImplDatabase,files);
    end
end