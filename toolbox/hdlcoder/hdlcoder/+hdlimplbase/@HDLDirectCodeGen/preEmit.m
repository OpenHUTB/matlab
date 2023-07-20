function oldContext=preEmit(this,hDriver,hComponent)


















    if hdlconnectivity.genConnectivity
        hCD=hdlconnectivity.getConnectivityDirector;
        hCD.setCurrentAdapter('Direct_Emit');
        oldContext.connectivity=1;
    else
        oldContext.connectivity=0;
    end

    numInstantiation=1;


    if isa(this,'hdlfilterblks.abstractFilter')
        numChannel=hComponent.HDLUserData.FilterObject.numChannel;

        isChannelShared=0;
        fParams=this.filterImplParamNames;
        if any(strcmpi('channelsharing',fParams))
            if strcmpi(this.getImplParams('channelsharing'),'on')
                isChannelShared=1;
            end
        end
        if~isChannelShared
            numInstantiation=numChannel;
        end
    end


    resrc=[PersistentHDLResource...
    ,struct('comp',hComponent,...
    'bom',containers.Map(),...
    'numInst',numInstantiation)];
    PersistentHDLResource(resrc);


