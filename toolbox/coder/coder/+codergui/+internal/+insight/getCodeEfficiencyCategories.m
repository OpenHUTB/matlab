

function varargout = getCodeEfficiencyCategories( opts )
arguments
    opts.File( 1, 1 )string{ mustBeTextScalar( opts.File ), mustBeFile( opts.File ) }
    opts.Filter string{ mustBeText( opts.Filter ) } = {  }
    opts.Refresh( 1, 1 )logical = false
    opts.ValidationMode( 1, 1 )logical = false
end

persistent defaultCategories;

if ~isfield( opts, 'File' )
    if opts.Refresh || isempty( defaultCategories )
        defaultCategories = loadFromFile( fullfile( matlabroot, 'toolbox/coder/coder/resources/codeEfficiencyIssues.json' ) );
    end
    categories = defaultCategories;
else
    categories = loadFromFile( file );
end

if ~isempty( opts.Filter )
    categories = categories( ismember( [ categories.InternalId ], opts.Filter ) );
end

if opts.ValidationMode
    disp( 'Code efficiency categories validated' );
end
if ~opts.ValidationMode || nargout ~= 0
    varargout{ 1 } = categories;
end
end


function categories = loadFromFile( file )
parsed = jsondecode( fileread( file ) );
if ~isfield( parsed, 'issueCategories' )
    categories = codergui.internal.insight.CodeEfficiencyCategory.empty(  );
    return
end

parsed = parsed.issueCategories;
if ~iscell( parsed )
    parsed = num2cell( parsed );
end

categories = repmat( codergui.internal.insight.CodeEfficiencyCategory(  ), 1, numel( parsed ) );
for i = 1:numel( parsed )
    try
        categories( i ) = validateCategory( parsed{ i }, categories( i ) );
    catch me
        error( 'Invalid issue category: %s', me.message );
    end
    if any( strcmp( categories( i ).Tag, [ categories( 1:i - 1 ).Tag ] ) )
        error( 'Tag "%s" is not unique', categories( i ).Tag );
    elseif any( strcmp( categories( i ).InternalId, [ categories( 1:i - 1 ).InternalId ] ) )
        error( 'Internal ID "%s" is not unique', categories( i ).InternalId );
    end
end
end


function category = validateCategory( raw, category )
assert( all( isfield( raw, { 'tag', 'title', 'description' } ) ),  ...
    'Issues must have "tag", "title", "description" properties' );
category.Title = message( raw.title ).getString(  );
category.Description = message( raw.description ).getString(  );

category.Tag = raw.tag;
if isfield( raw, 'id' )
    category.InternalId = raw.id;
else
    category.InternalId = raw.tag;
end

if isfield( raw, 'enabledCallback' )
    category.EnabledCallback = raw.enabledCallback;
end
if isfield( raw, 'configFeatureFlag' )
    category.ConfigFeatureFlag = raw.configFeatureFlag;
end
if isfield( raw, 'legacyMode' )
    category.IsLegacyMode = raw.legacyMode;
end

if isfield( raw, 'issues' )
    category.Children = validateIssueTypes( raw.issues );
elseif isfield( raw, 'subcategories' )
    category.Children = validateSubCategories( raw.subcategories, category.InternalId );
else
    error( 'Category definitions must specify either "issues" or "subcategories"' );
end


allChecks = vertcat( category.IssueTypes.Checks );
if numel( unique( allChecks ) ) < numel( allChecks )
    error( 'Checks for "%s" must be unique across its own issue types', category.Tag );
end
allTypeIds = [ category.IssueTypes.TypeId ];
if numel( unique( allTypeIds ) ) < numel( allTypeIds )
    error( 'Type ID for "%s" must be unique across all its own issue types', category.Tag );
end
end


function subCats = validateSubCategories( raw, parentId )
if ~iscell( raw )
    raw = num2cell( raw );
end

subCats = repmat( codergui.internal.insight.CodeEfficiencySubCategory(  ), 1, numel( raw ) );
for i = 1:numel( subCats )
    assert( all( isfield( raw{ i }, { 'title', 'description', 'issues' } ) ),  ...
        'Sub-categories must have ""title", "description", and "issues" properties' );
    subCats( i ).Title = message( raw{ i }.title ).getString(  );
    subCats( i ).Description = message( raw{ i }.description ).getString(  );
    subCats( i ).IssueTypes = validateIssueTypes( raw{ i }.issues );
    if isfield( raw, 'id' )
        subCats( i ).SubCategoryId = raw.id;
    else
        subCats( i ).SubCategoryId = sprintf( '%s.subCategory%g', parentId, i );
    end
end
end


function issueTypes = validateIssueTypes( rawIssues )
if ~iscell( rawIssues )
    rawIssues = num2cell( rawIssues );
end
issueTypes = repmat( codergui.internal.insight.CodeEfficiencyIssueType(  ), 1, numel( rawIssues ) );
for i = 1:numel( rawIssues )
    issueTypes( i ) = validateIssueType( rawIssues{ i }, issueTypes( i ) );
end
end


function issue = validateIssueType( raw, issue )
assert( all( isfield( raw, { 'checkId', 'message' } ) ),  ...
    'Issues must have "checks" and "message" properties' );
issue.Checks = raw.checkId;
assert( ~isempty( issue.Checks ), 'All issues must have at least one check ID' );
if isstruct( raw.message )
    assert( all( isfield( raw.message, { 'cli', 'gui' } ) ),  ...
        'Message object form must specify both "cli" and "gui" messages' );
    issue.CliTextKey = raw.message.cli;
    issue.CliText = message( raw.message.cli ).getString(  );
    issue.GuiTextKey = raw.message.gui;
    issue.GuiText = message( raw.message.gui ).getString(  );
else
    issue.CliTextKey = raw.message;
    issue.CliText = message( raw.message ).getString(  );
    issue.GuiTextKey = issue.CliTextKey;
    issue.GuiText = issue.CliText;
end
if isfield( raw, 'typeId' )
    issue.TypeId = raw.typeId;
else
    issue.TypeId = issue.Checks( 1 );
end
end


