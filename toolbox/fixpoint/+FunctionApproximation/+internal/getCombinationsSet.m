function combinationsSet=getCombinationsSet(allCombinations,setSize)



    combinationsSet=cell(1,ceil(numel(allCombinations)/setSize));
    if~isempty(allCombinations)
        ub=0;
        for ii=1:(numel(combinationsSet)-1)
            lb=(ii-1)*setSize+1;
            ub=ii*setSize;
            combinationsSet{ii}=allCombinations(lb:ub);
        end
        combinationsSet{end}=allCombinations(ub+1:end);
    end
end
