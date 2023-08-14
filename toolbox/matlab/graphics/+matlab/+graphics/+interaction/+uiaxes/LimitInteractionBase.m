classdef LimitInteractionBase<handle




    properties
        Dimensions(1,1)string{mustBeMember(Dimensions,["x","y","z","xy","yz","xz","xyz"])}="xyz";
    end
end

