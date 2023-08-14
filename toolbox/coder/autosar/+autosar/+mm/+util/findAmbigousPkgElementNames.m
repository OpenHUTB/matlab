





function[indexSet1,indexSet2]=findAmbigousPkgElementNames(packages,pkgElements)
    indexSet1={};
    indexSet2={};
    for j=1:length(pkgElements)
        regExpStr=sprintf('^(%s)',pkgElements{j});
        tokens=regexp(packages,regExpStr,'tokens');
        for i=1:length(tokens)
            if~isempty(tokens{i})



                if(length(pkgElements{j})==length(packages{i}))||(packages{i}(length(tokens{i}{1}{1})+1)=='/')
                    indexSet1=[indexSet1,i];%#ok<AGROW>
                    indexSet2=[indexSet2,j];%#ok<AGROW>
                end
            end
        end
    end
end

