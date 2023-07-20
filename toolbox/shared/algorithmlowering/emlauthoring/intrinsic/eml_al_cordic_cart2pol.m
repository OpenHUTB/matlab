function[theta,r]=eml_al_cordic_cart2pol(x,y,numIters,inputLUT,doOutputScaling,inputInvGC)



%#codegen

    coder.allowpcode('plain');

    eml_prefer_const(x);
    eml_prefer_const(y);
    eml_prefer_const(numIters);
    eml_prefer_const(inputLUT);
    eml_prefer_const(doOutputScaling);
    eml_prefer_const(inputInvGC);


    if isfi(x)
        lengthOfXArray=numberofelements(x);
    else
        lengthOfXArray=numel(x);
    end

    if isfi(y)
        lengthOfYArray=numberofelements(y);
    else
        lengthOfYArray=numel(y);
    end

    is_X_NonScalar=(lengthOfXArray>1);
    is_Y_NonScalar=(lengthOfYArray>1);


    if is_Y_NonScalar
        outLen=lengthOfYArray;
        sz=size(y);
    else
        outLen=lengthOfXArray;
        sz=size(x);
    end

    if isa(y,'double')
        zero_of_z_type=0;
        pi_of_z_type=pi;
        lut=inputLUT;
        theta=coder.nullcopy(zeros(sz));
        r=coder.nullcopy(zeros(sz));
        xAcc=double(0);
        yAcc=double(0);
        if doOutputScaling
            invGC=inputInvGC;
        end

    elseif isa(y,'single')
        zero_of_z_type=single(0);
        pi_of_z_type=single(pi);
        lut=inputLUT;
        theta=coder.nullcopy(single(zeros(sz)));
        r=coder.nullcopy(single(zeros(sz)));
        xAcc=single(0);
        yAcc=single(0);
        if doOutputScaling
            invGC=inputInvGC;
        end

    end

    if~isfloat(y)


        [zNT,zFm,xyNT,xyAccFm]=localGetXYZFixptAttribs(y);


        zero_of_z_type=fi(0,zNT);
        pi_of_z_type=fi(pi,zNT);
        lut=fi(inputLUT,zNT,zFm);
        theta=coder.nullcopy(fi(zeros(sz),zNT));


        xAcc=fi(0,xyNT,xyAccFm);
        yAcc=fi(0,xyNT,xyAccFm);
        r=coder.nullcopy(fi(zeros(sz),xyNT));

        if doOutputScaling


            gcNT=numerictype(inputInvGC);
            invGC=fi(inputInvGC,gcNT,xyAccFm);
        end
    end





    if(lengthOfYArray==1)
        if y<0











            yAcc(:)=-cast(y,'like',yAcc);y_quad_adjust=true;y_nonzero=true;
        else
            yAcc(:)=y;y_quad_adjust=false;y_nonzero=(y>0);
        end
    end

    if(lengthOfXArray==1)
        if x<0
            xAcc(:)=-cast(x,'like',xAcc);x_quad_adjust=true;
        else
            xAcc(:)=x;x_quad_adjust=false;
        end
    end

    for idx=1:outLen
        if is_Y_NonScalar
            y_idx=y(idx);
            if y_idx<0
                yAcc(:)=-cast(y_idx,'like',yAcc);y_quad_adjust=true;y_nonzero=true;
            else
                yAcc(:)=y_idx;y_quad_adjust=false;y_nonzero=(y_idx>0);
            end
        end

        if is_X_NonScalar
            x_idx=x(idx);
            if x_idx<0
                xAcc(:)=-cast(x_idx,'like',xAcc);x_quad_adjust=true;
            else
                xAcc(:)=x_idx;x_quad_adjust=false;
            end
        end



        [xN,~,zN]=...
        fixed.internal.cordic_vectoring_kernel_private(xAcc,yAcc,zero_of_z_type,...
        lut,numIters);

        if doOutputScaling

            rPrdFm=xN.*invGC;
            r(idx)=rPrdFm;
        else

            r(idx)=xN;
        end

        if y_nonzero


            if x_quad_adjust
                if y_quad_adjust
                    theta(idx)=zN-pi_of_z_type;
                else
                    theta(idx)=pi_of_z_type-zN;
                end
            else
                if y_quad_adjust
                    theta(idx)=-zN;
                else
                    theta(idx)=zN;
                end
            end
        elseif x_quad_adjust


            theta(idx)=pi_of_z_type;
        else


            theta(idx)=zero_of_z_type;
        end
    end

end


function[zNT,zFm,xyNT,xyFm]=localGetXYZFixptAttribs(u)


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


    zWL=uWL;
    if isUnsUInput
        zFL=zWL-2;
    else
        zFL=zWL-3;
    end
    if isfi(u)&&isscaleddouble(u)
        zNT=numerictype(...
        'Signedness','Signed',...
        'WordLength',zWL,...
        'FractionLength',zFL,...
        'DataTypeMode','Scaled double: binary point scaling');
    else
        zNT=numerictype(1,zWL,zFL);
    end
    zFm=fimath(...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',zWL,...
    'ProductFractionLength',zFL,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',zWL,...
    'SumFractionLength',zFL,...
    'RoundMode','floor',...
    'OverflowMode','wrap');





    xyWL=uWL+2+isUnsUInput;
    if isfi(u)&&isscaleddouble(u)
        xyNT=numerictype(...
        'Signedness','Signed',...
        'WordLength',xyWL,...
        'FractionLength',xyFL,...
        'DataTypeMode','Scaled double: binary point scaling');
    else
        xyNT=numerictype(1,xyWL,xyFL);
    end
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
