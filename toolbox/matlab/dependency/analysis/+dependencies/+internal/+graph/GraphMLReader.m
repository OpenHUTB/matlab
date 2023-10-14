classdef GraphMLReader < dependencies.internal.graph.GraphReader

    properties ( Constant )
        Extensions = ".graphml";
    end

    methods

        function graph = read( ~, file, root )
            arguments
                ~
                file( 1, 1 )string
                root( 1, 1 )string = "";
            end

            graph = dependencies.internal.graph.readGraphML( file, root );
        end

    end

end

