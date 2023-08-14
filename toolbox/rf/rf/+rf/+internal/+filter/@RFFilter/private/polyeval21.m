function ydata=polyeval21(designData,xData)




    omega=2*pi*xData;
    num=designData.Numerator21;
    den=designData.Denominator;
    denEval=polyvalCoeff(den,1i*omega);
    flag=0;
    if isfield(designData,'Auxiliary')
        if isfield(designData.Auxiliary,'Numerator21Polynomial')
            flag=1;
            numEval=polyvalCoeff(designData.Auxiliary.Numerator21Polynomial,...
            1i*omega);
        end
    end

    if~flag||any(isinf(prod(numEval,1)))||any(isinf(prod(denEval,1)))
        numEval=polyvalCoeff(num,1i*omega);
        ydata=prod(numEval./denEval,1);
    else
        ydata=prod(numEval,1)./prod(denEval,1);
    end
end

function values=polyvalCoeff(coeff,x_data)

    func=@(x)polyval(x,x_data);
    if size(coeff,1)==1
        values=func(coeff);
    else
        scell_coeff=mat2cell(coeff,ones(1,size(coeff,1)),size(coeff,2));
        values=cell2mat(cellfun(func,scell_coeff,'UniformOutput',false));
    end
end
