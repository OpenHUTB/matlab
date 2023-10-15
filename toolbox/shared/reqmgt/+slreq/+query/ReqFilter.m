classdef ReqFilter < slreq.query.Filter
    methods ( Access = protected )
        function rs = finalFilter( this, items )
            rs = slreq.data.Requirement.empty( 0, numel( items ) );
            c = 0;
            for i = 1:numel( items )
                if isa( items( i ), 'slreq.data.Requirement' )
                    c = c + 1;
                    rs( c ) = items( i );
                else
                    this.lastErrors{ end  + 1 } = struct( 'id', 'Slvnv:slreq:NonReqItemAfterFilter', 'message',  ...
                        getString( message( 'Slvnv:slreq:NonReqItemAfterFilter' ) ) );
                end
            end
            rs = rs( 1:c );
        end
    end

    methods
        function all = findAll( ~ )
            all = slreq.find( 'type', 'Requirement', '_returnType', 'dataObject' );
            all = [ all, slreq.find( 'type', 'Reference', '_returnType', 'dataObject' ) ];
            all = [ all, slreq.find( 'type', 'Justification', '_returnType', 'dataObject' ) ];
        end

        function r = apply( this, scopeObj )
            arguments
                this
                scopeObj = [  ];
            end

            this.scopeObject = scopeObj;


            this.lastErrors = struct( [  ] );

            if isempty( this.query )
                r = this.findAll(  );
            else
                apiObjs = this.evalQueryAsCellArray(  );
                dataObjs = slreq.data.ReqData.getDataObj( apiObjs );
                r = this.finalFilter( dataObjs );
            end

            this.queryResult = r;
        end
    end
end

