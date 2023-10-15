classdef filteredVMDWorkspace < internal.matlab.variableeditor.MLWorkspace & internal.matlab.variableeditor.MLNamedVariableObserver & dynamicprops






    properties
        currentVariables = {  };
        fieldNames;
        reqLength;
    end

    methods
        function this = filteredVMDWorkspace( fieldName, reqLength )
            this@internal.matlab.variableeditor.MLNamedVariableObserver( 'who', 'base' );
            this.fieldNames = fieldName;
            this.reqLength = reqLength;
            this.updateVariables( evalin( 'base', 'who' ) );
        end

        function s = who( this )
            s = this.currentVariables;
        end

        function val = getPropValue( ~, propName )
            val = evalin( 'base', propName );
        end

        function clearOldProps( this )
            for i = 1:length( this.currentVariables )
                propName = this.currentVariables{ i };
                if isprop( this, propName )
                    p = findprop( this, propName );
                    delete( p );
                end
            end
            this.currentVariables = {  };
        end

        function variableChanged( this, options )
            arguments
                this
                options.newData = [  ];
                options.newSize = 0;
                options.newClass = '';
                options.eventType = internal.matlab.datatoolsservices.WorkspaceEventType.UNDEFINED;
            end
            this.updateVariables( options.newData );
        end

        function updateVariables( this, variables )
            if ~iscell( variables )
                return ;
            end


            this.clearOldProps(  );


            for i = 1:length( variables )
                propName = variables{ i };
                value = evalin( 'base', propName );


                if this.isValidVariable( propName, value )
                    this.currentVariables{ end  + 1 } = propName;
                    if ~isprop( this, propName )
                        p = this.addprop( propName );
                        p.Dependent = true;
                        p.GetMethod = @( this )( this.getPropValue( propName ) );
                    end
                end
            end
            this.notify( 'VariablesChanged' );
        end

        function isValid = isValidVariable( this, ~, value )
            isValid = false;
            funcHandle = @( x )( isa( x, 'double' ) || isa( x, 'single' ) ) ...
                && ~any( isnan( x ), 'all' ) && all( isfinite( x ), 'all' );

            if this.fieldNames == "InitialLM"
                isValid = funcHandle( value ) ...
                    && ( ( isvector( value ) && ( length( value ) == this.reqLength ) ) ...
                    || isscalar( value ) );
            elseif this.fieldNames == "InitialIMFs"
                isValid = funcHandle( value ) && isreal( value ) ...
                    && ( ( ismatrix( value ) && isequal( size( value ), this.reqLength ) ) ...
                    || ( isvector( value ) && isequal( length( value ), this.reqLength( 1 ) ) ) ...
                    || isscalar( value ) );
            elseif this.fieldNames == "CentralFrequencies"
                isValid = funcHandle( value ) ...
                    && ( ( isvector( value ) && ( length( value ) == this.reqLength ) ) ...
                    || isscalar( value ) ) ...
                    && all( value <= 0.5 ) && all( value >= 0 );
            end
        end
    end
end

