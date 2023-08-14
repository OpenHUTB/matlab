function hdlcode=emit(this,in,out,varargin)



















    hdlcode=hdlcodeinit;
    body='';
    signals='';



    body=[];

    saturate=false;
    rounding='floor';
    num_optargin=size(varargin,2);
    switch num_optargin,
    case 1,
        saturate=varargin{1};
    case 2,
        rounding=varargin{1};
        saturate=varargin{2};
    end



    if nargin<4,
        saturate=false;
    end

    inreal=~(hdlsignaliscomplex(in));
    outreal=~(hdlsignaliscomplex(out));


    body=[body,hdldatatypeassignment(in,out,rounding,saturate,[],'real')];

    [outWL,outBP,outSIGNED]=hdlgetsizesfromtype(hdlsignalsltype(out));


    if~outreal,
        outimag=hdlsignalimag(out);
        if inreal,






            body=[body,hdlvectorconstantassign(outimag,0)];
        else

            inimag=hdlsignalimag(in);
            expand_inimag=hdlexpandvectorsignal(inimag);
            expand_outimag=hdlexpandvectorsignal(outimag);
            for ii=1:length(expand_inimag);
                body=[body,hdlunaryminus(expand_inimag(ii),expand_outimag(ii),rounding,saturate)];
            end
        end
    end




    hdlcode.arch_signals=[hdlcode.arch_signals,signals];
    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,body];


