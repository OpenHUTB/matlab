



classdef CScriptVarReplacer<internal.cxxfe.FrontEndHandler
    properties
FrontEndOptions
CustomCodeSettings
NameMap
ScriptParams
ScriptFunctionName
    end

    properties(Access=private)
FcnBody
    end

    methods
        function obj=CScriptVarReplacer(feOptions,customCodeSettings)
            obj.FrontEndOptions=feOptions;
            obj.CustomCodeSettings=customCodeSettings;
            obj.NameMap=containers.Map('KeyType','char','ValueType','char');
            obj.ScriptFunctionName='__cscript';
        end

        function setScriptParams(obj,params)
            obj.ScriptParams=params;
        end

        function addReplacementVariable(obj,originalVar,newVar)
            obj.NameMap(originalVar)=newVar;
        end

        function fcnBody=getBody(obj,originalBody)
            obj.FcnBody=originalBody;

            scriptFunction=sprintf('#include <tmwtypes.h>\n%s\n\nvoid %s(%s) {\n%s\n}',...
            obj.CustomCodeSettings.customCode,...
            obj.ScriptFunctionName,...
            strjoin(obj.ScriptParams,', '),...
            obj.FcnBody);

            internal.cxxfe.FrontEnd.parseText(scriptFunction,obj.FrontEndOptions,obj);

            fcnBody=obj.FcnBody;
        end

        function afterParsing(obj,ilPtr,~,~,~)
            obj.FcnBody=sldv.code.slcc.internal.replaceCScriptBody(ilPtr,...
            obj.ScriptFunctionName,...
            obj.FcnBody,...
            obj.NameMap.keys(),...
            obj.NameMap.values());
        end
    end
end


