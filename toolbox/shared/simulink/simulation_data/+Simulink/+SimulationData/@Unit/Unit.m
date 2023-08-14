







classdef Unit
    properties(SetAccess=private)
        Name;
    end

    properties(Hidden=true,GetAccess=public,SetAccess=private)
        Version=0;
    end


    methods
        function this=Unit(varargin)
            narginchk(0,1)
            if(nargin>0)
                if ischar(varargin{1})&&~strcmpi(varargin{1},'inherit')
                    this.Name=varargin{1};
                else
                    Simulink.SimulationData.utError(...
                    'InvalidUnitsName');
                end
            else
                this.Name='';
            end
        end

        function this=setName(this,name)
            if ischar(name)&&~strcmpi(name,'inherit')
                this.Name=name;
            else
                Simulink.SimulationData.utError(...
                'InvalidUnitsName');
            end
        end

    end
end


