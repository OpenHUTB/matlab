function[sections_arch,num_list,den_list,scaled_input]=emit_coefficients(this,sections_arch,current_input,section,scaleresultall)






    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    scales=this.ScaleValues;
    coeffs=this.Coefficients;

    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffsvsize=numcoeffall.size;
    numcoeffsvbp=numcoeffall.bp;
    coeffssigned=numcoeffall.signed;

    numcoeffsvtype=numcoeffall.vtype;
    numcoeffssltype=numcoeffall.sltype;

    dencoeffall=hdlgetallfromsltype(this.dencoeffSLtype);
    dencoeffsvbp=dencoeffall.bp;
    dencoeffsvtype=dencoeffall.vtype;
    dencoeffssltype=dencoeffall.sltype;


    [num,den]=getcoeffs(coeffs,section);


    if emitMode
        numChannels=0;
    else
        numChannels=current_input.Type.getDimensions;
    end




    if isempty(scales)||section>length(scales)||scales(section)==1

        scaled_input=current_input;

    else

        [sections_arch,scaled_input]=emit_scaleinput(this,sections_arch,current_input,section);
    end



    num_list=[];
    for n=1:length(num)
        cplxty_num=any(imag(num(n)));
        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section)]);
        [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_num,numChannels,numcoeffsvtype,numcoeffssltype);
        num_list=[num_list,ptr];
        if emitMode
            if cplxty_num
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(ptr,hdlconstantvalue(real(num(n)),coeffsvsize,numcoeffsvbp,coeffssigned))];
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(hdlsignalimag(ptr),hdlconstantvalue(imag(num(n)),coeffsvsize,numcoeffsvbp,coeffssigned))];
            else
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(ptr,hdlconstantvalue(num(n),coeffsvsize,numcoeffsvbp,coeffssigned))];
            end
        else
            pirelab.getConstComp(hN,ptr,repmat(num(n),numChannels,1));
        end
    end

    if emitMode
        den_list=[0];
    else
        cplxty_den=any(imag(den(n)));
        [~,dummy_ptr]=hdlnewsignal('Dummy','filter',-1,cplxty_den,numChannels,dencoeffsvtype,dencoeffssltype);
        den_list=dummy_ptr;
    end

    for n=2:length(den)
        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section)]);
        cplxty_den=any(imag(den(n)));
        [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_den,numChannels,dencoeffsvtype,dencoeffssltype);
        den_list=[den_list,ptr];
        if emitMode
            if cplxty_den
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(ptr,hdlconstantvalue(real(den(n)),coeffsvsize,dencoeffsvbp,coeffssigned))];
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(hdlsignalimag(ptr),hdlconstantvalue(imag(den(n)),coeffsvsize,dencoeffsvbp,coeffssigned))];

            else
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(ptr,hdlconstantvalue(den(n),coeffsvsize,dencoeffsvbp,coeffssigned))];
            end
        else
            pirelab.getConstComp(hN,ptr,repmat(den(n),numChannels,1));
        end
    end


    function[num,den]=getcoeffs(coeffs,section)
        num=coeffs(section,1:3);
        den=coeffs(section,4:6);


