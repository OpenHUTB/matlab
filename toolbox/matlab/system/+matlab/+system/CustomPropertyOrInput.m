classdef CustomPropertyOrInput<matlab.system.internal.PropertyOrInput

%#codegen

    methods
        function obj=CustomPropertyOrInput(aClient,aCPN,varargin)


            coder.allowpcode('plain');
            coder.extrinsic('checkInputs');

            [ordinal,inputLabel,isTargetActive]=resolveOptionalInputs(varargin{:});

            coder.internal.const(matlab.system.CustomPropertyOrInput.checkInputs(...
            aClient,aCPN,ordinal,inputLabel,isTargetActive));

            obj@matlab.system.internal.PropertyOrInput(...
            aClient,...
            aCPN,...
            ordinal,...
            inputLabel,...
            isTargetActive);

            obj.Name=class(obj);
        end

        function flag=useProperty(obj,sysObj,propName)
            flag=useProperty@matlab.system.internal.PropertyOrInput(obj,sysObj,propName);

            flag=~obj.isInputActive(sysObj,propName,~flag);
            verifyPolicyReturn(flag,'isInputActive');
        end

        function flag=isTargetPropertyActive(obj,sysObj,propName)
            flag=isTargetPropertyActive@matlab.system.internal.PropertyOrInput(obj,sysObj,propName);
            flag=obj.isPropertyActive(sysObj,propName,flag);
            verifyPolicyReturn(flag,'isPropertyActive');
        end

        function flag=isControlPropertyActive(obj,sysObj)
            flag=isControlPropertyActive@matlab.system.internal.PropertyOrInput(obj,sysObj);
            flag=obj.isPropertyActive(sysObj,obj.ControlPropertyName,flag);
            verifyPolicyReturn(flag,'isPropertyActive');
        end
    end

    methods(Static)
        function flag=checkInputs(varargin)
            strClientValidationFcn=@(x)validateattributes(x,...
            {'char','string'},...
            {'scalartext'},...
            'CustomPropertyOrInput',...
            'Client');

            strCPNValidationFcn=@(x)validateattributes(x,...
            {'char','string'},...
            {'scalartext'},...
            'CustomPropertyOrInput',...
            'ControlName');

            posIntValidationFcn=@(x)validateattributes(x,...
            {'numeric'},...
            {'scalar','integer','positive'},...
            'CustomPropertyOrInput',...
            'InputOrdinal');

            strLabelValidationFcn=@(x)validateattributes(x,...
            {'char','string'},...
            {'scalartext'},...
            'CustomPropertyOrInput',...
            'InputLabel');

            logicalValidationFcn=@(x)validateattributes(x,...
            {'logical'},...
            {'scalar'},...
            'CustomPropertyOrInput',...
            'IsControlActive');

            p=inputParser;
            p.addRequired('Client',strClientValidationFcn);
            p.addRequired('ControlName',strCPNValidationFcn);


            p.addOptional('InputOrdinal',1,posIntValidationFcn);
            p.addOptional('InputLabel','<missing>',strLabelValidationFcn);
            p.addOptional('IsActive',true,logicalValidationFcn);
            p.parse(varargin{:});
            lResults=p.Results;

            if strcmp(lResults.InputLabel,'<missing>')
                lResults.InputLabel='';
            end
            validatestring(lResults.Client,{'MATLAB','SystemBlock'},1,'Client');

            flag=true;
        end

        function flag=isPropertyActive(~,~,flag)
        end

        function flag=isInputActive(~,~,flag)
        end

        function args=getConstructorArgs(obj)
            args={obj.Client,...
            obj.ControlPropertyName,...
            obj.InputOrdinal,...
            obj.InputLabel,...
            obj.IsTargetPropertyActive};

            mc=metaclass(obj);
            parts=split(class(obj),'.');
            constructorName=parts{end};
            mm=findobj(mc.MethodList,'-depth',0,'Name',constructorName);

            if(mm.InputNames{end}~="varargin")&&(numel(mm.InputNames)<numel(args))
                args=args(1:numel(mm.InputNames));
            end
        end
    end
end

function verifyPolicyReturn(value,methodName)
    if~(islogical(value)&&isscalar(value))
        error(message('MATLAB:system:logicalMustBeLogicalScalarReturn',methodName));
    end
end

function[ordinal,inputLabel,isTargetActive]=resolveOptionalInputs(varargin)
    if nargin>0
        ordinal=varargin{1};
    else
        ordinal=1;
    end

    if nargin>1
        inputLabel=varargin{2};
    else
        inputLabel='<missing>';
    end

    if nargin>2
        isTargetActive=varargin{3};
    else
        isTargetActive=true;
    end
end
