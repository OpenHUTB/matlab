function IMT_PostHarnessAutoTestCleanup()






    try


        close all;

        close all hidden force;


        bdclose all;


        fclose all;


        diary off;
    catch
        disp('Error in IMT_PostHarnessAutoTestCleanup')
        disp(lasterr);
        diary off;
        quit force
    end
end
