classdef ( Sealed )CodeEfficiencyResults < handle
    properties ( SetAccess = immutable )
        Categories codergui.internal.insight.CodeEfficiencyCategory
        ActiveCategories codergui.internal.insight.CodeEfficiencyCategory
    end

    properties ( SetAccess = immutable, GetAccess = private )
        ByCategoryId containers.Map
    end

    methods
        function this = CodeEfficiencyResults( categories, byCategory )
            arguments
                categories codergui.internal.insight.CodeEfficiencyCategory
                byCategory containers.Map
            end

            this.Categories = categories;
            this.ActiveCategories = categories( byCategory.isKey( cellstr( [ categories.InternalId ] ) ) );
            this.ByCategoryId = byCategory;
        end

        function issues = getIssues( this, category, issueType )
            arguments
                this( 1, 1 )
                category{ mustBeA( category, { 'char', 'string', 'codergui.internal.insight.CodeEfficiencyCategory' } ) }
                issueType{ mustBeA( issueType, { 'char', 'string', 'codergui.internal.insight.CodeEfficiencyIssueType' } ) } = ''
            end

            catId = toCategoryId( category );
            typeId = toTypeId( issueType );

            if this.ByCategoryId.isKey( catId )
                byTypeId = this.ByCategoryId( catId );
                if ~isempty( typeId )
                    if byTypeId.isKey( typeId )
                        issues = byTypeId( typeId );
                    else
                        error( '"%s" is not a valid issue type for category "%s"', typeId, catId );
                    end
                else


                    typeIds = this.ActiveCategories( [ this.ActiveCategories.InternalId ] == catId ).IssueTypes;
                    typeIds = cellstr( [ typeIds.TypeId ] );
                    typeIds( ~byTypeId.isKey( typeIds ) ) = [  ];
                    issues = byTypeId.values( typeIds );
                    issues = [ issues{ : } ];
                end
            else
                issues = [  ];
            end
        end
    end

    methods ( Access = ?coder.report.contrib.CodeEfficiencyContributor )
        function issueMap = getIssueMap( this, category )
            arguments
                this( 1, 1 )
                category{ mustBeA( category, { 'char', 'string', 'codergui.internal.insight.CodeEfficiencyCategory' } ) }
            end

            issueMap = this.ByCategoryId( toCategoryId( category ) );
        end
    end
end


function catId = toCategoryId( arg )
if isempty( arg )
    catId = '';
elseif isa( arg, 'codergui.internal.insight.CodeEfficiencyCategory' )
    catId = arg.InternalId;
else
    catId = arg;
end
end


function typeId = toTypeId( arg )
if isempty( arg )
    typeId = '';
elseif isa( arg, 'codergui.internal.insight.CodeEfficiencyIssueType' )
    typeId = arg.TypeId;
else
    typeId = arg;
end
end


