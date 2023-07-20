function exportSolutions(solutions)







    for sIndex=1:numel(solutions)


        maxDiffCell={solutions(sIndex).simOut.maxDifferences}';
        maxDiffVec=cellfun(@(x)(max(x)),maxDiffCell);
        solutions(sIndex).maxDifferences=maxDiffVec;


        solutions(sIndex).setPass(all([solutions(sIndex).simOut.pass]));


        solutions(sIndex).setCost(solutions(sIndex).simOut(1).cost);

    end

end

