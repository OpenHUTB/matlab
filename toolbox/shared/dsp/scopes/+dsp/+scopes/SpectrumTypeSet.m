classdef SpectrumTypeSet<matlab.system.internal.StringSetGF




    properties(Access=private)
        GrandFathered=false;
        GFValues={};
        NewValues={};
    end

    methods
        function obj=SpectrumTypeSet(values,oldGFValues,newValues)
            obj@matlab.system.internal.StringSetGF(values,oldGFValues,newValues);
            obj.GFValues=oldGFValues;
            obj.NewValues=newValues;
        end

        function match=findMatch(obj,value,propname)

            value=oldToNewValue(obj,value);

            match=findMatch@matlab.system.internal.StringSetGF(obj,value,propname);
        end

        function ind=getIndex(obj,value)
            value=oldToNewValue(obj,value);
            ind=getIndex@matlab.system.StringSet(obj,value);
        end

        function flag=isGrandFathered(obj)
            flag=obj.GrandFathered;
        end

    end

    methods(Access=private)
        function value=oldToNewValue(obj,value)

            obj.GrandFathered=false;

            ind=find(strcmpi(obj.GFValues,value));
            if~isempty(ind)
                value=obj.NewValues{ind};
                obj.GrandFathered=true;
            end
        end
    end
end
