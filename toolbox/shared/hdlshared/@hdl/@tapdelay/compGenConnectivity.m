function compGenConnectivity(this)








    hCD=hdlconnectivity.getConnectivityDirector;


    if this.nDelays>1,
        if strcmpi(this.delayOrder,'newest')
            out1Ind=0;
            inInd=(0:this.nDelays-2);
            outInd=(1:this.nDelays-1);
            dInd=(0:this.nDelays-1);
        else
            out1Ind=this.nDelays-1;
            inInd=(1:this.nDelays-1);
            outInd=(0:this.nDelays-2);
            dInd=(0:this.nDelays-1);
        end
    else
        out1Ind=[];
        dInd=[];
    end



    hCD.addRegister(this.inputs,this.outputs,this.clock,this.clockenable,...
    'unroll',false,'realonly',false,...
    'inIndices',[],'outIndices',out1Ind);

    if this.nDelays>1,

        hCD.addRegister(this.outputs,this.outputs,this.clock,this.clockenable,...
        'unroll',false,'realonly',false,...
        'inIndices',inInd,'outIndices',outInd);
    end



    if strcmp(this.includecurrent,'on'),
        if strcmpi(this.delayorder,'Newest'),
            hCD.addDriverReceiverPair(this.outputs,this.tmpsignal,'realonly',false,...
            'receiverIndices',(1:this.nDelays),'driverIndices',dInd,'unroll',false);

            hCD.addDriverReceiverPair(this.inputs,this.tmpsignal,'realonly',false,...
            'receiverIndices',0,'driverIndices',[],'unroll',false);

        else

            hCD.addDriverReceiverPair(this.outputs,this.tmpsignal,'realonly',false,...
            'receiverIndices',(0:this.nDelays-1),'driverIndices',dInd,'unroll',false);

            hCD.addDriverReceiverPair(this.inputs,this.tmpsignal,'realonly',false,...
            'receiverIndices',this.nDelays,'driverIndices',[],'unroll',false);

        end
    end

