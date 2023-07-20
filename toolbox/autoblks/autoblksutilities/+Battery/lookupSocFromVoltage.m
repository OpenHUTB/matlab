function SOC=lookupSocFromVoltage(Voltage,SocVector,EmVector)






























    narginchk(3,3);
    validateattributes(Voltage,{'numeric'},{'vector','positive','finite','nonnan'});
    validateattributes(EmVector,{'numeric'},{'vector','positive','finite','nonnan'});
    validateattributes(SocVector,{'numeric'},{'vector','nonnan',...
    '<=',1,'>=',0,'size',size(EmVector)});


    SOC=interp1(EmVector(:),SocVector(:),Voltage(:),'linear','extrap');
