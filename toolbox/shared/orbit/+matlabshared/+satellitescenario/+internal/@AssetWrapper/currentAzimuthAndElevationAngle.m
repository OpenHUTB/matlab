function[az,el,r]=currentAzimuthAndElevationAngle(obj,target,varargin)%#codegen






    coder.allowpcode('plain');




    if nargin==2
        isFrameNED=true;
    else
        isFrameNED=varargin{1};
    end



    if~isnumeric(target)&&obj==target
        el=0;
        az=0;
        r=0;
        return
    end


    objITRF=obj.pPositionITRF;


    if~isnumeric(target)
        targetITRF=target.pPositionITRF;
    else
        targetITRF=matlabshared.orbit.internal.Transforms.geographic2itrf([target(1)*pi/180;target(2)*pi/180;target(3)]);
    end


    relativePositionITRF=targetITRF-objITRF;



    if isFrameNED
        transformationMatrix=...
        matlabshared.orbit.internal.Transforms.itrf2nedTransform([obj.pLatitude*pi/180;...
        obj.pLongitude*pi/180;obj.pAltitude]);
    else
        transformationMatrix=obj.pItrf2BodyTransform;
    end


    relativePositionNED=transformationMatrix*relativePositionITRF;


    x=relativePositionNED(1);
    y=relativePositionNED(2);
    z=relativePositionNED(3);


    r=norm(relativePositionNED);

    if r==0

        az=0;
        el=0;
    else


        el=asin(max(min(-(z/r),1),-1))*180/pi;
        az=mod(atan2(y,x),2*pi)*180/pi;
    end
end


