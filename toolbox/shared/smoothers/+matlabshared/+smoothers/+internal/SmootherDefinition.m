classdef SmootherDefinition<handle









%#codegen


    properties(Dependent)




EnableSmoothing
    end


    properties(Access=private)
pSmoothing
        pIsSmoothingLocked=false;
    end

    properties(Access=protected,Constant)
        DefaultEnableSmoothing=false;
    end

    properties(Access=private,Constant)

        ProtectedClasses={'matlabshared.tracking.internal.AbstractTrackingFilter'};
    end

    methods
        function obj=SmootherDefinition()
            coder.allowpcode('plain');
        end
    end

    methods
        function set.EnableSmoothing(obj,val)
            setSmoothingValue(obj,val)
        end

        function val=get.EnableSmoothing(obj)

            val=obj.pSmoothing;
        end

        function val=get.pSmoothing(obj)
            if~coder.target('MATLAB')&&~coder.internal.is_defined(obj.pSmoothing)
                obj.pSmoothing=obj.DefaultEnableSmoothing;
            end
            val=obj.pSmoothing;
        end
    end

    methods(Access=protected)
        function tf=isSmoothingLocked(obj)

            tf=obj.pIsSmoothingLocked;
        end

        function setSmoothingValue(obj,val)



            if coder.target('MATLAB')
                coder.internal.assert(~obj.pIsSmoothingLocked,'shared_smoothers:AbstractSmoother:nonTunableSmoothingML');
            else
                coder.internal.assert(~coder.internal.is_defined(obj.pSmoothing),'shared_smoothers:AbstractSmoother:nonTunableSmoothingCG');
            end
            validateattributes(val,{'logical','numeric'},{'binary'},class(obj),'EnableSmoothing');
            if val&&isLicenseProtected(obj)
                checkOutSFTTLicense(obj)
            end
            obj.pSmoothing=val;
        end

        function lockSmoothingValue(obj)



            obj.pIsSmoothingLocked=true;
        end
    end

    methods(Sealed,Access=private)
        function tf=isLicenseProtected(obj)

            tf=false;
            coder.unroll();
            for i=1:numel(obj.ProtectedClasses)
                tf=isa(obj,obj.ProtectedClasses{i});
                if tf
                    return;
                end
            end
        end

        function checkOutSFTTLicense(~)

            if coder.target('MATLAB')
                try
                    isSFTTAvailable=builtin('license','test','Sensor_Fusion_and_Tracking');
                    success=false;
                    if isSFTTAvailable
                        [success,~]=builtin('license','checkout','Sensor_Fusion_and_Tracking');
                    end
                    coder.internal.assert(success,'shared_smoothers:AbstractSmoother:needsSFTTLicense');
                catch ME
                    throwAsCaller(ME);
                end
            else
                coder.license('checkout','Sensor_Fusion_and_Tracking');
            end
        end
    end

    methods(Access=protected)
        function copySmootherProperties(obj,obj2)
            if coder.internal.is_defined(obj.pSmoothing)
                obj2.pSmoothing=obj.pSmoothing;
            end
        end

        function loadSmootherProperties(obj,s)




            if isfield(s,'pSmoothing')
                obj.pSmoothing=s.pSmoothing;
            end
            if isfield(s,'pIsSmoothingLocked')
                obj.pIsSmoothingLocked=s.pIsSmoothingLocked;
            end
        end

        function s=saveSmootherProperties(obj,sIn)

            s=struct;
            if nargin==2
                inFields=fieldnames(sIn);
                for i=1:numel(inFields)
                    s.(inFields{i})=sIn.(inFields{i});
                end
            end
            if coder.internal.is_defined(obj.pSmoothing)
                s.pSmoothing=obj.pSmoothing;
            end
            s.pIsSmoothingLocked=obj.pIsSmoothingLocked;
        end
    end

    methods(Static,Hidden)
        function props=matlabCodegenNontunableProperties(~)


            props={'pSmoothing'};
        end
    end
end