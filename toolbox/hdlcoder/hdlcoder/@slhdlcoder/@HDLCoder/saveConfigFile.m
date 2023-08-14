function saveConfigFile(this,filename,nondefault)


    if nargin<2
        filename='hdlcontrolfile.m';
        nondefault=false;
    elseif nargin<3
        nondefault=false;
    end


    oldDriver=hdlcurrentdriver;
    hdlcurrentdriver(this);

    configMgr=this.getConfigManager(this.ModelName);
    configMgr.saveMergedConfigFile(filename,this.ImplDB,nondefault);


    hdlcurrentdriver(oldDriver);
end

