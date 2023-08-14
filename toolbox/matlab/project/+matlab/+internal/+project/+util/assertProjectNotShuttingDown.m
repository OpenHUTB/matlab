function assertProjectNotShuttingDown()




    if matlab.internal.project.util.isThisAProjectShutdownCall()
        error(message('MATLAB:project:api:ForbiddenDuringShutdown'));
    end

end