function compGenConnectivity(this)








    hCD=hdlconnectivity.getConnectivityDirector;























    if numel(this.outputs)==1,
        for cc=1:numel(this.outputs{1}),
            op{cc}=this.outputs{1}(cc);
        end
        dly=repmat(this.nDelays,1,numel(op));
    else
        op=this.outputs;
        dly=this.nDelays;
    end


    if isscalar(this.inputs),
        ip=hdlexpandvectorsignal(this.inputs);
    else
        ip=this.inputs;
    end
    if isscalar(this.tmpsignal),
        tmpsig=hdlexpandvectorsignal(this.tmpsignal);
    else
        tmpsig=this.tmpsignal;
    end



    for dd=1:numel(dly),

        if dly(dd)==0,

            hCD.addDriverReceiverPair(ip(dd),tmpsig(dd),...
            'realonly',false,'unroll',false);

        elseif dly(dd)==1,


            hCD.addRegister(ip(dd),op{dd},...
            this.clock,this.clockenable,'realonly',false);

            hCD.addDriverReceiverPair(op{dd},tmpsig(dd),...
            'realonly',false,'unroll',false);


        else


            hCD.addRegister(ip(dd),op{dd},...
            this.clock,this.clockenable,'realonly',false,...
            'inIndices',[],'outIndices',[0]);


            for jj=2:dly(dd),
                hCD.addRegister(op{dd},op{dd},...
                this.clock,this.clockenable,'realonly',false,...
                'inIndices',[jj-2],'outIndices',[jj-1]);
            end

            hCD.addDriverReceiverPair(op{dd},tmpsig(dd),...
            'realonly',false,'unroll',false,...
            'driverIndices',dly(dd)-1,'receiverIndices',[]);


        end

    end


