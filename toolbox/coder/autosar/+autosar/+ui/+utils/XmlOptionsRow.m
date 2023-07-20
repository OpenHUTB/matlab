classdef XmlOptionsRow<handle






    properties
        Items;


        IsVisible logical=true;
    end

    methods
        function obj=XmlOptionsRow(items,isVisible)
            if~iscell(items)
                items={items};
            end
            obj.Items=items;
            obj.IsVisible=isVisible;
        end
    end
end
