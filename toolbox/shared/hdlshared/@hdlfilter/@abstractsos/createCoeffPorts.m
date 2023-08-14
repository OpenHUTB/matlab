function entitysigs=createCoeffPorts(this,entitysigs)




    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    coeffs=this.Coefficients;
    num=coeffs(1:3);
    den=coeffs(4:6);

    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    numcoeffssltype=numcoeffall.sltype;

    dencoeffall=hdlgetallfromsltype(this.dencoeffSLtype);
    dencoeffssltype=dencoeffall.sltype;

    if emitMode
        if hdlgetparameter('isvhdl')
            numcoeffsvtype=this.coeffvectorvtype{1};
            dencoeffsvtype=this.coeffvectorvtype{2};
        else
            numcoeffsvtype=numcoeffall.vtype;
            dencoeffsvtype=dencoeffall.vtype;
        end

        if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)

            cplxty_num=~isreal(num);
            coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_num']);
            [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_num,...
            [3,0],numcoeffsvtype,numcoeffssltype);
            hdladdinportsignal(ptr);
            num_list=hdlexpandvectorsignal(ptr);


            cplxty_den=~isreal(den);
            coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_den']);
            [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_den,...
            [2,0],dencoeffsvtype,dencoeffssltype);
            hdladdinportsignal(ptr);
            den_list=hdlexpandvectorsignal(ptr);

            entitysigs.coeffs=[num_list,0,den_list];
        else

            num_list=[];
            for n=1:3
                cplxty_num=~isreal(num(n));
                coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_num',num2str(n)]);
                [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_num,0,numcoeffsvtype,numcoeffssltype);
                hdladdinportsignal(ptr)
                num_list=[num_list,ptr];
            end


            den_list=[0];
            for n=2:3
                cplxty_den=~isreal(den(n));
                coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_den',num2str(n)]);
                [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_den,0,dencoeffsvtype,dencoeffssltype);
                hdladdinportsignal(ptr)
                den_list=[den_list,ptr];
            end

            entitysigs.coeffs=[num_list,den_list];
        end


        if hdlgetparameter('filter_generate_biquad_scale_port')
            scales=this.ScaleValues;
            scalesall=hdlgetallfromsltype(this.scaleSLtype);
            scalessltype=scalesall.sltype;
            if hdlgetparameter('isvhdl')
                scalesvtype=this.coeffvectorvtype{3};
            else
                scalesvtype=scalesall.vtype;
            end

            if hdlgetparameter('isvhdl')&&~hdlgetparameter('scalarizePorts')
                cplxty_scale=~isreal(scales);
                coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_g']);
                [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_scale,...
                [2,0],scalesvtype,scalessltype);
                hdladdinportsignal(ptr);
                scale_list=hdlexpandvectorsignal(ptr);
            else
                scale_list=[];
                for n=1:2
                    cplxty_scale=~isreal(scales(n));
                    coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_g',num2str(n)]);
                    [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_scale,0,scalesvtype,scalessltype);
                    hdladdinportsignal(ptr)
                    scale_list=[scale_list,ptr];
                end
            end
            entitysigs.coeffs=[entitysigs.coeffs,scale_list];
        end
    else
        num_list=hdlexpandvectorsignal(hN.PirInputSignals(2));
        den_list=hdlexpandvectorsignal(hN.PirInputSignals(3));
        dummySignal=hN.addSignal(num_list(1).Type,'DummySignal');
        entitysigs.coeffs=[num_list.',dummySignal,den_list.'];
        if hdlgetparameter('filter_generate_biquad_scale_port')
            scale_list=hdlexpandvectorsignal(hN.PirInputSignals(4));
            entitysigs.coeffs=[entitysigs.coeffs,scale_list.'];
        end
    end