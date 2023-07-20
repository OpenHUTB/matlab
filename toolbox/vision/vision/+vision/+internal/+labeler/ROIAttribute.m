

classdef ROIAttribute
    properties
LabelName
        SublabelName=''


        Type attributeType


Name


Value


Description
    end

    methods

        function this=ROIAttribute(labelName,sublabelName,name,type,val,description)



            this.Name=name;
            this.Type=type;
            this.Value=val;
            this.Description=description;

            this.LabelName=labelName;
            this.SublabelName=sublabelName;
        end
    end
end