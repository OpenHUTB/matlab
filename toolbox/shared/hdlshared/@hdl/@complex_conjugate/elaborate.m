function elaborate(this,hN,slrate,in,out,varargin)%#ok<INUSL>



























    saturate=false;
    rounding='floor';
    num_optargin=size(varargin,2);
    switch num_optargin
    case 1
        saturate=varargin{1};
    case 2
        rounding=varargin{1};
        saturate=varargin{2};
    end

    if nargin<4
        saturate=false;
    end


    isinvec=hdlissignalvector(in);
    vecSize=hdlsignalvector(in);
    if isinvec
        hT=in.Type.BaseType.BaseType;
    else
        hT=in.Type.BaseType;
    end
    hTVec=pirelab.getPirVectorType(hT,vecSize);


    isinreal=~(hdlsignaliscomplex(in));
    isoutreal=~(hdlsignaliscomplex(out));

    if~isinreal
        in_re=hN.addSignal2('Type',hTVec,'Name',[in.Name,'_re'],...
        'SimulinkRate',slrate);
        in_im=hN.addSignal2('Type',hTVec,'Name',[in.Name,'_im'],...
        'SimulinkRate',slrate);
        pirelab.getComplex2RealImag(hN,in,[in_re,in_im]);
    else
        in_re=in;
    end
    if~isoutreal
        out_re=hN.addSignal2('Type',hTVec,'Name',[out.Name,'_re'],...
        'SimulinkRate',slrate);
        out_im=hN.addSignal2('Type',hTVec,'Name',[out.Name,'_im'],...
        'SimulinkRate',slrate);

        pirelab.getRealImag2Complex(hN,[out_re,out_im],out);
    else
        out_re=out;
    end


    pirelab.getDTCComp(hN,in_re,out_re,rounding,saturate);




    if~isoutreal

        if isinreal

            pirelab.getConstComp(hN,out_im,0);
        else







            pirelab.getUnaryMinusComp(hN,in_im,out_im,saturate);
        end
    end

end


