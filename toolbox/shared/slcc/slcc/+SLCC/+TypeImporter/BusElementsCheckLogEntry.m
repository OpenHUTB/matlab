classdef BusElementsCheckLogEntry


    properties
        FieldName=[];
        ExistingValue=[];
        NewValue=[];
        ElementIndex=[];
        isNew=0;
    end

    methods
        function obj=BusElementsCheckLogEntry(fieldname,existingvalue,newvalue,elementindex,isnew)
            if nargin>0
                obj.FieldName=fieldname;
                obj.ExistingValue=existingvalue;
                obj.NewValue=newvalue;
                obj.ElementIndex=elementindex;
                obj.isNew=isnew;
            end
        end
    end

end

