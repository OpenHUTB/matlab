function gTruthMed=readGTruthMedicalFromMATFile(filename)




    if~isfile(filename)
        error(message('medical:medicalLabeler:invalidMATFile'))
    end

    try

        m=matfile(filename);
        vars=whos(m);

        if isempty(vars)

            error(message('medical:medicalLabeler:noGTruthMedCandidates'));

        else

            numberofCandidates=0;

            for idx=1:numel(vars)

                if isequal(vars(idx).class,'groundTruthMedical')

                    if numberofCandidates==0

                        numberofCandidates=numberofCandidates+1;
                        varname=vars(idx).name;

                    else



                        error(message('medical:medicalLabeler:multipleGTruthMedCandidates'));
                    end

                end

            end

            if numberofCandidates==0


                error(message('medical:medicalLabeler:noGTruthMedCandidates'));
            end

        end


        gTruthMed=eval(['m.',varname]);%#ok<EVLDOT> 

    catch ME
        throw(ME);
    end

end
