classdef CommandLineInterface < handle
    %
    
    %   Copyright 2020 The MathWorks, Inc.
    properties (Access = protected, Transient)
        Application
        ApplicationClosingListener
    end
    
    methods
        function parseInputs(this, app)
            if nargin < 1 || ~isa(app, getApplicationClassName(this))
                
                % Use throwAsCaller in order to remove stack lines
                id = getInvalidApplicationErrorID(this);
                me = MException(id, string(message(id)));
                throwAsCaller(me);
            end
            this.Application = app;
            this.ApplicationClosingListener = event.listener(app, 'ObjectBeingDestroyed', @(~,~) delete(this));
        end
    end
    
    methods (Hidden)
        function s = struct(~)
            s = struct();
        end
    end
    
    methods (Access = protected, Abstract)
        name = getApplicationClassName(this)
        id   = getInvalidApplicationErrorID(this)
    end
end

% [EOF]
