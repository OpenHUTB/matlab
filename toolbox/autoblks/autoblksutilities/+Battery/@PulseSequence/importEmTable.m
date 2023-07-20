function importEmTable(obj,SocVector,EmVector)


























    narginchk(3,3);
    validateattributes(EmVector,{'numeric'},{'vector','positive','finite','nonnan'});
    validateattributes(SocVector,{'numeric'},{'vector','nonnan',...
    '<=',1,'>=',0,'size',size(EmVector)});


    if isempty(obj.Pulse)||isempty(obj.Parameters)
        error(['You must first run the PulseSequence.createPulses() method '...
        ,'before importing the Em table. The createPulses() method will '...
        ,'generate the required Pulse and Parameters objects within the '...
        ,'PulseSequence.']);
    end


    for psIdx=1:numel(obj)


        Param=obj(psIdx).Parameters(end);


        NewSOC=Param.SOC;


        NewEm=interp1(SocVector,EmVector,NewSOC,'linear','extrap');


        Param.Em=NewEm;


        obj(psIdx).Parameters=Param;


        obj(psIdx).Pulse.importEmTable(SocVector,EmVector);

    end

