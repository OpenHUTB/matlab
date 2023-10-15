classdef Statistic

    properties
        Data = [  ]
        Name( 1, 1 )string = ""
        Description( 1, 1 )string = ""
    end

    methods
        function obj = Statistic( args )
            arguments
                args.Data = [  ]
                args.Name( 1, 1 )string = ""
                args.Description( 1, 1 )string = ""
            end
            obj.Data = args.Data;
            obj.Name = args.Name;
            obj.Description = args.Description;
        end
    end

end
