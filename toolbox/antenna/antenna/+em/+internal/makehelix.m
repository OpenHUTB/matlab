function p=makehelix(rad,theta,S,offset)





    nameOfFunction='makehelix';
    validateattributes(rad,{'numeric'},{'nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Radius',1);
    validateattributes(theta,{'numeric'},{'vector','nonempty','real',...
    'finite','nonnan'},...
    nameOfFunction,'Angular discretization',2);
    validateattributes(S,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan'},...
    nameOfFunction,'Spacing between turns',3);
    validateattributes(offset,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan'},...
    nameOfFunction,'Distance above X-Y plane',1);





    if(isscalar(rad))
        r=rad(1);
        rout=rad(1);
    else
        r=rad(1);
        rout=rad(2);
    end

    [val,ind]=max(abs(theta));
    d=((val/2*pi)*S)*(theta(ind)/val);
    d_range=((S*theta)/2*pi);

    px=(((d_range./d).*((rout-r)))+r).*cosd(theta);
    py=(((d_range./d).*((rout-r)))+r).*sind(theta);
    pz=(S.*theta/360)+offset;

    p=[px;py;pz];
end