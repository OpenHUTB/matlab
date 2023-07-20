
%

%   Copyright 2009-2010 The MathWorks, Inc.

classdef SldvExternalEngine
    properties
        Name = '';
        Command = '';
        CommandPath = '';
        CommandArguments = {};
        TestCaseGeneration = false;
        PropertyProving = false;
    end
       
    properties (Hidden = true)
        RuntimeErrorDetection = false;
        FollowUpStrategy = 0;
        AcceptExternalResults = false;
        UsesDVO = false;
        UsesEncryptedDVO = false;
        ValidateSatisfiedResults = false;
        ExternalKillCommand = '';
    end
    
    methods
        function [valid, msg] = isValid(eng)
            valid = false;
            msg = '';
            
            if isempty(eng.Command)
                msg = getString(message('Sldv:sldv:extEngine:EmptyCommand', eng.Name));
                return;
            end
           
            if isempty(eng.CommandPath)
                fullname = eng.Command;
            else
                fullname = [ eng.CommandPath filesep eng.Command ];
            end
            if ~exist(fullname, 'file')
                msg = getString(message('Sldv:sldv:extEngine:CommandNotFound', eng.Name));
                return;
            end
            
            valid = true;
        end
    end
end
