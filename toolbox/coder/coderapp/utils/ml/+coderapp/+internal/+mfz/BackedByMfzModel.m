classdef ( Abstract )BackedByMfzModel < coderapp.internal.log.Loggable & coderapp.internal.mfz.FriendOfMfzModel

    properties ( Dependent, SetAccess = protected, GetAccess = ?coderapp.internal.mfz.FriendOfMfzModel )
        MfzModel mf.zero.Model
    end

    properties ( Dependent, SetAccess = immutable )
        IsTransacting
    end

    properties ( Transient, Access = protected )
        ModelParent{ mustBeScalarOrEmpty( ModelParent ) } = [  ]
    end

    properties ( Dependent, SetAccess = immutable, GetAccess = protected )
        IsOwnModel
    end

    properties ( SetAccess = protected, GetAccess = private )
        Unswappable( 1, 1 )logical
        FollowParent( 1, 1 )logical = true
    end

    properties ( Dependent, SetAccess = immutable, GetAccess = private )
        ModelOwner coderapp.internal.mfz.BackedByMfzModel
    end

    properties ( Transient, Access = private )
        Children( 1, : )cell
        OwnModel mf.zero.Model{ mustBeScalarOrEmpty( OwnModel ) }
        Lock coderapp.internal.mfz.Lock{ mustBeScalarOrEmpty( Lock ) }
        Transaction mf.zero.Transaction{ mustBeScalarOrEmpty( Transaction ) }
        TransactionCounter = 0
        DeferredTasks = {  }
        LockOverride
    end

    methods
        function delete( this )
            for childCell = this.Children
                childCell{ 1 }.delete(  );
            end
            if this.IsOwnModel
                if ~isempty( this.Lock )
                    this.Lock.Model = [  ];
                end
                this.OwnModel.destroy(  );
            end
            if ~isempty( this.ModelParent )
                this.ModelParent.Children( cellfun( @( c )c == this, this.ModelParent.Children ) ) = [  ];
                this.ModelParent = [  ];
            end
        end

        function set.MfzModel( this, model )
            prev = this.MfzModel;
            if ( ~isempty( prev ) && ~isempty( model ) && model == prev ) || ( isempty( prev ) && isempty( model ) )
                return
            end
            this.assertSwappable(  );
            this.tryPopAll(  );
            if ~isempty( model )
                this.OwnModel = model;
                if isempty( this.Lock )
                    this.Lock = coderapp.internal.mfz.Lock( model, Locked = true );
                else
                    this.Lock.Model = model;
                end
            else
                this.OwnModel = mf.zero.Model.empty(  );
                if ~isempty( this.Lock )
                    this.Lock.Model = [  ];
                    this.Lock = [  ];
                end
            end
            this.notifyModelSwap( prev, model );
        end

        function set.ModelParent( this, modelParent )
            assert( isempty( modelParent ) || ( isscalar( modelParent ) && isa( modelParent, 'coderapp.internal.mfz.BackedByMfzModel' ) ),  ...
                'ModelParent must be a scalar BackedByMfzModel object' );
            if ~isempty( modelParent )
                this.assertSwappable(  );
            end
            this.tryPopAll(  );
            if ~isempty( this.ModelParent )
                this.ModelParent.Children( cellfun( @( x )this == x, this.ModelParent.Children ) ) = [  ];
            end
            if isempty( modelParent ) || isempty( this.ModelParent ) || ( modelParent ~= this && ~any( cellfun( @( x )this == x, this.ModelParent.Children ) ) )
                this.ModelParent = modelParent;
                if this.FollowParent && ~isempty( modelParent )
                    if isempty( modelParent.Children )
                        modelParent.Children = { this };
                    else
                        modelParent.Children{ end  + 1 } = this;
                    end
                end
            end
            if isempty( this.OwnModel ) && ~isempty( modelParent ) && ~isempty( modelParent.MfzModel )
                this.notifyModelSwap( [  ], modelParent.MfzModel );
            end
        end

        function set.Unswappable( this, unswappable )
            arguments
                this( 1, 1 )
                unswappable( 1, 1 )logical
            end

            this.Unswappable = unswappable || this.Unswappable;
        end

        function model = get.MfzModel( this )
            owner = this;
            while ~isempty( owner )
                model = owner.OwnModel;
                if ~isempty( model )
                    return
                end
                owner = owner.ModelParent;
            end
            model = mf.zero.Model.empty(  );
        end

        function yes = get.IsOwnModel( this )
            yes = ~isempty( this.OwnModel );
        end

        function owner = get.ModelOwner( this )
            if this.IsOwnModel
                owner = this;
            else
                owner = this.ModelParent;
                while ~isempty( owner )
                    if ~isempty( owner.OwnModel )
                        return
                    end
                    owner = owner.ModelParent;
                end
                error( 'No MF0 model present' );
            end
        end

        function yes = get.IsTransacting( this )
            if this.IsOwnModel
                yes = ~isempty( this.Transaction );
            else
                owner = this.ModelParent;
                yes = false;
                while ~isempty( owner )
                    if ~isempty( owner.OwnModel )
                        yes = ~isempty( owner.Transaction );
                        break
                    end
                    owner = owner.ModelParent;
                end
            end
        end
    end

    methods ( Access = protected, Sealed )
        function varargout = pushTransaction( this, opts )
            arguments
                this
                opts.Revertible( 1, 1 ){ mustBeNumericOrLogical( opts.Revertible ) } = true
                opts.Cleanup{ mustBeMember( opts.Cleanup, [ "Cancel", "Commit" ] ) } = "Cancel"
            end

            logCleanup = this.Logger.trace( 'Entering pushTransaction' );%#ok<NASGU>
            owner = this.ModelOwner;

            if owner.TransactionCounter == 0
                this.Logger.trace( 'Initiating new transaction' );
                owner.doUnlock(  );
                if opts.Revertible
                    owner.Transaction = owner.MfzModel.beginRevertibleTransaction(  );
                else
                    owner.Transaction = owner.MfzModel.beginTransaction(  );
                end
                try
                    this.traverse( @beginTransaction );
                catch me
                    owner.Transaction.rollBack(  );
                    owner.doLock(  );
                    me.rethrow(  );
                end
            end

            txnIdx = owner.TransactionCounter + 1;
            owner.TransactionCounter = txnIdx;

            if nargout > 0
                varargout{ 1 } = onCleanup( @(  )owner.cleanupPushCallback(  ...
                    opts.Cleanup == "Commit", txnIdx ) );
                this.Logger.trace( 'Returning transaction cleanup handle' );
            end
        end

        function popTransaction( this )
            logCleanup = this.Logger.trace( 'Entering popTransaction' );%#ok<NASGU>
            owner = this.ModelOwner;
            if owner.TransactionCounter == 1
                if isempty( owner.DeferredTasks )
                    this.Logger.trace( 'Commencing commit' );
                    owner.TransactionCounter = 0;
                    owner.doCommit(  );
                else
                    next = owner.DeferredTasks{ end  };
                    owner.DeferredTasks( end  ) = [  ];
                    cleanup = onCleanup( @(  )owner.popTransaction(  ) );
                    this.Logger.trace( @(  )sprintf( 'Invoking next deferred task: %s', func2str( next ) ) );
                    next(  );
                end
            elseif owner.TransactionCounter > 0
                owner.TransactionCounter = owner.TransactionCounter - 1;
                this.Logger.trace( 'Decrementing transaction counter: %g', owner.TransactionCounter );
            end
        end

        function varargout = newModel( this, opts )
            arguments
                this( 1, 1 )
                opts.Transact( 1, 1 ){ mustBeNumericOrLogical( opts.Transact ) } = false
            end
            this.tryPopAll(  );
            this.MfzModel = mf.zero.Model(  );
            if opts.Transact
                [ varargout{ 1:nargout } ] = this.pushTransaction(  );
            end
        end

        function lock( this )
            this.ModelOwner.doLock( true );
        end

        function unlock( this )
            this.ModelOwner.doUnlock( true );
        end

        function resetLock( this )
            this.LockOverride = [  ];
            if ~this.IsTransacting && ~isempty( this.Lock ) && ~this.Lock.Locked
                this.doLock(  );
            end
        end
    end

    methods ( Access = protected )
        function defer( this, func )
            arguments
                this( 1, 1 )
                func( 1, 1 )function_handle
            end
            this.ModelOwner.DeferredTasks{ end  + 1 } = func;
        end

        function assertSameModel( this, element, diagText )
            arguments
                this( 1, 1 )
                element( 1, 1 )mf.zero.ModelElement
                diagText( 1, 1 )string = "Element must be owned by the active MF0 model"
            end

            model = this.MfzModel;
            assert( ~isempty( model ) && mf.zero.getModel( element ) == model, diagText );
        end
    end

    methods ( Access = private )
        function tryPopAll( this )
            if ~isempty( this.MfzModel )
                this.popTransaction(  );
            end
        end

        function doCommit( this )
            if isempty( this.Transaction )
                return
            end
            try
                if ~this.abortableTraverse( @preCommit )
                    return
                end
            catch me
                this.doCancel(  );
                me.rethrow(  );
            end

            [ transaction, cleanup ] = this.detachTransaction(  );%#ok<ASGLU>
            transaction.commit(  );
            this.traverse( @postCommit );
        end

        function cleanupPushCallback( this, commit, txnIdx )
            if this.TransactionCounter == 0 || this.TransactionCounter < txnIdx
                return
            end
            if commit
                for i = 1:( this.TransactionCounter - txnIdx + 1 )
                    this.popTransaction(  );
                end
            else
                this.doCancel(  );
            end
        end

        function doCancel( this )
            if isempty( this.Transaction )
                return
            end
            [ transaction, cleanup ] = this.detachTransaction(  );%#ok<ASGLU>
            this.traverse( @preCancel, true );
            transaction.rollBack(  );
            this.traverse( @postCancel );
        end

        function [ transaction, cleanup ] = detachTransaction( this )
            transaction = this.Transaction;
            this.Transaction = mf.zero.Transaction.empty(  );
            this.TransactionCounter = 0;
            this.DeferredTasks = {  };
            this.doUnlock(  );
            cleanup = onCleanup( @(  )this.doCleanupTransaction(  ) );
        end

        function doCleanupTransaction( this )
            postCleanup = onCleanup( @(  )this.doLock(  ) );
            this.traverse( @cleanupTransaction );
        end

        function varargout = doLock( this, sticky )
            arguments
                this
                sticky = false
            end

            logCleanup = this.Logger.trace( 'Entering doLock' );%#ok<NASGU>
            lock = this.Lock;
            if nargout > 0 && ~isempty( lock )
                varargout{ 1 } = onCleanup( @(  )this.doUnlock(  ) );
            elseif isempty( lock ) || lock.Locked
                varargout{ 1 } = [  ];
                return
            end
            if sticky || isempty( this.LockOverride ) || this.LockOverride
                lock.Locked = true;
                if sticky
                    this.LockOverride = true;
                end
            end
        end

        function varargout = doUnlock( this, sticky )
            arguments
                this
                sticky = false
            end

            lock = this.Lock;
            if nargout > 0 && ~isempty( lock )
                varargout{ 1 } = onCleanup( @(  )this.doLock(  ) );
            elseif isempty( lock ) || ~lock.Locked
                varargout{ 1 } = [  ];
                return
            end
            if sticky || isempty( this.LockOverride ) || ~this.LockOverride
                lock.Locked = false;
                if sticky
                    this.LockOverride = false;
                end
            end
        end

        function notifyModelSwap( this, oldModel, newModel )
            this.onModelSwap( oldModel, newModel );
            for childCell = this.Children
                child = childCell{ 1 };
                if isempty( child.OwnModel )
                    child.notifyModelSwap( oldModel, newModel );
                end
            end
        end

        function traverse( this, method, ignoreErrors )
            arguments
                this
                method
                ignoreErrors = false
            end

            for childCell = this.Children
                child = childCell{ 1 };
                if ignoreErrors
                    try
                        child.traverse( method );
                    catch me %#ok<NASGU>
                    end
                else
                    child.traverse( method );
                end
            end
            method( this );
        end

        function proceed = abortableTraverse( this, method )
            for childCell = this.Children
                if ~childCell{ 1 }.abortableTraverse( method )
                    return
                end
            end
            proceed = method( this );
        end

        function assertSwappable( this )
            if this.Unswappable && ~isempty( this.MfzModel )
                error( 'Cannot swap MF0 models when marked Unswappable' );
            end
        end
    end

    methods ( Access = protected )
        function beginTransaction( ~ )
        end

        function proceed = preCommit( ~ )
            proceed = true;
        end

        function postCommit( ~ )
        end

        function preCancel( ~ )
        end

        function postCancel( ~ )
        end

        function cleanupTransaction( ~ )
        end
    end

    methods ( Access = protected )
        function onModelSwap( this, oldModel, newModel )%#ok<INUSD>
        end
    end
end


