classdef StyleType




    properties
StyleClass
    end
    methods
        function c=StyleType(class)
            c.StyleClass=class;
        end
    end
    enumeration
        Modified('IsModified')
        Deleted('IsDeleted')
        Inserted('IsInserted')
        Base('Base')
        Mine('Mine')
        Theirs('Theirs')
        Conflicted('Conflicted')
        ModifiedChildren('ModifiedChildren')
    end
end
