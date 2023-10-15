classdef AssumptionRow < slreq.modeling.TableRow




    methods ( Access = { ?slreq.modeling.RequirementsTable } )

        function obj = AssumptionRow( parent, rowType, chartId )


            if nargin == 0
                obj.InternalRequirement = [  ];
                obj.RowType = '';
                obj.ChartId = '';
                return ;
            end

            isCommented = false;
            if isa( parent, 'slreq.modeling.AssumptionRow' )
                parent = parent.InternalRequirement;
                isCommented = parent.commentOut;
            end

            rowType = lower( rowType );
            obj.verifyCanAddChild( rowType, 'sf.req.AssumptionsTable', parent );

            switch rowType
                case 'normal'
                    assumption = parent.addChild;
                case 'anychildactive'
                    assumption = obj.addOrChild( parent );
                case 'allchildrenactive'
                    assumption = obj.addAndChild( parent );
            end




            assumption.commentOut = isCommented;
            obj.InternalRequirement = assumption;
            obj.RowType = rowType;
            obj.ChartId = chartId;
        end
    end

    methods
        function assumption = addChild( obj, options )
            arguments
                obj
                options.RowType{ mustBeTextScalar, mustBeMember( options.RowType, { 'normal', 'anyChildActive', 'allChildrenActive' } ) } = 'normal'
                options.Preconditions cell
                options.Postconditions cell
                options.Summary{ mustBeTextScalar }
            end

            if ( isfield( options, 'Preconditions' ) && numel( options.Preconditions ) > 1 ) ||  ...
                    ( isfield( options, 'Postconditions' ) && numel( options.Postconditions ) > 1 )
                error( 'Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions',  ...
                    DAStudio.message( 'Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions' ) );
            end

            parent = obj;
            assumption = slreq.modeling.AssumptionRow( parent, options.RowType, obj.ChartId );
            assumption.setAllowRefreshUI( false );
            if isfield( options, 'Summary' )
                assumption.Summary = options.Summary;
            end
            if isfield( options, 'Preconditions' )
                assumption.Preconditions = options.Preconditions;
            end
            if isfield( options, 'Postconditions' )
                if assumption.canAddPostconditions(  )
                    assumption.Postconditions = options.Postconditions;
                else
                    warning( 'Slvnv:reqmgt:specBlock:SetPostconditionNotAllowed',  ...
                        DAStudio.message( 'Slvnv:reqmgt:specBlock:SetPostconditionNotAllowed' ) );
                end
            end
            assumption.setAllowRefreshUI( true );
            assumption.refreshUI(  );
        end

        function children = getChildren( obj )
            childrenInOrder = obj.InternalRequirement.getChildrenInOrder(  );
            children = [  ];
            for child = childrenInOrder
                slReqChild = slreq.modeling.AssumptionRow.wrap( child, obj.ChartId );
                children = [ children, slReqChild ];%#ok<AGROW>
            end
        end

        function clear( obj, type )
            arguments
                obj
                type char{ mustBeMember( type, { 'Summary', 'Preconditions', 'Postconditions', '' } ) } = ''
            end
            if isempty( type )
                obj.setAllowRefreshUI( false );
                areAncestorsIndependent = obj.areAncestorsIndependent( obj.InternalRequirement.parent, 'sf.req.AssumptionsTable' );

                if areAncestorsIndependent
                    obj.clear( 'Postconditions' );
                end

                if ~obj.isRowTypeDependent( obj.RowType )
                    obj.clear( 'Preconditions' );
                end

                obj.clear( 'Summary' );
                obj.setAllowRefreshUI( true );
                obj.refreshUI(  );
            elseif strcmp( type, 'Summary' )
                obj.( type ) = '';
                obj.refreshUI(  );
            else
                lngth = numel( obj.( type ) );
                newValues = cell( 1, lngth );
                newValues( : ) = { '' };
                obj.( type ) = newValues;
                obj.refreshUI(  );
            end
        end
    end

    methods ( Access = protected )

        function row = addOrChild( ~, parent )
            row = parent.addOrChild;
            row.addChild;
            row.addChild;
        end

        function row = addAndChild( ~, parent )
            row = parent.addAndChild;
            row.addChild;
            row.addChild;
        end
    end

    methods ( Static, Hidden )
        function obj = wrap( internalRequirement, chartId )
            obj = slreq.modeling.AssumptionRow(  );
            obj.InternalRequirement = internalRequirement;
            obj.ChartId = chartId;
            multiLineLogic = internalRequirement.multipleLineLogic;
            if multiLineLogic == Stateflow.ReqTable.internal.TableManager.ANYCHILDACTIVE
                obj.RowType = 'anychildActive';
            elseif multiLineLogic == Stateflow.ReqTable.internal.TableManager.ALLCHILDRENACTIVE
                obj.RowType = 'allChildrenActive';
            else
                obj.RowType = 'normal';
            end
        end
    end
end


