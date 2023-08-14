function editorApplet=openTypeEditor(initialTypes,varargin)

    if nargin==0
        initialTypes=[];
    end
    ip=inputParser();
    ip.addParameter('Schema',[],@(v)isempty(v)||isa(v,'codergui.internal.type.MetaTypeSchema'));
    ip.addParameter('TypeEditorFactories',{},@iscell);
    ip.addParameter('AttributeEditorFactories',{},@iscell);
    ip.addParameter('ViewArguments',{},@iscell);
    ip.parser(varargin{:});

    opts=ip.Results;
    if isempty(opts.Schema)
        opts.Schema=codergui.internal.type.MetaTypeSchema.default();
    end

    editorApplet=codergui.internal.type.TypeApplet('MetaTypeSchema',opts.Schema,...
    'Views',codergui.internal.type.WebTypeEditor([],opts.ViewArguments{:}),...
    'TypeEditorFactories',opts.TypeEditorFactories,'AttributeEditorFactories',opts.AttributeEditorFactories);

    if~isempty(initialTypes)
        if~iscell(initialTypes)
            initialTypes=num2cell(initialTypes);
        end
        editorApplet.Model.begin();
        cellfun(@(it)editorApplet.Model.addRoot().setCoderType(rootType),initialTypes);
        editorApplet.Model.finish();
    end

    editorApplet.start();
    editorApplet.show();
end