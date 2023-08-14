function this=spblkmultiply(varargin)




    this=hdl.spblkmultiply;
    this.init(varargin{:});





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);
    slrate=this.slrate;

    this.cplx1=hdlsignaliscomplex(this.in1);
    this.cplx2=hdlsignaliscomplex(this.in2);
    if this.cplx1&&this.cplx2
        outsltype=this.accumulator_sltype;
    else
        outsltype=this.product_sltype;
    end

    if this.cplx1||this.cplx2
        outcplx=true;
    else
        outcplx=false;
    end

    in1expanded=hdlexpandvectorsignal(this.in1);
    in2expanded=hdlexpandvectorsignal(this.in2);

    this.in1vec=in1expanded;
    this.in2vec=in2expanded;


    if(length(in1expanded)==1)&&(length(in2expanded)>1)

        this.in1vec=repmat(in1expanded,length(in2expanded),1);

    elseif(length(in1expanded)>1)&&(length(in2expanded)==1)

        this.in2vec=repmat(in2expanded,length(in1expanded),1);

    end

    impost=hdlgetparameter('Complex_Imag_Postfix');
    repost=hdlgetparameter('Complex_Real_Postfix');
    if emitMode
        prodvtype=hdlblockdatatype(this.product_sltype);


        [oname,this.out]=hdlnewsignal(this.outname,'block',-1,outcplx,length(this.in1vec),hdlblockdatatype(outsltype),outsltype);


        if this.cplx1&&this.cplx2
            [re1n,this.re1]=hdlnewsignal([this.outname,repost,'_partial1'],'block',-1,0,length(this.in1vec),prodvtype,this.product_sltype);
            [re2n,this.re2]=hdlnewsignal([this.outname,repost,'_partial2'],'block',-1,0,length(this.in1vec),prodvtype,this.product_sltype);
            [im1n,this.im1]=hdlnewsignal([this.outname,impost,'_partial1'],'block',-1,0,length(this.in1vec),prodvtype,this.product_sltype);
            [im2n,this.im2]=hdlnewsignal([this.outname,impost,'_partial2'],'block',-1,0,length(this.in1vec),prodvtype,this.product_sltype);
        end
    else
        hT=outsltype.BaseType;
        if outcplx
            hT=hN.getType('Complex',...
            'BaseType',hT);
        end
        veclen=length(this.in1vec);
        if veclen>1
            hT=hN.getType('Array',...
            'BaseType',hT,...
            'Dimensions',veclen);
        end
        this.out=hN.addSignal2('Type',hT,'Name',this.outname,...
        'SimulinkRate',slrate);
        if this.cplx1&&this.cplx2

            hT=this.product_sltype.BaseType;
            veclen=length(this.in1vec);
            if veclen>1
                hT=hN.getType('Array',...
                'BaseType',hT,...
                'Dimensions',veclen);
            end
            this.re1=hN.addSignal2('Type',hT,'Name',[this.outname,repost,'_partial1'],...
            'SimulinkRate',slrate);
            this.re2=hN.addSignal2('Type',hT,'Name',[this.outname,repost,'_partial2'],...
            'SimulinkRate',slrate);
            this.im1=hN.addSignal2('Type',hT,'Name',[this.outname,impost,'_partial1'],...
            'SimulinkRate',slrate);
            this.im2=hN.addSignal2('Type',hT,'Name',[this.outname,impost,'_partial2'],...
            'SimulinkRate',slrate);
        end

    end
