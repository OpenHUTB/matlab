



classdef EnumType<handle
    properties

        fTagName;

        fElementNames={};

        fElementValues={};

        fAddClassNameToEnumNames;
    end


    methods

        function aObj=EnumType(name)
            aObj.fTagName=name;
        end


        function addElementAndValue(aObj,elementName,elementValue)
            aObj.fElementNames{end+1}=elementName;
            aObj.fElementValues{end+1}=elementValue;
        end


        function setAddClassNameToEnumNames(aObj,addClassName)
            aObj.fAddClassNameToEnumNames=addClassName;
        end


        function out=getAddClassNameToEnumNames(aObj)
            out=aObj.fAddClassNameToEnumNames;
        end


        function out=getName(aObj)
            out=aObj.fTagName;
        end


        function out=getElementNames(aObj)
            out=aObj.fElementNames;
        end


        function out=getElementValues(aObj)
            out=aObj.fElementValues;
        end
    end
end