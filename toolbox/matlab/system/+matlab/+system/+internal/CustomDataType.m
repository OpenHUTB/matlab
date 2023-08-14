classdef(Sealed)CustomDataType




    properties(SetAccess=protected)




        Signedness;




        Scaling;
    end

    properties(Hidden,Constant)
        SignednessSet=matlab.system.StringSet({'Signed','Unsigned','Auto'});
        ScalingSet=matlab.system.StringSet({'BinaryPoint','Unspecified'});
    end

    methods
        function obj=CustomDataType(varargin)
            p=inputParser;
            validationFcn=@(x)~isempty(x)&&(iscellstr(x)||isstring(x));
            p.addParameter('Signedness',{'Signed'},validationFcn);
            p.addParameter('Scaling',{'BinaryPoint'},validationFcn);
            p.parse(varargin{:});


            obj.Signedness=p.Results.Signedness;
            obj.Scaling=p.Results.Scaling;
        end

        function obj=set.Signedness(obj,v)
            for ind=1:numel(v)
                v{ind}=obj.SignednessSet.findMatch(v{ind},'Signedness');
            end
            obj.Signedness=v;
        end

        function obj=set.Scaling(obj,v)
            for ind=1:numel(v)
                v{ind}=obj.ScalingSet.findMatch(v{ind},'Scaling');
            end
            obj.Scaling=v;
        end

        function match=findNumerictypeMatch(obj,value,propName)
            matlab.system.internal.CustomDataType.validateCustomDataType(obj,propName,value);
            match=value;
        end
    end

    methods(Static)
        function validateCustomDataType(obj,propName,value)

            if~isa(value,'embedded.numerictype')
                matlab.system.internal.error('MATLAB:system:CustomDataType:Invalid',propName);
            elseif~ismember(value.Signedness,obj.Signedness)
                vSignednessStr=lower(value.Signedness);
                if strcmp(vSignednessStr,'auto')
                    vSignednessStr='auto-signed';
                end

                switch numel(obj.Signedness)
                case 1
                    matlab.system.internal.error('MATLAB:system:CustomDataType:UnsupportedSignednessAllowOne',...
                    propName,vSignednessStr,lower(obj.Signedness{1}));
                case 2
                    matlab.system.internal.error('MATLAB:system:CustomDataType:UnsupportedSignednessAllowTwo',...
                    propName,vSignednessStr,lower(obj.Signedness{1}),lower(obj.Signedness{2}));
                otherwise
                    matlab.system.internal.error('MATLAB:system:CustomDataType:UnsupportedSignednessAllowThree',...
                    propName,vSignednessStr,lower(obj.Signedness{1}),lower(obj.Signedness{2},lower(obj.Signedness{3})));
                end
            elseif~ismember(value.Scaling,obj.Scaling)
                switch numel(obj.Scaling)
                case 1
                    matlab.system.internal.error('MATLAB:system:CustomDataType:UnsupportedScalingAllowOne',...
                    propName,value.Scaling,obj.Scaling{1});
                otherwise
                    matlab.system.internal.error('MATLAB:system:CustomDataType:UnsupportedScalingAllowTwo',...
                    propName,value.Scaling,obj.Scaling{1},obj.Scaling{2});
                end
            end
        end
    end
end
