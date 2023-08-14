classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) fitRationalOptions
    %
    
    % Options for fitRational
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        MaxIterSK = 20;
        MaxIterIV = 20;
        UseCtrlToolboxFcns = false();
    end
    
    properties(Hidden)
        FittingMethod = 'OVF';
        InitializationMethod = 'Levy';
        SolutionMethod = 'qr';
        MagnitudeScaling = true();
        AutoIterations = true();
        KeepAsymptotes = true();
        GuaranteeRelativeDegree = true();
        % Basic stability enforcements
        EnforceStability = false();
        % Debugging options
        DisplayConditionNumber = false();
        Debug = false();
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Visible options
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = set.MaxIterSK(this,val)
            validateattributes(val,{'numeric'},...
                {'scalar','finite','nonnegative','integer'},...
                'set.MaxIterSK');
            this.MaxIterSK = val;
        end
        
        function this = set.MaxIterIV(this,val)
            validateattributes(val,{'numeric'},...
                {'scalar','finite','nonnegative','integer'},...
                'set.MaxIterIV');
            this.MaxIterIV = val;
        end
        
        function this = set.UseCtrlToolboxFcns(this,val)
            validateattributes(val,{'numeric','logical'},...
                {'scalar','finite'},...
                'set.UseCtrlToolboxFcns');
            this.UseCtrlToolboxFcns = logical(val);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hidden options
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = set.FittingMethod(this,val)
            val = validatestring(val,{'SK','VF','OVF'});
            this.FittingMethod = val;
        end
        
        function this = set.InitializationMethod(this,val)
            val = validatestring(val,{'Levy','Lin','Log','UniformRandom'});
            this.InitializationMethod = val;
        end
        
        function this = set.SolutionMethod(this,val)
            val = validatestring(val,{'qr','qrro','idilslnsh'});
            this.SolutionMethod = val;
        end
        
        function this = set.MagnitudeScaling(this,val)
            validateattributes(val,{'numeric','logical'},{'scalar','finite'},...
                'set.MagnitudeScaling');
            this.MagnitudeScaling = logical(val);
        end
        
        function this = set.AutoIterations(this,val)
            validateattributes(val,{'numeric','logical'},{'scalar','finite'},...
                'set.AutoIterations');
            this.AutoIterations = logical(val);
        end
        
        function this = set.KeepAsymptotes(this,val)
            validateattributes(val,{'numeric','logical'},{'scalar','finite'},...
                'set.KeepAsymptotes');
            this.KeepAsymptotes = logical(val);
        end
        
        
        function this = set.GuaranteeRelativeDegree(this,val)
            validateattributes(val,{'numeric','logical'},{'scalar','finite'},...
                'set.GuaranteeRelativeDegree');
            this.GuaranteeRelativeDegree = logical(val);
        end
        
        function this = set.EnforceStability(this,val)
            validateattributes(val,{'numeric','logical'},{'scalar','finite'},...
                'set.EnforceStability');
            this.EnforceStability = logical(val);
        end
    end
end

% LocalWords:  OVF qrro idilslnsh
