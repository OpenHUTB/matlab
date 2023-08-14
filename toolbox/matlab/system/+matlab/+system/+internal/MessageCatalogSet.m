classdef(Sealed)MessageCatalogSet<matlab.system.StringSet




    properties(Access=private)
MessageIdentifiers
    end

    methods
        function obj=MessageCatalogSet(varargin)
            obj@matlab.system.StringSet(varargin{:});
        end
    end

    methods(Hidden)
        function messageID=getMessageIdentiferFromIndex(obj,index)
            messageID=obj.MessageIdentifiers{index};
        end
    end

    methods(Access=protected)
        function setValues(obj,values)
            visibleValues=matlab.system.internal.lookupMessageCatalogEntries(values,true,'MessageCatalogSet');
            setValues@matlab.system.StringSet(obj,visibleValues);
            obj.MessageIdentifiers=values;
        end
    end
end
