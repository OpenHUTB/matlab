function values=polyvalCoeffroots(coeff)




    func=@roots;
    if size(coeff,1)==1
        values=func(coeff);
    else
        scell_coeff=mat2cell(coeff,ones(1,size(coeff,1)),size(coeff,2));
        values=cell2mat(cellfun(func,scell_coeff,'UniformOutput',false));
    end

end
