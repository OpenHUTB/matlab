classdef RequirementRow < slreq.modeling.TableRow




    properties
        Actions
        Duration
    end

    methods ( Access = { ?slreq.modeling.RequirementsTable } )

        function obj = RequirementRow( parent, rowType, chartId )


            if nargin == 0
                obj.InternalRequirement = [  ];
                obj.RowType = '';
                obj.ChartId = [  ];
                return ;
            end

            isCommented = false;
            if isa( parent, 'slreq.modeling.RequirementRow' )
                parent = parent.InternalRequirement;
                isCommented = parent.commentOut;
            end


            hasDefaultRow = obj.hasDefaultRow( parent );
            if hasDefaultRow
                error( 'Slvnv:reqmgt:specBlock:HasDefaultRow',  ...
                    DAStudio.message( 'Slvnv:reqmgt:specBlock:HasDefaultRow' ) );
            end

            rowType = lower( rowType );
            obj.verifyCanAddChild( rowType, 'sf.req.RequirementsTable', parent );

            requirement = [  ];
            switch rowType
                case 'normal'
                    requirement = parent.addChild;
                case 'anychildactive'
                    requirement = obj.addOrChild( parent );
                case 'allchildrenactive'
                    requirement = obj.addAndChild( parent );
                case 'default'
                    requirement = parent.addDefaultChild;
            end




            requirement.commentOut = isCommented;
            obj.InternalRequirement = requirement;
            obj.RowType = rowType;
            obj.ChartId = chartId;
        end
    end

    methods
        function requirement = addChild( obj, options )
            arguments
                obj
                options.RowType{ mustBeTextScalar, mustBeMember( options.RowType, { 'normal', 'anyChildActive', 'allChildrenActive', 'default' } ) } = 'normal'
                options.Actions cell
                options.Duration{ mustBeTextScalar }
                options.Preconditions cell
                options.Postconditions cell
                options.Summary{ mustBeTextScalar }
            end
            parent = obj;
            requirement = slreq.modeling.RequirementRow( parent, options.RowType, obj.ChartId );
            requirement.setAllowRefreshUI( false );
            if isfield( options, 'Preconditions' )
                requirement.Preconditions = options.Preconditions;
            end
            if isfield( options, 'Duration' )
                requirement.Duration = options.Duration;
            end
            if isfield( options, 'Summary' )
                requirement.Summary = options.Summary;
            end
            if isfield( options, 'Postconditions' )
                if requirement.canAddPostconditions(  )
                    requirement.Postconditions = options.Postconditions;
                else
                    warning( 'Slvnv:reqmgt:specBlock:SetPostconditionNotAllowed',  ...
                        DAStudio.message( 'Slvnv:reqmgt:specBlock:SetPostconditionNotAllowed' ) );
                end
            end

            if isfield( options, 'Actions' )
                if requirement.canAddPostconditions(  )
                    requirement.Actions = options.Actions;
                else
                    warning( 'Slvnv:reqmgt:specBlock:SetActionsNotAllowed',  ...
                        DAStudio.message( 'Slvnv:reqmgt:specBlock:SetActionsNotAllowed', options.RowType ) );
                end
            end
            requirement.setAllowRefreshUI( true );
            requirement.refreshUI(  );
        end

        function children = getChildren( obj )
            childrenInOrder = obj.InternalRequirement.getChildrenInOrder(  );
            children = [  ];
            for child = childrenInOrder
                slReqChild = slreq.modeling.RequirementRow.wrap( child, obj.ChartId );
                children = [ children, slReqChild ];%#ok<AGROW>
            end
        end

        function set.Duration( obj, newValue )
            arguments
                obj
                newValue{ mustBeTextScalar }
            end
            if strcmp( obj.RowType, obj.DEFAULT_ROW )
                warning( 'Slvnv:reqmgt:specBlock:SetPreconditionNotAllowed',  ...
                    DAStudio.message( 'Slvnv:reqmgt:specBlock:SetPreconditionNotAllowed', obj.RowType ) );
                return ;
            end
            obj.InternalRequirement.duration = newValue;
            obj.refreshUI(  );
        end

        function duration = get.Duration( obj )
            duration = obj.InternalRequirement.duration;
        end

        function set.Actions( obj, newValue )
            arguments
                obj
                newValue cell
            end
            isAnyChildActive = obj.isAnyChildActiveRow(  );
            isAllChildrenActive = obj.isAllChildrenActiveRow(  );
            if isAnyChildActive || isAllChildrenActive
                warning( 'Slvnv:reqmgt:specBlock:NoActionOnMultiLineLogicRow',  ...
                    DAStudio.message( 'Slvnv:reqmgt:specBlock:NoActionOnMultiLineLogicRow' ) );
                return ;
            end

            [ newValue{ : } ] = convertStringsToChars( newValue{ : } );

            if ~iscellstr( newValue )
                error( 'Slvnv:reqmgt:specBlock:InputMustBeCellOfStrings',  ...
                    DAStudio.message( 'Slvnv:reqmgt:specBlock:InputMustBeCellOfStrings' ) );
            end
            obj.InternalRequirement.setActions( newValue );
            obj.refreshUI(  );
        end

        function actions = get.Actions( obj )
            actions = obj.InternalRequirement.getActions(  );
        end

        function clear( obj, type )

            arguments
                obj
                type char{ mustBeMember( type, { 'Summary', 'Actions', 'Duration', 'Preconditions', 'Postconditions', '' } ) } = ''
            end

            if isempty( type )
                obj.setAllowRefreshUI( false );
                obj.clear( 'Summary' );

                areAncestorsIndependent = obj.areAncestorsIndependent( obj.InternalRequirement.parent, 'sf.req.RequirementsTable' );
                if areAncestorsIndependent
                    obj.clear( 'Actions' );
                    obj.clear( 'Postconditions' );
                end

                if ~strcmp( obj.RowType, obj.DEFAULT_ROW )
                    obj.clear( 'Duration' );
                    if ~obj.isRowTypeDependent( obj.RowType )
                        obj.clear( 'Preconditions' );
                    end
                end

                obj.setAllowRefreshUI( true );
                obj.refreshUI(  );
            elseif strcmp( type, 'Summary' ) || strcmp( type, 'Duration' )
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

        function tf = hasDefaultRow( ~, parent )
            if isa( parent, 'sf.req.RequirementsTable' )
                children = parent.requirements.toArray;
            else
                children = parent.children.toArray(  );
            end
            if isempty( children )
                tf = false;
                return ;
            end
            lastChild = children( end  );
            tf = lastChild.isDefault;
        end
    end

    methods ( Static, Hidden )
        function obj = wrap( internalRequirement, chartId )
            obj = slreq.modeling.RequirementRow(  );
            obj.InternalRequirement = internalRequirement;
            isDefault = internalRequirement.isDefault;
            obj.ChartId = chartId;
            if isDefault
                obj.RowType = 'default';
                return ;
            end
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

