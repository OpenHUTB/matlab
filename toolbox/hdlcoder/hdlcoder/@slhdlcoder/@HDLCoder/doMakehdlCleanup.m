function doMakehdlCleanup(this,hs,me)




    pirNetworkForFilterComp('reset');
    hdlconnectivity.slhcConnectivityCleanup([],this.ModelName,false);
    this.cleanup(hs,false);
    hdlresetgcb(hs.current_system);
    targetcodegen.alteradspbadriver.process('cleanup',this);
    rethrow(me);
end
