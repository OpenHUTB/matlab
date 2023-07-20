function[success]=saveExclusion(this,filename)




    try


        exclusion.ExclusionCellArray=this.ExclusionCellArray;
        exclusion.SLVersionInfo=ver('Simulink');


        if ischar(filename)
            filename=fliplr(filename);
            if~strncmpi(filename,'tam.',4)
                filename=['tam.',filename];
            end;
            filename=fliplr(filename);
        end


        save(filename,'exclusion');

        success=true;

    catch E


        disp(E.message);
        rethrow(E);
    end
