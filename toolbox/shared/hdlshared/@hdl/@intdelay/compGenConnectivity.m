function compGenConnectivity(this)






    hCD=hdlconnectivity.getConnectivityDirector;



    lenout=length(this.outputs);
    realonly=~hdlsignaliscomplex(this.outputs(1));

    inp=hdlexpandvectorsignal(this.inputs);
    morethanone=lenout>1;

    if this.nDelays==1

        hCD.addRegister(this.inputs,this.outputs,this.clock,this.clockenable,...
        'realonly',realonly,'unroll',true);
    else
        tmp=hdlexpandvectorsignal(this.tmpsignal);


        for ii=1:lenout,

            hCD.addRegister(inp(ii),this.outputs(ii),this.clock,this.clockenable,...
            'realonly',realonly,'unroll',false,...
            'inIndices',[],'outIndices',0);

            for jj=2:this.nDelays,
                hCD.addRegister(this.outputs(ii),this.outputs(ii),this.clock,this.clockenable,...
                'realonly',realonly,'unroll',false,...
                'inIndices',(jj-2),'outIndices',jj-1);




            end

            hCD.addDriverReceiverPair(this.outputs(ii),tmp(ii),...
            'realonly',realonly,'unroll',false,...
            'driverIndices',this.nDelays-1,'receiverIndices',[]);


        end

    end

