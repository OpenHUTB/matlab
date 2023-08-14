classdef PropertyOrMethod<matlab.system.internal.ChoosablePolicy


%#codegen 



    properties(SetAccess=protected)
        MethodName=''
    end

    methods
        function obj=PropertyOrMethod(aClient,aCPN,aMethodName,aIsTargetActive)

            coder.allowpcode('plain');

            obj@matlab.system.internal.ChoosablePolicy(...
            'PropertyOrMethod',...
            aClient,...
            aCPN,...
            aIsTargetActive);

            obj.MethodName=char(aMethodName);
        end

        function value=invokeMethod(obj,sysObj)
            fcn=str2func(obj.MethodName);
            value=fcn(sysObj);
        end
    end

    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'MethodName'};
        end

        function args=getConstructorArgs(obj)
            args={obj.Client,...
            obj.ControlPropertyName,...
            obj.MethodName,...
            obj.IsTargetPropertyActive};
        end
    end
end
