classdef Actors<handle

    properties
        ID uint8
        Next=sim3d.utils.Actors.empty
        Prev=sim3d.utils.Actors.empty
ActorTag
Blk
    end


    methods
        function obj=Actors(ID,Prev,Next,Blk,ActorTag)
            obj.Next=Next;
            obj.Prev=Prev;
            obj.ID=ID;
            obj.Blk=Blk;
            obj.ActorTag=ActorTag;
        end
    end
end
