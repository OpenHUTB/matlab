function this=tapdelay(varargin)





    this=hdl.tapdelay;
    this.init(varargin{:});

    if isempty(this.nDelays)
        this.nDelays=4;
    end

    if isempty(this.delayOrder)
        this.delayOrder='oldest';
    end

    if isempty(this.includeCurrent)
        this.includeCurrent='off';
    end

    if strcmpi(this.includeCurrent,'on')
        [outname,tmpidx]=hdlnewsignal([hdlsignalname(this.outputs(1)),'_tmp'],...
        '',-1,...
        hdlsignaliscomplex(this.outputs(1)),...
        (hdlsignalvector(this.outputs(1))-1),...
        hdlsignalvtype(this.outputs(1)),...
        hdlsignalsltype(this.outputs(1)),...
        hdlsignalrate(this.outputs(1)));

        this.tmpsignal=this.outputs(1);
        this.outputs=tmpidx;
    end
