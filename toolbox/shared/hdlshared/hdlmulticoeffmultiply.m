function[optr,body,signals,tempsigs,typedefs]=hdlmulticoeffmultiply(iptr,coeff,coeffptr,selector,valarray,name,vtype,sltype,rounding,sat,accumsltype)







    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    typedefs={};
    if nargin<11
        accumsltype='';
    end
    numcoeff=length(coeff);
    if length(coeff)==1
        [optr,body,signals,tempsigs]=hdlcoeffmultiply(iptr,coeff,coeffptr,name,vtype,sltype,rounding,sat,accumsltype);
    else

        body='';
        signals='';
        tempsigs='';

        prodcplxty=hdlsignaliscomplex(iptr)||~isreal(coeff);


        if~strcmpi(vtype,'real')&&strcmpi(hdlgetparameter('filter_multipliers'),'factored-csd')||strcmpi(hdlgetparameter('filter_multipliers'),'csd')





            mtypedefs=[];
            for k=1:numcoeff
                [optrtemp(k),bodytemp,signalstemp,tempsigstemp,mtypedefs]=hdlcoeffmultiply(iptr,coeff(k),coeffptr(k),name,vtype,sltype,rounding,sat,accumsltype);
                body=[body,bodytemp];
                signals=[signals,signalstemp];
                tempsigs=[tempsigs,tempsigstemp];
                if optrtemp(k)==0
                    optrtemp(k)=coeffptr(k);
                end
            end
            typedefs=[typedefs,mtypedefs];

            if hdlsignaliscomplex(iptr)&&~all(cell2mat(hdlsignalcomplex(coeffptr)))&&any(cell2mat(hdlsignalcomplex(coeffptr)))



                for nn=1:length(optrtemp)
                    if~hdlsignaliscomplex(coeffptr(nn))
                        accum_all=hdlgetallfromsltype(accumsltype);
                        [~,optr_cast]=hdlnewsignal(name,'filter',-1,hdlsignaliscomplex(optrtemp(nn)),0,accum_all.vtype,accum_all.sltype);
                        signals=[signals,makehdlsignaldecl(optr_cast)];
                        body=[body,hdldatatypeassignment(optrtemp(nn),optr_cast,rounding,sat)];
                        optrtemp(nn)=optr_cast;
                    end
                end
            end
            oput_all=hdlgetallfromsltype(hdlsignalsltype(optrtemp(1)));
            [~,optr]=hdlnewsignal(name,'filter',-1,prodcplxty,0,oput_all.vtype,oput_all.sltype);
            signals=[signals,makehdlsignaldecl(optr)];
            tempbody=hdlmux(optrtemp(1:numcoeff),optr,selector,{'='},valarray,'when-else');

            if hdlsignaliscomplex(optr)&&~all(cell2mat(hdlsignalcomplex(optrtemp(1:numcoeff))))



                [signalstemp,bodytemp]=localMuxforImag(optrtemp(1:numcoeff),optr,selector,{'='},valarray,'when-else');
                signals=[signals,signalstemp];
                body=[body,bodytemp];
            end

            body=[body,tempbody];
        else

            if~isreal(coeff)
                muxcplxty=1;
            else
                muxcplxty=0;
            end






            optrtemp_all=hdlgetallfromsltype(hdlsignalsltype(coeffptr(1)));
            [~,optrtemp]=hdlnewsignal([name,'_mux'],'filter',-1,muxcplxty,0,...
            optrtemp_all.vtype,hdlsignalsltype(coeffptr(1)));
            tempsigs=[tempsigs,makehdlsignaldecl(optrtemp)];

            if emitMode
                bodytemp=hdlmux(coeffptr(1:numcoeff),optrtemp,selector,{'='},valarray,'when-else');
                body=[body,bodytemp];
            else
                [~,coeff_vect]=hdlnewsignal('coeff_vector','filter',-1,...
                muxcplxty,length(1:numcoeff),optrtemp_all.vtype,hdlsignalsltype(coeffptr(1)));

                pirelab.getMuxComp(hN,coeffptr(1:numcoeff),coeff_vect);

                pirelab.getSerializerComp(hN,coeff_vect,optrtemp);

                optrtemp.SimulinkRate=coeffptr(1).SimulinkRate/length(1:numcoeff);
            end



            if hdlsignaliscomplex(optrtemp)&&~all(cell2mat(hdlsignalcomplex(coeffptr(1:numcoeff))))



                [signalstemp,bodytemp]=localMuxforImag(coeffptr(1:numcoeff),optrtemp,selector,{'='},valarray,'when-else');
                signals=[signals,signalstemp];
                body=[body,bodytemp];
            end
            if hdlsignaliscomplex(iptr)


                if hdlsignaliscomplex(optrtemp)
                    ccmult=hdl.spblkmultiply(...
                    'in1',iptr,...
                    'in2',optrtemp,...
                    'outname',name,...
                    'product_sltype',sltype,...
                    'accumulator_sltype',accumsltype,...
                    'rounding',rounding,...
                    'saturation',sat...
                    );

                    ccmultcode=ccmult.emit;
                    body=[body,ccmultcode.arch_body_blocks];
                    optr=ccmult.out;
                    signals=[signals,makehdlsignaldecl(ccmult.out),...
                    makehdlsignaldecl(ccmult.re1),...
                    makehdlsignaldecl(ccmult.re2),...
                    makehdlsignaldecl(ccmult.im1),...
                    makehdlsignaldecl(ccmult.im2)];
                    tempsigs=[tempsigs,ccmultcode.arch_signals];
                else



                    tempcoeff=(0.234543);
                    [optr,bodytemp,signalstemp,tempsigs1,~]=hdlcoeffmultiply(iptr,tempcoeff,...
                    optrtemp,name,vtype,sltype,rounding,sat,accumsltype);
                    body=[body,bodytemp];
                    tempsigs=[signalstemp,tempsigs,tempsigs1];
                end
            else



                coeffcplxity=hdlsignaliscomplex(optrtemp);
                if coeffcplxity
                    tempcoeff=(0.234543+1i*0.5235);
                else
                    tempcoeff=(0.234543);
                end
                [optr,bodytemp,signalstemp,tempsigs1,mtypedefs]=hdlcoeffmultiply(iptr,tempcoeff,...
                optrtemp,name,vtype,sltype,rounding,sat,accumsltype);
                body=[body,bodytemp];
                tempsigs=[signalstemp,tempsigs,tempsigs1];
                typedefs=[typedefs,mtypedefs];
            end
        end
    end

    function[constdecl,bodytemp]=localMuxforImag(inputsptrs,optr,selector,cmpstr,valarray,formatstr)



        constdecl='';
        for nn=1:length(inputsptrs)
            if hdlsignaliscomplex(inputsptrs(nn))
                inputsptrs(nn)=hdlsignalimag(inputsptrs(nn));
            else
                inim_all=hdlgetallfromsltype(hdlsignalsltype(inputsptrs(nn)));
                [~,constzro]=hdlnewsignal('const_zero_im','filter',-1,0,0,...
                inim_all.vtype,inim_all.sltype);
                inputsptrs(nn)=constzro;
                constdecl=[constdecl,...
                makehdlconstantdecl(constzro,hdlconstantvalue(0,inim_all.size,inim_all.bp,1))];
            end
        end
        bodytemp=hdlmux(inputsptrs,hdlsignalimag(optr),selector,cmpstr,valarray,formatstr);

