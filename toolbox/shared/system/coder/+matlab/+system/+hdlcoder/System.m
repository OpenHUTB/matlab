classdef(Abstract)System<matlab.system.hdlcoder.SystemCore&matlab.system.coder.SystemProp





%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    methods
        function obj=System()
            coder.allowpcode('plain');
            coder.internal.allowHalfInputs;
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
        end
        function props=matlabCodegenPublicNontunableProperties(classname)
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
        function N=matlabCodegenNumNonTunableProps(classname)
            N=numel(feval('matlab.system.hdlcoder.System.matlabCodegenPublicNontunableProperties',classname));
        end
        function p=matlabCodegenGetNthNonTunableProp(classname,N)
            nonTunableProps=feval('matlab.system.hdlcoder.System.matlabCodegenPublicNontunableProperties',classname);
            p=nonTunableProps{N};
        end
        function out=matlabCodegenhasTunablePublicProps(className)
            out=false;
            mc=meta.class.fromName(className);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if matlab.system.coder.SystemProp.isTunablePublicSetProp(mp)
                    out=true;
                    break;
                end
            end
        end
        function out=matlabCodegenhasContinuousStateProps(className)
            out=false;
            mc=meta.class.fromName(className);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if isa(mp,'matlab.system.CustomMetaProp')&&mp.ContinuousState
                    out=true;
                    break;
                end
            end
        end
    end

    methods(Access=public,Hidden)


        function checkPropertyValues(obj)
            coder.extrinsic('matlabCodegenNumNonTunableProps');
            coder.extrinsic('matlabCodegenGetNthNonTunableProp');
            N=coder.internal.const(obj.matlabCodegenNumNonTunableProps(class(obj)));
            for i=coder.unroll(1:N)
                p=coder.internal.const(obj.matlabCodegenGetNthNonTunableProp(class(obj),i));
                value=obj.(p);
                coder.internal.assert(isnumeric(value)||ischar(value)||...
                islogical(value)||isa(value,'embedded.fi')||...
                isa(value,'embedded.numerictype'),...
                'hdlcoder:matlabhdlcoder:systemobjectunsupportedpropvalue',...
                p,class(obj),class(value));
            end
        end
    end
end


