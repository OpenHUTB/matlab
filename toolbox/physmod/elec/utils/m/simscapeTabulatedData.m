classdef simscapeTabulatedData<handle



    properties(SetAccess=private,GetAccess=public)
name
symbol
value
    end

    methods(Access=public)
        function theSimscapeTabulatedData=simscapeTabulatedData(aName,aSymbol,aValue)
            theSimscapeTabulatedData.name=aName;
            theSimscapeTabulatedData.symbol=aSymbol;
            theSimscapeTabulatedData.value=aValue;
        end
    end

    methods
        function set.name(theSimscapeTabulatedData,aName)
            if~ischar(aName)&&~isstring(aName)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeTabulatedData:error_PropertyName')));
            end
            theSimscapeTabulatedData.name=string(aName);
        end

        function set.symbol(theSimscapeTabulatedData,aSymbol)
            if~ischar(aSymbol)&&~isstring(aSymbol)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeTabulatedData:error_PropertySymbol')));
            end
            theSimscapeTabulatedData.symbol=string(aSymbol);
        end

        function set.value(theSimscapeTabulatedData,aValue)
            theSimscapeTabulatedData.value=aValue;
        end
    end
end