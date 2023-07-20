function hdlcode=emit(this)





    body=[];
    hdlcode=hdlcodeinit;

    outexp=hdlexpandvectorsignal(this.out);

    if this.cplx1&&this.cplx2
        re1exp=hdlexpandvectorsignal(this.re1);
        re2exp=hdlexpandvectorsignal(this.re2);
        im1exp=hdlexpandvectorsignal(this.im1);
        im2exp=hdlexpandvectorsignal(this.im2);

        for ii=1:length(this.in1vec),
            [body1,sigs1]=hdlmultiply(this.in1vec(ii),this.in2vec(ii),re1exp(ii),this.rounding,this.saturation,true);
            [body2,sigs2]=hdlmultiply(hdlsignalimag(this.in1vec(ii)),hdlsignalimag(this.in2vec(ii)),re2exp(ii),this.rounding,this.saturation,true);
            [body3,sigs3]=hdlmultiply(this.in1vec(ii),hdlsignalimag(this.in2vec(ii)),im1exp(ii),this.rounding,this.saturation,true);
            [body4,sigs4]=hdlmultiply(hdlsignalimag(this.in1vec(ii)),this.in2vec(ii),im2exp(ii),this.rounding,this.saturation,true);
            body=[body,body1,body2,body3,body4];
            hdlcode.arch_signals=[hdlcode.arch_signals,sigs1,sigs2,sigs3,sigs4];

            [body1,sigs1]=hdlsub(re1exp(ii),re2exp(ii),outexp(ii),this.rounding,this.saturation);
            [body2,sigs2]=hdladd(im1exp(ii),im2exp(ii),hdlsignalimag(outexp(ii)),this.rounding,this.saturation);
            body=[body,body1,body2];
            hdlcode.arch_signals=[hdlcode.arch_signals,sigs1,sigs2];
        end
    elseif this.cplx1&&~this.cplx2,
        for ii=1:length(this.in1vec),
            body=[body,hdlmultiply(this.in1vec(ii),this.in2vec(ii),outexp(ii),this.rounding,this.saturation,true),...
            hdlmultiply(hdlsignalimag(this.in1vec(ii)),this.in2vec(ii),hdlsignalimag(outexp(ii)),this.rounding,this.saturation,true)];
        end
    elseif this.cplx2&&~this.cplx1,
        for ii=1:length(this.in1vec),
            body=[body,hdlmultiply(this.in1vec(ii),this.in2vec(ii),outexp(ii),this.rounding,this.saturation,true),...
            hdlmultiply(this.in1vec(ii),hdlsignalimag(this.in2vec(ii)),hdlsignalimag(outexp(ii)),this.rounding,this.saturation,true)];
        end
    else
        for ii=1:length(this.in1vec),
            body=[body,hdlmultiply(this.in1vec(ii),this.in2vec(ii),outexp(ii),this.rounding,this.saturation,true)];
        end
    end

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,body];
