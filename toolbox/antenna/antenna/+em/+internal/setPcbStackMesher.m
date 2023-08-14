function setPcbStackMesher(meshertype,persist)














    narginchk(1,2);
    if nargin==1
        persist=true;
    end

    s=settings;

    if strcmpi(meshertype,'R2021b')

        if persist
            s.antenna.Mesher.UsePCBStackR2021bEngine.PersonalValue=true;
        else
            s.antenna.Mesher.UsePCBStackR2021bEngine.TemporaryValue=true;
        end

    elseif strcmpi(meshertype,'preR2021b')

        if persist
            s.antenna.Mesher.UsePCBStackR2021bEngine.PersonalValue=false;
        else
            s.antenna.Mesher.UsePCBStackR2021bEngine.TemporaryValue=false;
        end

    else
        error(message('antenna:antennaerrors:Unsupported',meshertype,'mesher type: Choose either R2021b or preR2021b'));

    end