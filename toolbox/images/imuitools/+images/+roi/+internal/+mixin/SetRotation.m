classdef(Abstract)SetRotation<handle




    properties(Dependent)










RotationAngle

    end

    properties(Hidden,Access=protected)
        ThetaInternal double=0;
    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
CachedTheta
        SnapToAngleInternal=false;
StartAngle
StartCorner
StartTheta
        SnapAngleIncrement=15;
    end

    methods(Hidden,Access=protected)


        function[x,y]=rotateLineData(self,x,y,centerX,centerY,positiveFlag)




            if positiveFlag
                theta=self.ThetaInternal;
            else
                theta=-self.ThetaInternal;
            end

            rotationMatrix=[cosd(theta),sind(theta);...
            -sind(theta),cosd(theta)];

            pos=rotationMatrix*[(x-centerX);(y-centerY)];

            x=(pos(1,:)+centerX)';
            y=(pos(2,:)+centerY)';

        end


        function theta=findAngle(self,pos)

            [~,~,newAngle]=images.roi.internal.getAngle(pos);

            if isempty(self.StartAngle)
                self.StartAngle=newAngle;
                self.StartTheta=self.ThetaInternal;
            end

            theta=self.StartTheta+(newAngle-self.StartAngle);

            if self.SnapToAngleInternal
                theta=self.SnapAngleIncrement*round(theta/self.SnapAngleIncrement);
            end

            if theta<0
                theta=360+theta;
            elseif theta>360
                theta=theta-360;
            end

        end


        function symbol=getRotatedSymbol(self,theta)




            hAx=ancestor(self,'axes');

            theta=theta+self.ThetaInternal;

            if theta>=360
                theta=theta-360;
            end

            theta=round(theta/45);

            switch theta

            case{0,4,8}
                if isempty(hAx)
                    symbol='north';
                else
                    symbol='east';
                end
            case{1,5}
                if isempty(hAx)||strcmp(hAx.XDir,hAx.YDir)
                    symbol='NW';
                else
                    symbol='NE';
                end
            case{2,6}
                if isempty(hAx)
                    symbol='east';
                else
                    symbol='north';
                end
            case{3,7}
                if isempty(hAx)||strcmp(hAx.XDir,hAx.YDir)
                    symbol='NE';
                else
                    symbol='NW';
                end
            end

        end

    end

    methods





        function set.RotationAngle(self,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','finite','nonsparse'},...
            mfilename,'RotationAngle')



            val=mod(val,360);

            if self.ThetaInternal~=val
                self.ThetaInternal=val;

                update(self);
            end
        end

        function val=get.RotationAngle(self)
            val=self.ThetaInternal;
        end

    end

end