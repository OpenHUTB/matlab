classdef SystemCore<matlab.system.coder.SystemCore




%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    methods(Access=public)
        function obj=SystemCore()
            coder.extrinsic('matlabCodegenhasTunablePublicProps');
            coder.extrinsic('matlabCodegenhasContinuousStateProps');
            coder.extrinsic('lowersysobj.isPIRSupportedObject');
            coder.extrinsic('checkMATLABAuthoredNonPirObject');
            coder.allowpcode('plain');
            coder.internal.allowHalfInputs;
            isPIRObject=coder.internal.const(feval('lowersysobj.isPIRSupportedObject',class(obj)));
            if~isPIRObject

                coder.internal.assert(...
                coder.internal.const(obj.checkMATLABAuthoredNonPirObject(class(obj))),...
                'MATLAB:system:unsupportedNonPirMATLABSystemHDL',class(obj));

                coder.internal.assert(...
                coder.internal.const(~obj.matlabCodegenhasContinuousStateProps(class(obj))),...
                'MATLAB:system:unsupportedContinuousStatePropertiesHDL');
            end
        end

        function reset(obj)
            coder.internal.defer_inference('resetImpl',obj);
        end

        function s=info(~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','info');
            s='';
        end

        function varargout=systemobject_hdl_codegen_step_method(obj,varargin)
            coder.inline('never');
            coder.extrinsic('matlabCodegenNumNonTunableProps');
            coder.extrinsic('matlabCodegenGetNthNonTunableProp');
            N=coder.internal.const(obj.matlabCodegenNumNonTunableProps(class(obj)));
            [~,tempCreateErr,tempNewObj]=feval('eml_try_catch',...
            'matlab.system.hdlcoder.SystemCore.createObjectFromStruct',class(obj));
            createErr=coder.internal.const(tempCreateErr);
            newObj=coder.internal.const(tempNewObj);
            for i=coder.unroll(1:N)
                p=coder.internal.const(obj.matlabCodegenGetNthNonTunableProp(class(obj),i));
                coder.internal.const(feval('eml_try_catch',...
                'matlab.system.hdlcoder.SystemCore.setObjectProp',newObj,p,obj.(p)));
            end
            eml_assert(isempty(createErr),createErr);
            if nargout>0
                [varargout{1:nargout}]=eml_sea_method_call('step_hdl',newObj,varargin{:},obj);
            else
                eml_sea_method_call('step_hdl',newObj,varargin{:},obj);
            end
        end

        function varargout=step(obj,varargin)
            coder.extrinsic('lowersysobj.isPIRSupportedObject');
            obj.setupAndReset(varargin{:});
            isPIRObject=coder.internal.const(feval('lowersysobj.isPIRSupportedObject',class(obj)));
            if~isPIRObject
                checkPropertyValues(obj);
                if nargout>0
                    [varargout{1:nargout}]=step@matlab.system.coder.SystemCore(obj,varargin{:});
                else
                    step@matlab.system.coder.SystemCore(obj,varargin{:});
                end
            else


                numOuts=coder.internal.const(getNumOutputs(obj));
                if numOuts>0
                    [varargout{1:numOuts}]=obj.stepImpl(varargin{:});
                    [varargout{1:numOuts}]=systemobject_hdl_codegen_step_method(obj,nargin-1,varargin{:},varargout{:});
                else
                    obj.stepImpl(varargin{:});
                    systemobject_hdl_codegen_step_method(obj,nargin-1,varargin{:});
                end
            end
        end

        function release(~)

            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','release');
        end

        function varargout=isInputDirectFeedthrough(~,varargin)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','isInputDirectFeedthrough');
            varargout{1}=false;
        end

        function ds=getDiscreteState(~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','getDiscreteState');
            ds=[];
        end

        function setDiscreteState(~,~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','setDiscreteState');
        end

        function ds=getContinuousState(~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','getContinuousState');
            ds=[];
        end

        function setContinuousState(~,~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','setContinuousState');
        end
    end

    methods(Access=public,Static)
        function props=getDiscreteStateProperties(~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','getDiscreteStateProperties');
            props={};
        end

        function props=getContinuousStateProperties(~)
            coder.internal.assert(false,'MATLAB:system:unsupportedHDLMethod','getContinuousStateProperties');
            props={};
        end

        function isValid=checkMATLABAuthoredNonPirObject(objName)

            isValid=lowersysobj.isAllowedAuthoredObject(objName);


            objPath=which(objName);
            if~startsWith(objPath,matlabroot)...
                ||~isempty(regexp(objPath,'demos','once'))...
                ||startsWith(objPath,fullfile(matlabroot,'example'))...
                ||startsWith(objPath,fullfile(matlabroot,'test'))
                isValid=true;
            end
        end
    end

end


