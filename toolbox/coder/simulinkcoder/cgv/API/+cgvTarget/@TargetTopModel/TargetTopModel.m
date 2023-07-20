classdef TargetTopModel<cgvTarget.TargetBase




    methods
        function obj=TargetTopModel(aModelName,connectivity)
            if(nargin~=2)
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            obj.TestHarnessName=aModelName;
            obj.ModelName=aModelName;
            obj.ComponentType='topmodel';
            obj.Connectivity=connectivity;
        end

        function setupTarget(this)
            h=load_system(this.TestHarnessName);
            switch lower((this.Connectivity))
            case{'sim','normal'}
                simMode='normal';
            case 'sil'
                simMode='software-in-the-loop (sil)';
            case 'pil'
                simMode='processor-in-the-loop (pil)';
            otherwise
                assert(false,'Unexpected connectivity "%s" type.',...
                this.Connectivity);
            end
            set_param(h,'SimulationMode',simMode);
        end
    end

end


