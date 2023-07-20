classdef uitreeStruct<handle
    properties






        CheckedNodes=[]

        Children=[];













        Layout=[];




        Parent=[];




        Tag='';
        Tooltip='';
        Type='uicheckboxtree';
        UserData=[];

    end

    methods

        function obj=uitreeStruct(parent)










            obj.Parent=parent;
        end
    end
end