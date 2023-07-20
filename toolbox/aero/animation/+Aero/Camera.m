classdef(CompatibleInexactProperties=true)Camera...
    <matlab.mixin.SetGet&matlab.mixin.Copyable












    properties(Transient,SetObservable)
        CoordTransformFcn=@nullCoordTransform;
        PositionFcn=@doFirstOrderChaseCameraDynamics;
        Position=[-150,-50,0];
        Offset=[-150,-50,0];
        AimPoint=[0,0,0];
        UpVector=[0,0,-1];
        ViewAngle=3;
        ViewExtent=[-50,50];
        xlim=[-50,50];
        ylim=[-50,50];
        zlim=[-50,50];
        PrevTime=0;
        UserData=[];
    end


    methods
        function h=Camera(varargin)


            if~builtin('license','test','Aerospace_Toolbox')
                error(message('aero:licensing:noLicenseCam'));
            end

            if~builtin('license','checkout','Aerospace_Toolbox')
                return;
            end

        end

    end

    methods

        function update(h,Tnew,Bodies)



            h.PositionFcn(Tnew,Bodies,h);



            h.PrevTime=Tnew;

        end

    end

end



function[nullTrans,nullRot]=nullCoordTransform(trans,rot)





    nullTrans=trans;
    nullRot=rot;

end
