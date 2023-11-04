function v=eml_al_cordic_rotate(theta,u,numIters,inputLUT,doOutputScaling,inputInvGC)

%#codegen

    coder.allowpcode('plain');

    eml_prefer_const(theta);
    eml_prefer_const(u);
    eml_prefer_const(numIters);
    eml_prefer_const(doOutputScaling);
    eml_prefer_const(inputLUT);
    eml_prefer_const(inputInvGC);


    if isfi(theta)
        lengthOfThetaArray=numberofelements(theta);
    else
        lengthOfThetaArray=numel(theta);
    end

    if isfi(u)
        lengthOfUArray=numberofelements(u);
    else
        lengthOfUArray=numel(u);
    end

    isThetaNonScalar=(lengthOfThetaArray>1);
    is_U_NonScalar=(lengthOfUArray>1);


    if is_U_NonScalar
        outLen=lengthOfUArray;
        sz=size(u);
    else
        outLen=lengthOfThetaArray;
        sz=size(theta);
    end

    if isa(u,'double')

        lut=inputLUT;
        invGC=inputInvGC;


        v=coder.nullcopy(complex(zeros(sz),zeros(sz)));

    elseif isa(u,'single')

        lut=inputLUT;
        invGC=inputInvGC;


        v=coder.nullcopy(single(complex(zeros(sz),zeros(sz))));
    end

    if~isfloat(u)


        [xyWL,xyFL,xyFm]=localGetU_XY_FixptAttribs(u);


        tNT=eml_al_numerictype(theta);
        zWL=tNT.WordLength;
        zNT=numerictype(numerictype(1,zWL,(zWL-2)),'DataType',tNT.DataType);
        lut=fi(inputLUT,zNT,eml_al_cordic_fimath(theta));



        gcNT=numerictype(inputInvGC);
        invGC=fi(inputInvGC,gcNT,xyFm);


        if(isfi(u)&&isscaleddouble(u))||(isfi(theta)&&isscaleddouble(theta))
            xyNT=numerictype(...
            'Signedness','Signed',...
            'WordLength',xyWL,...
            'FractionLength',xyFL,...
            'DataTypeMode','Scaled double: binary point scaling');
        else
            xyNT=numerictype(1,xyWL,xyFL);
        end

        v=coder.nullcopy(fi(complex(zeros(sz),zeros(sz)),xyNT));
    end





    if(lengthOfThetaArray==1)

        [negate,z0]=localQuadCorrBeforeCORDIC(theta,lut);
    end

    if(lengthOfUArray==1)

        if isfloat(u)
            [x0,y0]=localInitNextXYFloat(u);
        else
            [x0,y0]=localInitNextXYFixpt(u,xyNT,xyFm);
        end
    end

    for idx=1:outLen
        if isThetaNonScalar

            [negate,z0]=localQuadCorrBeforeCORDIC(theta(idx),lut);
        end

        if is_U_NonScalar

            if isfloat(u)
                [x0,y0]=localInitNextXYFloat(u(idx));
            else
                [x0,y0]=localInitNextXYFixpt(u(idx),xyNT,xyFm);
            end
        end


        [xn,yn]=fixed.internal.cordic_rotation_kernel_private(x0,y0,z0,lut,numIters);
        [xout,yout]=eml_al_cordic_quad_correction_after(xn,yn,negate);


        if doOutputScaling
            xout_scaled=xout.*invGC;
            yout_scaled=yout.*invGC;
            v(idx)=complex(xout_scaled,yout_scaled);
        else

            if isfi(v)
                v_XY_Fm=fi(complex(xout,yout),xyNT,xyFm);
                v(idx)=v_XY_Fm;
            else
                v(idx)=complex(xout,yout);
            end
        end
    end
end


function[negate,z0]=localQuadCorrBeforeCORDIC(theta,lut)

    eml_prefer_const(theta,lut);
    if isfloat(theta)
        [negate,z0]=...
        eml_al_cordic_quad_correction_before_float(theta);
    else
        [negate,z0]=...
        eml_al_cordic_quad_correction_before(theta,lut);
    end
end


function[x0,y0]=localInitNextXYFloat(u)
    eml_prefer_const(u);
    if isreal(u)


        x0=u;
        if isa(u,'double')
            y0=0;
        else
            y0=single(0);
        end
    else

        x0=real(u);
        y0=imag(u);
    end
end


function[x0,y0]=localInitNextXYFixpt(u,xyNT,xyFm)

    eml_prefer_const(u,xyNT,xyFm);
    uLclFm=fi(u,xyNT,xyFm);
    if isreal(uLclFm)


        x0=fi(uLclFm,xyNT,xyFm);
        y0=fi(0,xyNT,xyFm);
    else

        x0=fi(real(uLclFm),xyNT,xyFm);
        y0=fi(imag(uLclFm),xyNT,xyFm);
    end
end


function[xyWL,xyFL,xyFm]=localGetU_XY_FixptAttribs(u)


    eml_prefer_const(u);
    if isinteger(u)
        switch class(u)
        case 'int8'
            uWL=8;isUnsUInput=0;
        case 'uint8'
            uWL=8;isUnsUInput=1;
        case 'int16'
            uWL=16;isUnsUInput=0;
        case 'uint16'
            uWL=16;isUnsUInput=1;
        case 'int32'
            uWL=32;isUnsUInput=0;
        case 'uint32'
            uWL=32;isUnsUInput=1;
        case 'int64'
            uWL=64;isUnsUInput=0;
        otherwise
            uWL=64;isUnsUInput=1;
        end
        xyFL=0;
    else

        isUnsUInput=double((~isfloat(u))&&(~issigned(u)));
        uNT=eml_al_numerictype(u);
        uWL=uNT.WordLength;
        xyFL=uNT.FractionLength;
    end





    xyWL=uWL+2+isUnsUInput;
    xyFm=fimath(...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',xyWL,...
    'ProductFractionLength',xyFL,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',xyWL,...
    'SumFractionLength',xyFL,...
    'RoundMode','floor',...
    'OverflowMode','wrap'...
    );

end
