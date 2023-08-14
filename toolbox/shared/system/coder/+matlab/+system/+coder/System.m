classdef(Abstract)System<matlab.system.coder.SystemProp&matlab.system.coder.SystemCore



%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    methods
        function obj=System()
            coder.allowpcode('plain');
        end
    end

    methods(Access=public,Static)
        function props=matlabCodegenNontunableProperties(classname)
            props={};
            mc=meta.class.fromName(classname);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if(isa(mp,'matlab.system.CustomMetaProp')&&mp.Nontunable)
                    props{end+1}=mp.Name;
                end
            end
            props=[props,matlabCodegenNontunableProperties@matlab.system.coder.SystemCore(classname)];
        end

        function props=matlabCodegenNontunablePublicProperties(classname)
            props={};
            mc=meta.class.fromName(classname);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if(isa(mp,'matlab.system.CustomMetaProp')&&mp.Nontunable&&...
                    ~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&...
                    ~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public'))
                    props{end+1}=mp.Name;
                end
            end
        end

        function props=matlabCodegenPublicProperties(classname)
            props={};
            mc=meta.class.fromName(classname);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if(~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&...
                    ~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public'))
                    props{end+1}=mp.Name;
                end
            end
        end

        function props=matlabCodegenPublicTunableProperties(classname)
            props={};
            mc=meta.class.fromName(classname);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if(isa(mp,'matlab.system.CustomMetaProp')&&~mp.Nontunable&&...
                    ~iscell(mp.DiscreteState)&&~mp.DiscreteState&&...
                    ~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&...
                    ~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public'))
                    props{end+1}=mp.Name;
                end
            end
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)
            supported=false;
        end
    end

end
