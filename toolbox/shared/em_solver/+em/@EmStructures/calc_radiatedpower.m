function RadiatedPower=calc_radiatedpower(obj,freq,R)






    sphereChoice='low';
    if isa(obj,'em.Array')
        if getTotalArrayElems(obj)>100
            sphereChoice='high';
        end
    end
    if strcmpi(class(obj),'sectorInvertedAmos')
        sphereChoice='high';
    end
    [Points,n_s,Area_s]=generateRadiationSphere(R,...
    obj.Tilt,obj.TiltAxis,sphereChoice);
    [E,H]=calcEHfields(obj,freq,Points,...
    0,0,[],[]);
    Poynting=0.5*real(cross(E,conj(H)));
    RadiatedPower=R^2*sum(abs(dot(n_s,Poynting)).*Area_s);
    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP
        RadiatedPower=0.5*RadiatedPower;
    end
    clear Area_s Center_s n_s p_s t_s

end
function[Points,n_s,Area_s]=generateRadiationSphere(R,Tilt,TiltAxis,sphereChoice)

    switch sphereChoice
    case 'low'

        load([matlabroot,('/toolbox/antenna/antenna/+em/@FieldAnalysisWithFeed/spherenew.mat')]);

    case 'high'

        load([matlabroot,('/toolbox/antenna/antenna/+em/@FieldAnalysisWithFeed/spherenew15000.mat')]);
    end


    if any(Tilt~=0)
        tempTilt=Tilt;
        numTilt=numel(Tilt);
        tempAxis=TiltAxis;


        em.internal.checktiltaxisconsistency(tempTilt,tempAxis)

        p_s=em.internal.orientgeom(p_s,tempTilt,numTilt,tempAxis);%#ok<NODEF>
        TrianglesTotal=length(t_s);

        Area_s=zeros(1,TrianglesTotal);
        Center_s=zeros(3,TrianglesTotal);
        n_s=zeros(3,TrianglesTotal);
        for m=1:TrianglesTotal
            N=t_s(1:3,m);
            Vec1=p_s(:,N(1))-p_s(:,N(2));
            Vec2=p_s(:,N(3))-p_s(:,N(2));
            crossval=cross(Vec1,Vec2);
            Area_s(m)=norm(crossval)/2;
            n_s(:,m)=crossval/norm(crossval);
            Center_s(:,m)=1/3*sum(p_s(:,N),2);
        end
    end
    Points=R*Center_s;
end
