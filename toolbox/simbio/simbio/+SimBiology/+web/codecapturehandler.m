function out=codecapturehandler(action,varargin)











    out={action};

    switch(action)
    case 'createAddObjectCommand'
        out=createAddObjectCommand(varargin{:});
    case 'createConfigureObjectCommand'
        out=createConfigureObjectCommand(varargin{:});
    case 'createCopyObjCommand'
        out=createCopyObjCommand(varargin{:});
    case 'creatDeleteObjectCommand'
        out=createDeleteObjectCommand(varargin{:});
    case 'postObjectAddedEvent'
        postObjectAddedEvent(varargin{:});
    case 'postObjectDeletedEvent'
        postObjectDeletedEvent(varargin{:});
    case 'postObjectMovedEvent'
        postObjectMovedEvent(varargin{:});
    case 'postCodeCaptureEvent'
        postCodeCaptureEvent(varargin{:});
    case 'postConfigsetPropertyChangedEvent'
        postConfigsetPropertyChangedEvent(varargin{:});
    case 'postModelPropertyChangedEvent'
        postModelPropertyChangedEvent(varargin{:});
    case 'postPropertyChangedEvent'
        postPropertyChangedEvent(varargin{:});
    case 'postSinglePropertyChangedEvent'
        postSinglePropertyChangedEvent(varargin{:});
    end

end

function command=createAddObjectCommand(obj)

    command=struct;
    command.type='objectAddedCodeCapture';
    command.sessionID=obj.SessionID;
    command.objType=obj.Type;

    scope=obj.Parent;
    if isa(scope,'SimBiology.KineticLaw')
        scope=scope.Parent;
    elseif isa(obj,'SimBiology.Compartment')&&~isempty(obj.Owner)
        scope=obj.Owner;
    end

    command.scopeSessionID=scope.SessionID;
    command.name=obj.Name;

    if isa(obj,'SimBiology.Reaction')
        command.reaction=obj.Reaction;
    elseif isa(obj,'SimBiology.Rule')
        command.rule=obj.Rule;
        command.ruleType=obj.RuleType;
    elseif isa(obj,'SimBiology.Event')
        command.trigger=obj.Trigger;
    elseif isa(obj,'SimBiology.Observable')
        command.expression=obj.Expression;
    end

end

function command=createConfigureObjectCommand(obj,property,value,varargin)

    command=struct;
    command.type='propertyChangedCodeCapture';
    command.sessionID=obj.SessionID;
    command.property=property;
    command.value=value;
    command.error={false};
    command.codeInfo={[]};
    command.commands={[]};

    if nargin==4
        command.codeInfo=varargin{1};
    end

end

function command=createCopyObjCommand(modelSessionID,child,parent)


    command.type='copyobjCodeCatpure';
    command.model=modelSessionID;
    command.child=child.SessionID;
    command.parent=parent.SessionID;

end

function command=createDeleteObjectCommand(obj)

    scope=obj.Parent;
    if isa(scope,'SimBiology.KineticLaw')
        scope=scope.Parent;
    elseif isa(obj,'SimBiology.Compartment')&&~isempty(obj.Owner)
        scope=obj.Owner;
    end

    index=-1;
    if isa(obj,'SimBiology.Rule')||isa(obj,'SimBiology.Event')
        model=obj.Parent;
        list=sbioselect(model,'Type',obj.Type);
        index=find(obj==list);
    end

    modelStoreRow=struct;
    modelStoreRow.name=obj.Name;
    modelStoreRow.type=obj.Type;
    modelStoreRow.ID=obj.SessionID;
    modelStoreRow.scopeSessionID=scope.SessionID;
    modelStoreRow.arrayIndex=index;

    command=struct;
    command.type='objectDeletedCodeCapture';
    command.sessionID=obj.SessionID;
    command.modelStoreRow=modelStoreRow;

end

function postObjectAddedEvent(modelSessionID,objAdded,commands,errorOccurred)


    evt.type='objectAddedCodeCapture';
    evt.model=modelSessionID;
    evt.sessionID=objAdded.SessionID;
    evt.error=errorOccurred;
    addCommand=createAddObjectCommand(objAdded);

    if isempty(commands)
        evt.commands={addCommand};
    else
        evt.commands=horzcat({addCommand},commands);
    end

    message.publish('/SimBiology/object',evt);

end

function postObjectDeletedEvent(modelSessionID,commands)


    evt.type='objectDeletedCodeCapture';
    evt.model=modelSessionID;
    evt.commands=commands;

    message.publish('/SimBiology/object',evt);

end

function postObjectMovedEvent(parent,obj,forceMove)

    model=parent;
    while~isa(model,'SimBiology.Model')
        model=model.Parent;
    end

    evt.type='objectMovedCodeCatpure';
    evt.model=model.SessionID;
    evt.sessionID=obj.SessionID;
    evt.parentSessionID=parent.SessionID;
    evt.force=forceMove;

    message.publish('/SimBiology/object',evt);

end

function postCodeCaptureEvent(modelSessionID,commands)


    evt.type='codeCatpure';
    evt.model=modelSessionID;
    evt.commands=commands;

    message.publish('/SimBiology/object',evt);

end

function postConfigsetPropertyChangedEvent(modelSessionID,property,value,errorOccurred)


    evt.type='configsetPropertyChangedCodeCapture';
    evt.model=modelSessionID;
    evt.property=property;
    evt.value=value;
    evt.error=errorOccurred;

    message.publish('/SimBiology/object',evt);

end

function postModelPropertyChangedEvent(modelObj,property,value,error)


    evt.type='modelPropertyChangedCodeCapture';
    evt.model=modelObj.SessionID;
    evt.property=property;
    evt.value=value;
    evt.error=error;

    message.publish('/SimBiology/object',evt);

end

function postSinglePropertyChangedEvent(modelSessionID,obj,property,value)

    input.modelSessionID=modelSessionID;
    input.sessionID=obj.SessionID;
    input.property=property;
    input.value=value;

    postPropertyChangedEvent(input,false,[],[]);

end

function postPropertyChangedEvent(input,errorOccurred,codeInfo,commands)

    if~iscell(errorOccurred)
        errorOccurred={errorOccurred};
    end

    if~iscell(codeInfo)
        codeInfo={codeInfo};
    end

    if~iscell(commands)
        commands={commands};
    end

    modelSessionID=input.modelSessionID;
    property=input.property;


    evt.type='propertyChangedCodeCapture';
    evt.model=modelSessionID;
    evt.input=input;
    evt.input.codeInfo=codeInfo;
    evt.input.commands=commands;
    evt.input.error=errorOccurred;

    if strcmpi(property,'kineticlaw')
        evt.input.value=evt.input.value.value;
    end

    message.publish('/SimBiology/object',evt);

end
