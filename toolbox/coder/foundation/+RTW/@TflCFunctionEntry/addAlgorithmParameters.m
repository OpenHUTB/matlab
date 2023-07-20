
function h=addAlgorithmParameters(h,algPropertyList)




    apset=h.getAlgorithmParameters();


    for i=1:length(algPropertyList)
        apset.(algPropertyList{i}{1})=algPropertyList{i}{2};
    end


    h.setAlgorithmParameters(apset);
end
