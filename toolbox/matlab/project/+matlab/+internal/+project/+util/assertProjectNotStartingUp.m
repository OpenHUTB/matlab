function assertProjectNotStartingUp()




    if matlab.internal.project.util.isThisAProjectStartupCall
        error(message('MATLAB:project:api:ForbiddenDuringStartup'));
    end

end