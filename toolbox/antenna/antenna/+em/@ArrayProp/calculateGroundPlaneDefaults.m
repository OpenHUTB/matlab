function gndDim=calculateGroundPlaneDefaults(obj,shape)


    switch shape
    case 'Rectangle'
        Ltemp=nan;
        Wtemp=nan;
        for i=1:numel(obj.Element)
            Ltemp=max(obj.Element(i).GroundPlaneLength,Ltemp);
            Wtemp=max(obj.Element(i).GroundPlaneWidth,Wtemp);
        end
        L=Ltemp;
        W=Wtemp;
    case 'Circle'
        Rtemp=nan;
        for i=1:numel(obj.Element)
            Rtemp=max(obj.Element(i).GroundPlaneRadius,Rtemp);
        end
        if isa(obj.Element,'reflectorCircular')
            L=Rtemp;
            W=Rtemp;
        else
            L=2*Rtemp;
            W=2*Rtemp;
        end
    end


    if isa(obj,'linearArray')
        arraysize=[1,obj.NumElements];

        gndPlaneLength=L*arraysize(2);
        gndPlaneWidth=W*arraysize(1);
        gndDim=[gndPlaneLength,gndPlaneWidth];





    elseif isa(obj,'rectangularArray')
        arraysize=obj.Size;

        gndPlaneLength=L*arraysize(2);
        gndPlaneWidth=W*arraysize(1);
        gndDim=[gndPlaneLength,gndPlaneWidth];





    else
        gndPlaneLength=2*max(obj.Radius)+L;
        gndPlaneWidth=2*max(obj.Radius)+W;
        if L==0
            gndPlaneLength=0;
        end
        if W==0
            gndPlaneWidth=0;
        end
        gndDim=[gndPlaneLength,gndPlaneWidth];
        if isa(obj.Element,'reflectorCircular')
            gndDim=gndDim/1.5;
        end
    end

end