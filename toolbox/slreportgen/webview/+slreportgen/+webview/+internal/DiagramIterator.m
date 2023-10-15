classdef DiagramIterator < handle

    properties ( Access = private )
        Stack
        Top = 0
    end

    methods
        function this = DiagramIterator( container )
            arguments
                container{ mustBeA( container, [  ...
                    "slreportgen.webview.internal.Diagram",  ...
                    "slreportgen.webview.internal.Model",  ...
                    "slreportgen.webview.internal.Project" ] ) }
            end

            if isa( container, "slreportgen.webview.internal.Diagram" )
                this.Stack = { container };
                this.Top = 1;
            elseif isa( container, "slreportgen.webview.internal.Model" )
                this.Stack = { container.RootDiagram };
                this.Top = 1;
            else
                n = numel( container.Models );
                this.Stack = cell( 1, n );
                this.Top = n;
                for i = n: - 1:1
                    this.Stack{ i } = container.Models( i ).RootDiagram;
                end
            end
        end

        function tf = hasNext( this )



            tf = ( this.Top > 0 );
        end

        function out = next( this )
            if this.Top == 0
                out = slreportgen.webview.internal.Diagram.empty(  );
            else
                out = this.Stack{ this.Top };
                this.Top = this.Top - 1;
                n = numel( out.Children );
                if ( n > 0 )
                    top = this.Top;
                    if ( top + n ) > numel( this.Stack )
                        this.Stack{ top + n } = [  ];
                    end
                    for i = 1:n
                        this.Stack{ top + i } = out.Children( n - i + 1 );
                    end
                    this.Top = top + n;
                end
            end
        end
    end
end

