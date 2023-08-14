function[R,P,K]=simrfV2_filt_polezerores(qZeros,qPoles)























    numberTolDigits=3;
    tol=10^numberTolDigits;


    K=[];

    numCplxPoles=0;
    numRealPoles=0;
    for row_idx=1:size(qPoles,1)
        scl=qPoles(row_idx,find(qPoles(row_idx,:)~=0,1));
        qPoles(row_idx,:)=qPoles(row_idx,:)/scl;
        qZeros(row_idx,:)=qZeros(row_idx,:)/scl;
        poles=roots(qPoles(row_idx,:));
        numRealPoles=numRealPoles+sum(~imag(poles));
        numCplxPoles=numCplxPoles+round(sum(~(~imag(poles)))/2);
    end

    polyZeros=cellfun(@(x)x(find(x~=0,1):end),num2cell(qZeros,2),...
    'UniformOutput',false);
    polyPoles=cellfun(@(x)x(find(x~=0,1):end),num2cell(qPoles,2),...
    'UniformOutput',false);
    rowsQpoles=size(qPoles,1);
    lenPolyZeros=sum(cellfun(@length,polyZeros))-rowsQpoles;
    lenPolyPoles=sum(cellfun(@length,polyPoles))-rowsQpoles;
    if lenPolyZeros==lenPolyPoles


        K=prod(cellfun(@(x,y)x(1)/y(1),polyZeros,polyPoles));
    elseif lenPolyZeros>lenPolyPoles

        error('Current filter design invalid: Order(num)>Order(den)')
    end

    R=NaN(numCplxPoles+numRealPoles,1);
    P=R;
    poleResIdxReal=numCplxPoles+1;
    poleResIdxCplx=0;
    for row_idx=1:rowsQpoles
        poles=sort(roots(qPoles(row_idx,:)),'descend',...
        'ComparisonMethod','real');
        num_poles=size(poles,1);
        num_real=sum(~imag(poles));
        num_cplx=num_poles-num_real;
        if num_cplx>1

            validateattributes(...
            abs(real(poles(1:2:num_cplx))-real(poles(2:2:num_cplx)))<...
            tol*eps(max(abs(real(poles(1:2:num_cplx))),...
            abs(real(poles(2:2:num_cplx))))),...
            {'logical'},{'nonzero'},mfilename,...
            'number of complex poles of the rational function')



            validateattributes(...
            abs(imag(poles(1:2:num_cplx,:))+imag(poles(2:2:num_cplx,:)))<...
            tol*eps(max(abs(imag(poles(1:2:num_cplx,:))),...
            abs(imag(poles(2:2:num_cplx,:))))),...
            {'logical'},{'nonzero'},mfilename,...
            'complex conjugate poles of the rational function')




            polesSecondQuad=poles(1:2:end);
            RHS=ones(round(num_cplx/2,0),1);
            for n_idx=1:rowsQpoles
                if row_idx~=n_idx
                    denRHS=polyval(qPoles(n_idx,:),polesSecondQuad);
                elseif size(polesSecondQuad,1)==1
                    denRHS=(2i*imag(polesSecondQuad));
                else
                    denPart=[ones(2,1),(-2*real(polesSecondQuad))...
                    ,abs(polesSecondQuad).^2];
                    denRHS=([polyval(denPart(2,:),polesSecondQuad(1));...
                    polyval(denPart(1,:),polesSecondQuad(2))]).*...
                    (2i*imag(polesSecondQuad));
                end
                numRHS=polyval(qZeros(n_idx,:),polesSecondQuad);
                RHS=(numRHS./denRHS).*RHS;
            end
            idxEnd=poleResIdxCplx+round(num_cplx/2,0);

            R(poleResIdxCplx+1:idxEnd)=2*RHS;
            P(poleResIdxCplx+1:idxEnd)=polesSecondQuad;
            poleResIdxCplx=poleResIdxCplx+round(num_cplx/2,0);
        elseif num_real>0
            realPoles=poles(~imag(poles));
            numRePoles=size(realPoles,1);
            RHS=ones(numRePoles,1);
            for n_idx=1:rowsQpoles
                if n_idx~=row_idx
                    denRHS=polyval(qPoles(n_idx,:),realPoles);
                elseif numRePoles==1
                    denRHS=1;
                else
                    denRHS=ones(numRePoles,1);
                    for p_idx=1:numRePoles
                        denRHS(p_idx)=prod(realPoles(p_idx)-...
                        realPoles([1:(p_idx-1),(p_idx+1):numRePoles]));
                    end
                end
                numRHS=polyval(qZeros(n_idx,:),realPoles);
                RHS=(numRHS./denRHS).*RHS;
            end
            R(poleResIdxReal:poleResIdxReal+numRePoles-1)=RHS;
            P(poleResIdxReal:poleResIdxReal+numRePoles-1)=realPoles;
            poleResIdxReal=poleResIdxReal+numRePoles;
        else

            error('Current filter design invalid: Order(num)>Order(den)')
        end
    end
end