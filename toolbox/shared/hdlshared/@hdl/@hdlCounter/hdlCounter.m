function this=hdlCounter(varargin)





    this=hdl.hdlCounter;

    this.init(varargin{:});

    if length(this.outputs)>1
        this.resetvalues=this.resetvalues(:);
    end



    getCounterSignal(this);



    function getCounterSignal(this)

        slType=hdlsignalsltype(this.outputs);
        type=hdlgetallfromsltype(slType);

        newType=this.getCounterType(type);


        [sigName,sigIdx]=hdlnewsignal('counter','block',-1,0,0,newType.vtype,newType.sltype);
        this.CounterSignal=this.outputs;
        this.outputs=sigIdx;


