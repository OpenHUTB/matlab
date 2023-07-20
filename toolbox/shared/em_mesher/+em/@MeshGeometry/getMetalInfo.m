function[name,antennaColor]=getMetalInfo(metalname)

    if isempty(metalname)
        metalname='PEC';
    end

    if strcmpi(metalname,'Aluminium')
        antennaColor=[132,135,137]/255;
        name='Aluminium';
    elseif strcmpi(metalname,'copper')
        antennaColor=[154,115,51]/255;
        name='Copper';
    elseif strcmpi(metalname,'silver')
        antennaColor=[192,192,192]/255;
        name='Silver';
    elseif strcmpi(metalname,'gold')
        antennaColor=[212,175,55]/255;
        name='Gold';
    elseif strcmpi(metalname,'zinc')
        antennaColor=[145,136,139]/255;
        name='Zinc';
    elseif strcmpi(metalname,'lead')
        antennaColor=[46,53,56]/255;
        name='Lead';
    elseif strcmpi(metalname,'tungsten')
        antennaColor=[255,197,143]/255;
        name='Tungsten';
    elseif strcmpi(metalname,'iron')
        antennaColor=[192,204,204]/255;
        name='Iron';
    elseif strcmpi(metalname,'PEC')
        antennaColor=[223,185,58]/255;
        name='PEC';
    elseif strcmpi(metalname,'Steel')
        antennaColor=[67,70,75]/255;
        name='Steel';
    elseif strcmpi(metalname,'Brass')
        antennaColor=[181,166,166]/255;
        name='Brass';
    else
        antennaColor=[184,115,51]/255;
        name=metalname;
    end
end