classdef DefineToA2LConverter<handle





    properties(Access=private)

        DefineMap containers.Map=containers.Map.empty;
    end

    methods
        function obj=DefineToA2LConverter(defineMap)

            obj.DefineMap=defineMap;
        end

        function a2lValue=getNumericValue(obj,macroName,defaultValue)

            hasDefine=obj.DefineMap.isKey(macroName);
            if hasDefine
                a2lValue=obj.evalNumericValue(obj.DefineMap(macroName));
            else
                a2lValue=defaultValue;
            end
        end

        function a2lValue=getEnumValue(obj,macroName,conditionMap,defaultValue)

            hasDefine=obj.DefineMap.isKey(macroName);
            if hasDefine
                macroValue=obj.DefineMap(macroName);
                macroValue=strip(macroValue);
                for kCond=1:size(conditionMap,1)
                    if isempty(conditionMap{kCond,1})

                        hasMatch=true;
                    else
                        hasMatch=~isempty(regexp(macroValue,['^(',conditionMap{kCond,1},')$'],'match','once'));
                    end
                    if hasMatch
                        a2lValue=conditionMap{kCond,2};
                        return;
                    end
                end
                DAStudio.error('coder_xcp:a2l:UnsupportedPreprocessorMacroValue',macroName,macroValue);
            else
                a2lValue=defaultValue;
            end
        end

        function conditionVal=getBoolCondition(obj,macroName,conditionRule,defaultValue)

            hasDefine=obj.DefineMap.isKey(macroName);
            if hasDefine
                macroValue=obj.DefineMap(macroName);
                if isempty(conditionRule)
                    conditionVal=true;
                else
                    conditionVal=~isempty(regexp(macroValue,['^(',conditionRule,')$'],'match','once'));
                end
            else
                conditionVal=defaultValue;
            end
        end
    end

    methods(Access=private)
        function numVal=evalNumericValue(obj,inStr)




            inStr=strip(inStr);

            if obj.isHexStr(inStr)

                inStr=regexprep(inStr,'^0[xX]','');
                numVal=hex2dec(inStr);
            else
                numVal=str2double(inStr);
            end
        end
    end

    methods(Static,Access=private)
        function isHex=isHexStr(inStr)



            isHex=~isempty(regexp(inStr,'^0[xX][0-9a-fA-F]+$','once'));
        end
    end
end