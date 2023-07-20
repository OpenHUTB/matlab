function workspacesMatch=workerBaseWorkspacesMatchClient(pool,computeChecksumFunc)






    if nargin<2
        computeChecksumFunc=@coder.parallel.internal.computeBaseWorkspaceChecksum;
    end


    future=pool.runOnAllWorkersAsync(computeChecksumFunc);


    clientBaseWorkspaceChecksum=computeChecksumFunc();


    workerBaseWorkspaceChecksums=fetchOutputs(future);

    workspacesMatch=all(workerBaseWorkspaceChecksums==clientBaseWorkspaceChecksum,'all');
end
