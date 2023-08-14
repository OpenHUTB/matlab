classdef roughness_spec<int32




    enumeration
        commercial_pipe(1)
        steel_wrought_iron(2)
        galvanized_steel_iron(3)
        cast_iron(4)
        custom(5)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('commercial_pipe')='Commercially smooth brass, lead, copper, or plastic pipe : 1.52 um';
            map('steel_wrought_iron')='Steel and wrought iron : 46 um';
            map('galvanized_steel_iron')='Galvanized iron or steel : 152 um';
            map('cast_iron')='Cast iron : 259 um';
            map('custom')='Custom';
        end
    end
end