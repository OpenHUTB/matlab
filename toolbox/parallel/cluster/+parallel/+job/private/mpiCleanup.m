function mpiCleanup()




    dctSchedulerMessage(5,'In mpiCleanup.');
    if mpiInitialized
        dctSchedulerMessage(4,'In mpiCleanup, actually cleaning up MPI infrastructure.');


        mpigateway('setidle');
        mpigateway('setrunning');





        spmdBarrier;


        mpiParallelSessionEnding;

        mpiFinalize;
        dctSchedulerMessage(4,'In mpiCleanup, finished cleaning up MPI infrastructure.');
    end


    pctPreRemoteEvaluation('mpi_mi');

end
