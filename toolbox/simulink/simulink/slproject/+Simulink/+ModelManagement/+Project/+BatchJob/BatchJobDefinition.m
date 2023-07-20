classdef BatchJobDefinition<handle




    properties(Abstract,GetAccess=public,SetAccess=protected)
        Files;
        Command;
        Arguments;
    end

end

