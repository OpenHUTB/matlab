classdef RBTReader<robotics.manip.internal.InternalAccess

    properties
    end


    methods

        function Visuals=getVisuals(obj,RBT)
            VInt=RBT.BodyInternal.VisualsInternal;
            N=length(VInt);
            if N>0
                for i=1:N
                    Visuals{i}.Vertices=VInt{i}.Vertices;
                    Visuals{i}.Faces=VInt{i}.Faces;
                    Visuals{i}.Tform=VInt{i}.Tform;
                    Visuals{i}.Color=VInt{i}.Color;
                end
            else
                Visuals=[];
            end
        end
        function[Loc,Rot]=getTransform(obj,RBT)
            try
                Loc=RBT.Joint.JointToParentTransform(1:3,4)';
                Rot=RBT.Joint.JointToParentTransform(1:3,1:3);

                if RBT.Joint.HomePosition~=0
                    Rot=Rot*sim3d.internal.Math.rot321(RBT.Joint.JointAxis*RBT.Joint.HomePosition*180/pi);
                end
                if~isequal(RBT.Joint.ChildToJointTransform,eye(4))
                    Loc=Loc+RBT.Joint.ChildToJointTransform(1:3,4)';
                    Rot=Rot*RBT.Joint.ChildToJointTransform(1:3,1:3);
                end
                Rot=sim3d.internal.Math.decomp321(Rot);
            catch
                Loc=[0,0,0];
                Rot=[0,0,0];
            end
        end

    end

end