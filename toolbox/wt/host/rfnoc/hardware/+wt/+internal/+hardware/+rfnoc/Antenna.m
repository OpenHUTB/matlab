classdef Antenna<handle




    properties
Name
IsRx
IsTx
Subdev
Block
Channel
InUse
    end

    methods
        function obj=Antenna(name,subdev,isrx,istx,block,channel)
            obj.Name=name;
            obj.IsRx=isrx;
            obj.IsTx=istx;
            obj.Subdev=subdev;
            obj.Block=block;
            obj.Channel=channel;
            obj.InUse=false;
        end
    end
end
