function compGenConnectivity(this)








    hCD=hdlconnectivity.getConnectivityDirector;



    for ii=1:min(numel(this.inputs),numel(this.outputs)),
        hCD.addRegister(this.inputs(ii),...
        this.outputs(ii),...
        this.clock,...
        this.clockenable,...
        'realonly',false...
        );
    end

