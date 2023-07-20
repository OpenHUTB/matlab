classdef StateVariable




    properties
Parent
        Minimum(1,1)double=25
        Maximum(1,1)double=25
    end
    methods
        function value=getCData(obj,points)
            zMin=points.getZMin;
            zMax=points.getZMax;
            value=cell(size(points));
            for pointIdx=1:length(points)
                thesePoints=points(pointIdx);
                deltaZ=zMax-zMin;
                if deltaZ==0&&zMax==0
                    cData=thesePoints.ZData;
                elseif deltaZ==0
                    cData=thesePoints.ZData./zMax;
                else
                    cData=(thesePoints.ZData-zMin)./deltaZ;
                end
                deltaT=obj.Maximum-obj.Minimum;
                value{pointIdx}=obj.Minimum+(cData.*deltaT);
            end
        end
    end
end

