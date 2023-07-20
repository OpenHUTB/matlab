



classdef CNameGenerator<handle


    properties(Access=private)


SFcnName

VarPrefix

FcnPrefix

SimStructPrefix
    end

    properties(Access=public)


        SingleInstance=false
    end


    methods
        function obj=CNameGenerator(sfunctionName,sInfo,ssPrefix,varPrefix,fcnPrefix)
            if nargin<3
                ssPrefix='';
            end
            if nargin<4
                varPrefix='';
            end
            if nargin<5
                fcnPrefix='';
            end

            if isempty(varPrefix)
                varPrefix=sInfo.InstrumInfo.VarRadix;
            end
            if isempty(fcnPrefix)
                fcnPrefix=sInfo.InstrumInfo.FcnRadix;
            end

            obj.SFcnName=sfunctionName;
            obj.VarPrefix=varPrefix;
            obj.FcnPrefix=fcnPrefix;
            obj.SimStructPrefix=ssPrefix;
        end

        function name=varName(obj,baseName,instanceName)
            if nargin<3
                instanceName='';
            end
            if obj.SingleInstance
                name=sprintf('%s_%s_%s',obj.VarPrefix,obj.SFcnName,baseName);
            else
                name=sprintf('%s_%s_%s_%s',obj.VarPrefix,obj.SFcnName,instanceName,baseName);
            end
        end

        function name=functionName(obj,baseName,instanceName)
            if nargin<3
                instanceName='';
            end
            if obj.SingleInstance
                name=sprintf('%s_%s_%s',obj.FcnPrefix,obj.SFcnName,baseName);
            else
                name=sprintf('%s_%s_%s_%s',obj.FcnPrefix,obj.SFcnName,instanceName,baseName);
            end
        end

        function name=ssFunction(obj,functionName)
            name=sprintf('%s%s',obj.SimStructPrefix,functionName);
        end
    end
end
