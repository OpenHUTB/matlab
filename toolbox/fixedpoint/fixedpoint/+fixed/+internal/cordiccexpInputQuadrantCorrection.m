function[theta_in_range,needToNegate]=cordiccexpInputQuadrantCorrection(theta_input)



%#codegen
    coder.allowpcode('plain');
    if coder.internal.isAmbiguousTypes()
        theta_in_range=zeros(size(theta_input));
        needToNegate=zeros(size(theta_input));
        return
    end

    theta=upcastInput(theta_input);
    needToNegate=false(size(theta));

    if isfi(theta)&&isfixed(theta)&&...
        ((theta.WordLength-theta.FractionLength-issigned(theta))<=0)


        theta_in_range=theta;
        return;
    end


    [theta_in_range,piOver2,onePi,twoPi]=initialize_variables(theta);

    for idx=1:numel(theta)
        thetaMinusOnePi=theta(idx)-onePi;
        thetaPlusOnePi=theta(idx)+onePi;
        thetaMinusTwoPi=theta(idx)-twoPi;
        thetaPlusTwoPi=theta(idx)+twoPi;
        if cast(theta(idx),'like',piOver2)>piOver2


            if(thetaMinusOnePi<=piOver2)

                theta_in_range(idx)=thetaMinusOnePi;
                needToNegate(idx)=1;
            else

                theta_in_range(idx)=thetaMinusTwoPi;
            end

        elseif(cast(theta(idx),'like',piOver2)<-piOver2)


            if(thetaPlusOnePi>=-piOver2)

                theta_in_range(idx)=thetaPlusOnePi;
                needToNegate(idx)=1;
            else

                theta_in_range(idx)=thetaPlusTwoPi;
            end
        else

            theta_in_range(idx)=theta(idx);
        end
    end
    theta_in_range=removefimath(theta_in_range);
end

function[theta_in_range,piOver2,onePi,twoPi]=initialize_variables(theta)

    if isfloat(theta)

        theta_in_range=zeros(size(theta),'like',theta);
        piOver2=cast(pi/2,'like',theta);
        onePi=cast(pi,'like',theta);
        twoPi=cast(2*pi,'like',theta);

    else



        theta=fi(theta);



        wordLength=max(16,theta.WordLength);
        theta_in_range=fi(zeros(size(theta)),1,wordLength,wordLength-2);



        twoPi=fi(2*pi,1,wordLength);
        onePi=cast(pi,'like',twoPi);
        piOver2=cast(pi/2,'like',twoPi);
    end



    theta_in_range=setfimath(theta_in_range,fixed.fimathLike(theta_in_range));
    twoPi=setfimath(twoPi,fixed.fimathLike(twoPi));
    onePi=setfimath(onePi,fixed.fimathLike(onePi));
    piOver2=setfimath(piOver2,fixed.fimathLike(piOver2));
end

function theta=upcastInput(theta_input0)

    theta_input1=integerToFi(theta_input0);
    theta_input2=upcastUnsignedToSigned(theta_input1);
    theta=moveFractionLengthUp(theta_input2);
    theta=removefimath(theta);
end
function theta_input1=integerToFi(theta_input0)
    if isinteger(theta_input0)

        theta_input1=fi(theta_input0);
    else
        theta_input1=theta_input0;
    end
end
function theta_input2=upcastUnsignedToSigned(theta_input1)

    if isfi(theta_input1)&&isscaledtype(theta_input1)&&~issigned(theta_input1)

        if(theta_input1.WordLength-theta_input1.FractionLength)<=3



            theta_input2=fi(theta_input1,1,theta_input1.WordLength+1,theta_input1.FractionLength,'DataType',theta_input1.DataType);
        else



            theta_input2=fi(theta_input1,1,theta_input1.WordLength,theta_input1.FractionLength,'DataType',theta_input1.DataType);
        end
    else
        theta_input2=theta_input1;
    end
end
function theta=moveFractionLengthUp(theta_input2)

    if isfi(theta_input2)&&isscaledtype(theta_input2)&&((theta_input2.WordLength-theta_input2.FractionLength)>4)



        theta=fi(theta_input2,1,theta_input2.WordLength,theta_input2.WordLength-4,'DataType',theta_input2.DataType);
    else
        theta=theta_input2;
    end
end