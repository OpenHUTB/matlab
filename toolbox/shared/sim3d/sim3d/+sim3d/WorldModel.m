classdef ( Hidden = true )WorldModel < handle

    properties
        Reader = [  ]
        Writer = [  ]
        Model = [  ]
        Name = ""
    end

    methods
        function self = WorldModel( name )
            self.clear(  );
            self.Name = name;
        end

        function delete( self )
            if ~isempty( self.Reader )
                self.Reader.delete(  );
            end
            if ~isempty( self.Writer )
                self.Writer.delete(  );
            end
        end

        function release( self )
            if ~isempty( self.Reader )
                self.Reader.delete(  );
                self.Reader = [  ];

            end
            if ~isempty( self.Writer )
                self.Writer.delete(  );
                self.Writer = [  ];
            end
        end

        function clear( self )
            self.Model = [  ];
            while ~isempty( self.receive(  ) )
            end
        end

        function setup( self )
            if ~isempty( self.Writer )
                self.Writer.delete(  );
            end
            if ~isempty( self.Reader )
                self.Reader.delete(  );
            end
            self.Reader = sim3d.io.Subscriber( self.Name + "_IN", 'QueueDepth', sim3d.World.MaxActorLimit );
        end

        function send( self )
            if ~isempty( self.Model )
                if ~isempty( self.Writer )
                    self.Writer.delete(  );
                end
                self.Writer = sim3d.io.Publisher( self.Name + "_OUT", 'Packet', self.Model );
                success = self.Writer.send( self.Model );
                if ~success
                    error( message( "shared_sim3d:sim3dWorld:ErrorPublishingWorldModel", self.Name ) );
                end
            end
        end

        function model = receive( self )
            model = [  ];
            if ~isempty( self.Reader )
                model = self.Reader.receive(  );
            end
        end

        function add( self, element, value, queue )
            arguments
                self sim3d.WorldModel
                element( 1, 1 )string
                value( 1, 1 )struct
                queue( 1, 1 )logical = false
            end
            if ~isempty( value )
                if ~isfield( self.Model, element )
                    self.Model.( element ) = value;
                else
                    if queue
                        try
                            elements = self.Model.( element );
                            elements( end  + 1 ) = value;
                            self.Model.( element ) = elements;
                        catch e
                            error( message( "shared_sim3d:sim3dWorld:ErrorPublishingWorldModel", self.Name ) );
                        end
                    else
                        self.Model.( element ) = value;
                    end
                end
            end
        end
    end
end


