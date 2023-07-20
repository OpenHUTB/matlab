classdef BasePort<handle




    properties(Abstract)
Name
    end
    properties(SetAccess=private,Abstract)
Parent
Direction
Interface
Connectors
Connected
    end
end

