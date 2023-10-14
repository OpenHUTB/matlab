classdef WidgetAction < handle

    properties ( Dependent )
        Source
        ID
    end

    properties ( Access = private )
        MF0DataBinding
    end

    methods ( Access = ?metric.dashboard.widgets.Widget )
        function obj = WidgetAction( databinding )
            obj.MF0DataBinding = databinding;
        end
    end

    methods

        function src = get.Source( this )
            src = this.MF0DataBinding.Source;
        end

        function set.Source( this, src )
            arguments
                this
                src{ mustBeMember( src, { 'ResultService', 'MATLAB' } ) }
            end
            metric.dashboard.Verify.ScalarCharOrString( src );
            this.MF0DataBinding.Source = char( src );
        end


        function id = get.ID( this )
            id = this.MF0DataBinding.ID;
        end

        function set.ID( this, id )
            metric.dashboard.Verify.ScalarCharOrString( id );
            this.MF0DataBinding.ID = char( id );
        end


        function remove( this )
            this.MF0DataBinding.destroy(  );
        end


        function verify( this )
            if isempty( this.MF0DataBinding.ID ) && isempty( strtrim( this.MF0DataBinding.ID ) )
                error( message( 'dashboard:uidatamodel:WidgetActionNoID' ) );
            end
            if isempty( this.MF0DataBinding.Source )
                error( message( 'dashboard:uidatamodel:WidgetActionNoSrc' ) );
            end
        end

    end
end



