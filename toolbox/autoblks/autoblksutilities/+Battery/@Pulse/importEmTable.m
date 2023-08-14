function importEmTable(obj,SocVector,EmVector)























    narginchk(3,3);
    validateattributes(EmVector,{'numeric'},{'vector','positive','finite','nonnan'});
    validateattributes(SocVector,{'numeric'},{'vector','nonnan',...
    '<=',1,'>=',0,'size',size(EmVector)});


    for pIdx=1:numel(obj)


        Param=obj(pIdx).Parameters;


        NewSOC=Param.SOC;


        NewEm=interp1(SocVector,EmVector,NewSOC,'linear','extrap');


        Param.Em=NewEm;


        obj(pIdx).Parameters=Param;

    end

