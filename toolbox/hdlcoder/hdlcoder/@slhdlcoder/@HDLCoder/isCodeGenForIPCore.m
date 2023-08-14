function result=isCodeGenForIPCore(this)





    result=~isempty(this.DownstreamIntegrationDriver)&&...
    this.DownstreamIntegrationDriver.isIPCoreGen;

end
