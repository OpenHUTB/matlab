classdef uitreenodeStruct<handle
    properties





        Children=[];






        NodeData=[];
        Parent=[];
        Tag='';
        Text='Tree Node';
        Type='uitreenode';
        UserData=[];
    end

    methods

        function obj=uitreenodeStruct(parent)









            obj.Parent=parent;
        end
    end
end