classdef ( Sealed )TypeStoreBuilder < handle

    properties ( SetAccess = immutable )
        TypeStore coderapp.internal.codertype.TypeStore{ mustBeScalarOrEmpty( TypeStore ) }
        MfzModel( 1, 1 )mf.zero.Model
    end

    properties ( Access = private )
        ByChecksum containers.Map
    end

    methods
        function this = TypeStoreBuilder( tsOrModel )
            arguments
                tsOrModel{ mustBeTypeStoreOrModel( tsOrModel ) } = mf.zero.Model.empty(  )
            end
            if isempty( tsOrModel )
                this.MfzModel = mf.zero.Model(  );
                this.TypeStore = coderapp.internal.codertype.TypeStore( this.MfzModel );
            elseif isa( tsOrModel, 'mf.zero.Model' )
                this.MfzModel = tsOrModel;
                this.TypeStore = coderapp.internal.codertype.TypeStore( tsOrModel );
            else
                this.MfzModel = mf.zero.getModel( tsOrModel );
                this.TypeStore = tsOrModel;
            end
            this.ByChecksum = containers.Map(  );
        end






        function [ mfzType, novel ] = addType( this, tmNode )
            arguments
                this( 1, 1 )
                tmNode( 1, 1 )codergui.internal.type.TypeMakerNode
            end

            assert( ~tmNode.TypeMaker.IsPending, 'TypeMaker must not be transacting' );
            [ mfzType, novel ] = this.internalAddType( tmNode );
        end
    end

    methods ( Access = ?codergui.internal.type.TypeMakerNode )
        function [ mfzType, novel ] = internalAddType( this, tmNode )
            checksum = tmNode.TypeChecksum;
            assert( ~isempty( checksum ), 'Node %d must have a checksum', tmNode.Id );

            if isKey( this.ByChecksum, checksum )
                mfzType = this.ByChecksum( checksum );
                novel = false;
            else
                mfzType = tmNode.getCoderType( this );
                this.ByChecksum( checksum ) = mfzType;
                this.TypeStore.Types.add( mfzType );
                novel = true;
            end
        end
    end
end


function mustBeTypeStoreOrModel( arg )
mustBeScalarOrEmpty( arg );
if ~isempty( arg )
    mustBeA( arg, [ "coderapp.internal.codertype.TypeStore", "mf.zero.Model" ] );
end
end


