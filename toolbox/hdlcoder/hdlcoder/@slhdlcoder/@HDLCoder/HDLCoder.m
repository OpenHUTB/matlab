function this=HDLCoder





    this=slhdlcoder.HDLCoder;


    this.ChecksCatalog=containers.Map();
    this.TestbenchChecksCatalog=containers.Map();


    this.WebBrowserHandles=WebBrowserHandleCollector();


    this.NeedToGenerateHTMLReport=true;

    this.nfp_stats=containers.Map();

    this.ConfigManager=containers.Map('KeyType','char','ValueType','any');

    this.CalledFromMakehdl=true;
