function pnew=orientGeom(obj,p)

    tempTilt=obj.Tilt;
    numTilt=numel(obj.Tilt);
    tempAxis=obj.TiltAxis;


    checkTiltAxisConsistency(obj,tempAxis);

    pnew=em.internal.orientgeom(p,tempTilt,numTilt,tempAxis);
    if isprop(obj,'Mirror')
        if~isempty(obj.Mirror)
            for i=1:numel(obj.Mirror)
                if obj.Mirror(i)==1
                    pnew=pnew';
                    pnew(:,2)=-pnew(:,2);
                    pnew=pnew';
                end
                if obj.Mirror(i)==2
                    pnew=pnew';
                    pnew(:,1)=-pnew(:,1);
                    pnew=pnew';
                end
            end
        end
    end




















































end
