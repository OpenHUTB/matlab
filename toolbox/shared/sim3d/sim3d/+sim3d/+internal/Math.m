classdef Math<handle


    methods(Static)


        function OutLoc=convertLoc(InLoc,InSys,OutSys)
            if strcmp(InSys,OutSys)
                OutLoc=InLoc;
            else
                InLoc=sim3d.internal.Math.posToUnreal(InLoc,InSys);
                OutLoc=sim3d.internal.Math.posFromUnreal(InLoc,OutSys);
            end
        end


        function OutRot=convertRot(InRot,InSys,OutSys)
            if strcmp(InSys,OutSys)
                OutRot=InRot;
            else
                InRot=sim3d.internal.Math.rotToUnreal(InRot,InSys);
                OutRot=sim3d.internal.Math.rotFromUnreal(InRot,OutSys);
            end
        end


        function M=rot321(XYZ)
            c=cosd(XYZ);
            s=sind(XYZ);

            X=[1,0,0;0,c(1),-s(1);0,s(1),c(1)];
            Y=[c(2),0,s(2);0,1,0;-s(2),0,c(2)];
            Z=[c(3),-s(3),0;s(3),c(3),0;0,0,1];
            M=Z*Y*X;
        end


        function M=mat2unr(M)
            M=M'.*[1,1,-1;1,1,-1;-1,-1,1];
        end


        function M=rotAA(Axis,Angle)
            if any(Axis(:))
                Axis=Axis/norm(Axis);
                cB=cosd(Angle);
                sB=sind(Angle);
                M=zeros(3);

                M(1,1)=cB+Axis(1)*Axis(1)*(1-cB);
                M(1,2)=Axis(1)*Axis(2)*(1-cB)-Axis(3)*sB;
                M(1,3)=Axis(1)*Axis(3)*(1-cB)+Axis(2)*sB;

                M(2,1)=Axis(1)*Axis(2)*(1-cB)+Axis(3)*sB;
                M(2,2)=cB+Axis(2)*Axis(2)*(1-cB);
                M(2,3)=Axis(2)*Axis(3)*(1-cB)-Axis(1)*sB;

                M(3,1)=Axis(1)*Axis(3)*(1-cB)-Axis(2)*sB;
                M(3,2)=Axis(2)*Axis(3)*(1-cB)+Axis(1)*sB;
                M(3,3)=cB+Axis(3)*Axis(3)*(1-cB);
            else
                M=eye(3);
            end
        end


        function XYZ=decomp321(R)
            sy=sqrt(R(3,2)^2+R(3,3)^2);
            if sy<1e-3


            end
            x=atan2(R(3,2),R(3,3));
            y=atan2(-R(3,1),sy);
            z=atan2(R(2,1),R(1,1));
            XYZ=[x,y,z]*180/pi;
        end


        function outXYZ=rotToUnreal(inXYZ,CoordinateSystem)
            switch CoordinateSystem
            case 'unreal'

                outXYZ=inXYZ;
            case 'matlab'

                outXYZ=[inXYZ(:,1),-inXYZ(:,2),-inXYZ(:,3)];
            case 'vrml'

                outXYZ=[inXYZ(:,1),inXYZ(:,3),-inXYZ(:,2)];
            case 'lhcs'

                outXYZ=inXYZ;
            case 'aerospace'

                outXYZ=inXYZ;
            end
        end


        function outXYZ=posToUnreal(inXYZ,CoordinateSystem)
            switch CoordinateSystem
            case 'unreal'
                outXYZ=inXYZ;
            case 'matlab'
                outXYZ=inXYZ*[1,0,0;0,-1,0;0,0,1];
            case 'vrml'
                outXYZ=inXYZ*[1,0,0;0,0,1;0,1,0];

            case 'lhcs'
                outXYZ=inXYZ*[-1,0,0;0,-1,0;0,0,1];
            case 'aerospace'
                outXYZ=inXYZ*[1,0,0;0,1,0;0,0,-1];
            end
        end


        function outXYZ=rotFromUnreal(inXYZ,CoordinateSystem)
            switch CoordinateSystem
            case 'unreal'
                outXYZ=inXYZ;
            case 'matlab'
                outXYZ=[inXYZ(:,1),-inXYZ(:,2),-inXYZ(:,3)];
            case 'vrml'
                outXYZ=[inXYZ(:,1),-inXYZ(:,3),inXYZ(:,2)];
            case 'lhcs'
                outXYZ=inXYZ;
            case 'aerospace'
                outXYZ=inXYZ;
            end
        end


        function outXYZ=posFromUnreal(inXYZ,CoordinateSystem)
            switch CoordinateSystem
            case 'unreal'
                outXYZ=inXYZ;
            case 'matlab'
                outXYZ=inXYZ*[1,0,0;0,-1,0;0,0,1]';
            case 'vrml'
                outXYZ=inXYZ*[1,0,0;0,0,1;0,1,0]';
            case 'lhcs'
                outXYZ=inXYZ*[-1,0,0;0,-1,0;0,0,1]';
            case 'aerospace'
                outXYZ=inXYZ*[1,0,0;0,1,0;0,0,-1];
            end
        end


        function Hex=colorToHex(Color)
            Color=int32(Color*255);
            Color(Color<0)=0;
            Color(Color>255)=255;
            Hex=reshape(dec2hex(Color,2)',1,6);
        end


        function N=normRows(M)
            N=M./sqrt(sum(M.^2,2));
        end

    end

end
