function this=pipemul(varargin)





    this=hdl.pipemul;

    this.init(varargin{:});

    if isempty(this.roundmode)
        this.roundmode='floor';
    end

    if isempty(this.saturation)
        this.saturation=0;
    end

    if isempty(this.realonly)
        this.realonly=false;
    end

    if length(this.outputs)>1
        this.resetvalues=this.resetvalues(:);
    end

    if this.inputpipelevels>0
        aname=hdllegalnamersvd(hdlsignalname(this.inputs(1)));
        avec=hdlsignalvector(this.inputs(1));
        avtype=hdlsignalvtype(this.inputs(1));
        asltype=hdlsignalsltype(this.inputs(1));
        acplx=hdlsignaliscomplex(this.inputs(1));

        bname=hdllegalnamersvd(hdlsignalname(this.inputs(2)));
        bvec=hdlsignalvector(this.inputs(2));
        bvtype=hdlsignalvtype(this.inputs(2));
        bsltype=hdlsignalsltype(this.inputs(2));
        bcplx=hdlsignaliscomplex(this.inputs(2));

        for ii=1:this.inputpipelevels
            [~,this.areg(ii)]=hdlnewsignal([aname,hdlgetparameter('PipelinePostfix')],...
            'block',-1,acplx,...
            avec,avtype,asltype);
            hdlregsignal(this.areg(ii));
            [~,this.breg(ii)]=hdlnewsignal([bname,hdlgetparameter('PipelinePostfix')],...
            'block',-1,bcplx,...
            bvec,bvtype,bsltype);
            hdlregsignal(this.breg(ii));
        end
    else
        this.areg=this.inputs(1);
        this.breg=this.inputs(2);
    end

    mvec=hdlsignalvector(this.outputs(1));
    mcplx=hdlsignaliscomplex(this.outputs(1));

    this.finalout=this.outputs(1);
    outname=hdlsignalname(this.finalout);

    if this.outputpipelevels>0
        [~,~,~,mvtype,msltype]=hdl.muldt(this.inputs(1),this.inputs(2));

        for ii=1:this.outputpipelevels
            [~,this.mreg(ii)]=hdlnewsignal([hdllegalnamersvd(outname),hdlgetparameter('PipelinePostfix')],...
            'block',-1,mcplx,...
            mvec,mvtype,msltype);
            hdlregsignal(this.mreg(ii));
        end
    else
        this.mreg=[];
    end


    if this.inputpipelevels>0
        this.outputs=[this.areg,this.breg,this.mreg];
    else
        this.outputs=this.mreg;
    end
    this.resetvalues=zeros(numel(this.outputs),1);
