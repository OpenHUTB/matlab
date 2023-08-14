


classdef Objective



    enumeration
        None,SpeedOptimized,AreaOptimized,CompileOptimized
    end

    methods

        function val=getObjectiveName(obj)
            switch obj
            case hdlcoder.Objective.None
                val='None';
            case hdlcoder.Objective.CompileOptimized
                val='Compile Optimized';
            case hdlcoder.Objective.AreaOptimized
                val='Area Optimized';
            case hdlcoder.Objective.SpeedOptimized
                val='Speed Optimized';
            end
        end

        function val=getObjectiveFromName(obj,name)
            switch name
            case 'None'
                val=hdlcoder.Objective.None;
            case 'Compile Optimized'
                val=hdlcoder.Objective.CompileOptimized;
            case 'CompileOptimized'
                val=hdlcoder.Objective.CompileOptimized;
            case 'Area Optimized'
                val=hdlcoder.Objective.AreaOptimized;
            case 'AreaOptimized'
                val=hdlcoder.Objective.AreaOptimized;
            case 'Speed Optimized'
                val=hdlcoder.Objective.SpeedOptimized;
            case 'SpeedOptimized'
                val=hdlcoder.Objective.SpeedOptimized;
            otherwise
                val=hdlcoder.Objective.None;
            end
        end

        function val=getObjectiveList(obj)
            val={'Area Optimized','Compile Optimized','None','Speed Optimized'};
        end
    end

end


