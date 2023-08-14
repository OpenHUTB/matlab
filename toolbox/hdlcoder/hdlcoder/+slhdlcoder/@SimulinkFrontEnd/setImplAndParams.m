function setImplAndParams(this,hC,slbh,configManager)



    impl=this.pirGetImplementation(slbh,configManager);
    hC.setImplementation(impl);

    this.setPipelineInfo(hC,impl);

end
