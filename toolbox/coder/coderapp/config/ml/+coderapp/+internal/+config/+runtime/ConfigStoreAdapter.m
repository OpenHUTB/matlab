classdef ( Sealed )ConfigStoreAdapter < handle

    properties ( SetAccess = immutable, Transient )
        Configuration coderapp.internal.config.Configuration
    end

    properties ( SetAccess = ?coderapp.internal.config.Configuration, GetAccess = private, Transient )
        Store coderapp.internal.ext.ConfigStore
    end

    properties ( SetAccess = ?coderapp.internal.config.runtime.Configuration, Dependent, Transient )
        Dirty logical
    end

    properties ( Access = private, Transient )
        Suppress logical = false
    end

    methods
        function this = ConfigStoreAdapter( configuration )
            arguments
                configuration( 1, 1 )coderapp.internal.config.Configuration
            end

            this.Configuration = configuration;
        end

        function dirty = get.Dirty( this )
            dirty = this.Configuration.State.Dirty;
        end

        function set.Dirty( this, dirty )
            if dirty ~= this.Configuration.State.Dirty
                this.Configuration.State.Dirty = dirty;
                this.Configuration.notify( 'DirtyStateChanged' );
            end
        end

        function set.Store( this, store )
            this.Store = store;
            this.Dirty = false;
        end

        function has = hasEntries( this )
            has = this.Store.Values.Size > 0;
        end
    end

    methods ( Access = ?coderapp.internal.config.runtime.ParamNodeAdapter )
        function removeValue( this, paramNode )
            arguments
                this( 1, 1 )
                paramNode( 1, 1 )coderapp.internal.config.runtime.ParamNodeAdapter
            end

            if this.Suppress || paramNode.Transient
                return
            end
            entry = this.Store.Values.getByKey( paramNode.Key );
            if ~isempty( entry )
                entry.destroy(  );
                this.Dirty = true;
            end
        end

        function setValue( this, paramNode, value )
            arguments
                this( 1, 1 )
                paramNode( 1, 1 )coderapp.internal.config.runtime.ParamNodeAdapter
                value
            end

            if this.Suppress || paramNode.Transient
                return
            end
            entry = this.Store.Values.getByKey( paramNode.Key );
            if isempty( entry )
                entry = this.Store.createIntoValues( struct( 'Key', paramNode.Key ) );
            end
            if isempty( entry.Data )
                entry.Data = paramNode.newValueObject(  );
            end
            entry.Data.Value = value;
            this.Dirty = true;
        end
    end

    methods ( Access = ?coderapp.internal.config.Configuration )
        function loadFrom( this, otherStore )
            arguments
                this
                otherStore( 1, 1 )coderapp.internal.ext.ConfigStore
            end

            this.doApply( Store = otherStore, Suppress = false );
        end

        function apply( this )
            this.doApply(  );
        end
    end

    methods ( Access = private )
        function doApply( this, opts )
            arguments
                this
                opts.Store = this.ConfigStore
                opts.Suppress = true
            end

            params = this.Configuration.ParamAdapters;
            if isempty( params )
                return
            end

            valueMap = opts.Store.Values;
            this.Suppress = opts.Suppress;
            this.Configuration.finishApplyConfigStore( params, @visit );
            this.Suppress = false;

            function abort = visit( node, triggerNodes )
                abort = false;
                if ~isempty( triggerNodes )
                    node.updateNode( triggerNodes );
                end
                if node.NodeType == 'Param' %#ok<BDSCA>
                    if ~node.Transient && ~node.Derived
                        entry = valueMap.getByKey( node.Key );
                        if ~isempty( entry )
                            node.doSetValue( entry.Data.Value, External = true, Validate = false, IgnoreEnabled = true );
                            return
                        end
                    end
                    node.resetParam(  );
                end
            end
        end
    end
end


