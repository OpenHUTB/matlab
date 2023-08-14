

classdef FrameLabel
    properties

Label


Description


Color


Group
    end

    methods

        function this=FrameLabel(label,description,group)
            this.Label=label;
            this.Description=description;
            this.Group=group;
        end
    end
end