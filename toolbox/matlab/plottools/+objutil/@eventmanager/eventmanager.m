classdef eventmanager<matlab.mixin.SetGet&matlab.mixin.Copyable&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer




    properties(SetObservable,GetObservable)
        TargetListeners;
        RootNode;
        ExclusionTag char='';
        Filter;
        Enable matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    events
NodeChanged
NewNode
    end

    methods
        function obj=eventmanager(hTarget,varargin)




























            if~isempty(hTarget)&&ishghandle(hTarget)
                nin=nargin-1;
                if(nin>1)
                    if rem(nin,2)~=0
                        error(message('MATLAB:graphics:eventtreemanager:IncorrectNumberOfInputs'));
                    end
                    localInit(obj,hTarget,varargin{:});
                else
                    localInit(obj,hTarget,{});
                end
            end
        end
    end
end

function localInit(hThis,hTarget,varargin)

    hTarget=handle(hTarget);
    hThis.RootNode=hTarget;


    localClearListeners(hThis,hTarget);

    if(strcmp(varargin{1},'IncludeFilter'))
        if~isstruct(varargin{2})
            error(message('MATLAB:graphics:eventtreemanager:FilterCellArray'));
        end
        hThis.Filter=varargin{2};
    end

    localAddListenersRecurse(hThis,hTarget);
end


function localAddListenerWithNoFilterToObject(hThis,hTarget)



    if~isempty(hThis.ExclusionTag)&&strcmp(hThis.ExclusionTag,get(hTarget,'Tag'))
        return
    end


    doPropagate=true;


    hCls=metaclass(hTarget);
    hProps=hCls.Properties(cellfun(@(h)h.SetObservable&&...
    any(strcmp('public',h.GetAccess))&&any(strcmp('public',h.SetAccess)),hCls.Properties));

    hEventListener=event.listener(hTarget,'ObjectBeingDestroyed',...
    localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate));
    hpropListener=event.proplistener(hTarget,hProps,'PostSet',...
    localCreateFunctionHandle(@localPropertyPostCallback,hThis,doPropagate));




    if isa(hTarget,'matlab.graphics.axis.Axes')
        hEventListener=[hEventListener;...
        event.listener(hTarget.ChildContainer,'ObjectChildAdded',...
        localCreateFunctionHandle(@localObjectChildAddedCallback,hThis));...
        event.listener(hTarget.ChildContainer,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis));...
        event.listener(hTarget,'MarkedClean',...
        localCreateFunctionHandle(@localChildContainerUpdateCallback,hThis,hTarget.ChildContainer))];

    elseif isa(hTarget,'matlab.ui.Figure')||isa(hTarget,'matlab.ui.container.Panel')
        sv=hTarget.getCanvas();
        hEventListener=[hEventListener;...
        event.listener(sv,'ObjectChildAdded',...
        localCreateFunctionHandle(@localObjectChildAddedCallback,hThis));...
        event.listener(sv,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    elseif isempty(ancestor(hTarget,'axes'))||isa(hTarget,'matlab.graphics.primitive.Group')
        hEventListener=[hEventListener;...
        event.listener(hTarget,'ObjectChildAdded',...
        localCreateFunctionHandle(@localObjectChildAddedCallback,hThis));...
        event.listener(hTarget,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    else
        hEventListener=[hEventListener;...
        event.listener(hTarget,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    end
    localAddListener(hThis,hTarget,hpropListener(:));
    localAddListener(hThis,hTarget,hEventListener(:));
end


function classname=localGetClassName(hObj)


    m=metaclass(hObj);
    if~isempty(m)
        classname=m.Name;
    else
        classname='';
    end
end


function[b,n]=localDoIncludeClassCreation(hThis,classname)


    filter=get(hThis,'Filter');
    if isempty(filter)
        b=true;
        return
    end
    b=false;
    for n=1:length(filter)
        if any(strcmpi(classname,filter(n).classname))...
            &&isfield(filter(n),'listentocreation')...
            &&isequal(filter(n).listentocreation,true)
            b=true;
            break;
        end
    end
end



function[b,n]=localDoIncludeClass(hThis,classname)


    filter=get(hThis,'Filter');
    if isempty(filter)
        b=true;
        return
    end
    b=false;
    for n=1:length(filter)
        if any(strcmpi(classname,filter(n).classname))||...
            isequal(filter(n).includeallchildren,true)
            b=true;
            break;
        end
    end
end


function b=localDoIncludeEventsForTarget(hThis,hTarget)

    filter=get(hThis,'Filter');
    if isempty(filter)
        b=true;
        return
    end
    b=false;
    for n=1:length(filter)
        if isfield(filter(n),'includeallchildren')&&isequal(filter(n).includeallchildren,true)
            classname=filter(n).classname;
            hParent=ancestor(hTarget,classname);
            if~isempty(hParent)&&~isequal(hParent,hTarget)
                b=true;
            end
        end
    end
end


function localAddListenerWithFilterToObject(hThis,hTarget)




    if ishghandle(hThis)&&~isempty(hThis.ExclusionTag)&&...
        strcmp(hThis.ExclusionTag,get(hTarget,'Tag'))
        return
    end

    filter=hThis.Filter;
    hCls=metaclass(hTarget);
    classname=localGetClassName(hTarget);
    [doinclude,n]=localDoIncludeClass(hThis,classname);



    doPropagate=doinclude;
    if isa(hTarget,'matlab.graphics.axis.Axes')
        hChildListener=[event.listener(hTarget.ChildContainer,'ObjectBeingDestroyed',...
        localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate));...
        event.listener(hTarget.ChildContainer,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis));...
        event.listener(hTarget,'MarkedClean',...
        localCreateFunctionHandle(@localChildContainerUpdateCallback,hThis,hTarget.ChildContainer))];
    elseif isa(hTarget,'matlab.ui.Figure')||isa(hTarget,'matlab.ui.container.Panel')
        sv=hTarget.getCanvas();
        hChildListener=[event.listener(sv,'ObjectBeingDestroyed',...
        localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate));...
        event.listener(sv,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    else
        hChildListener=[event.listener(hTarget,'ObjectBeingDestroyed',...
        localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate));...
        event.listener(hTarget,'ObjectChildRemoved',...
        localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    end




    if isa(hTarget,'matlab.graphics.axis.Axes')
        hChildListener=[hChildListener;...
        event.listener(hTarget.ChildContainer,'ObjectChildAdded',...
        localCreateFunctionHandle(@localObjectChildAddedCallback,hThis))];
    elseif isa(hTarget,'matlab.ui.Figure')||isa(hTarget,'matlab.ui.container.Panel')
        sv=hTarget.getCanvas();
        hChildListener=[hChildListener;...
        event.listener(sv,'ObjectChildAdded',...
        localCreateFunctionHandle(@localObjectChildAddedCallback,hThis))];
    elseif~any(strcmp(classname,[filter.classname]))
        hChildListener=[hChildListener;...
        event.listener(hTarget,'ObjectChildAdded',...
        localCreateFunctionHandle(@localObjectChildAddedCallback,hThis))];
    end
    localAddListener(hThis,hTarget,hChildListener(:));


    if doinclude
        hProps=hCls.Properties(cellfun(@(h)h.SetObservable&&...
        any(strcmp('public',h.GetAccess))&&any(strcmp('public',h.SetAccess)),hCls.Properties));
        hProps=[hProps{:}];
        propnamelist=filter(n).properties;
        if~any([filter.includeallchildren])&&~isempty(propnamelist)
            hProps(~ismember(lower(localGetPropNames(hProps)),...
            lower(propnamelist)))=[];
        end

        for m=1:length(hProps)
            hProp=hProps(m);
            propname=hProp.Name;

            doPropagate=isempty(propnamelist)||any(strcmpi(propname,propnamelist));
            hListener(m)=event.proplistener(hTarget,hProp,'PostSet',...
            @(es,ed)localPropertyPostCallback(es,ed,hThis,doPropagate));%#ok<AGROW>
        end
        localAddListener(hThis,hTarget,hListener(:));
    end
end


function localAddListenersRecurse(hThis,hTarget)

    if isempty(hThis.Filter)
        localAddListenerWithNoFilterToObject(hThis,hTarget);
    else
        localAddListenerWithFilterToObject(hThis,hTarget);
    end


    hKids=localGetChildren(hTarget);
    for n=1:length(hKids)
        if~(isobject(hKids(n))&&isprop(hKids(n),'Internal')&&...
            hKids(n).Internal&&isa(hKids(n).Parent,'matlab.graphics.primitive.Data'))
            localAddListenersRecurse(hThis,hKids(n));
        end
    end
end


function hKids=localGetChildren(hTarget)

    hKids=findobj(hTarget);
    for k=1:length(hKids)
        if hKids(k)==hTarget
            hKids(k)=[];
            break;
        end
    end
end


function localClearListeners(hThis,hTarget)



    hKids=localGetChildren(hTarget);
    for n=1:length(hKids)
        if~(isobject(hKids(n))&&isprop(hKids(n),'Internal')&&...
            hKids(n).Internal&&isa(hKids(n).Parent,'matlab.graphics.primitive.Data'))
            localClearListeners(hThis,hKids(n))
        end
    end



    KEY='eventmanagerlisteners__';
    PROPKEY='eventmanagerproplisteners__';
    if isprop(hTarget,KEY)
        delete(hTarget.(KEY));
        hTarget.(KEY)=[];
    end
    if isprop(hTarget,PROPKEY)
        delete(hTarget.(PROPKEY));
        hTarget.(PROPKEY)=[];
    end
end


function localAddListener(hThis,hTarget,hListener)

    KEY='eventmanagerlisteners__';
    PROPKEY='eventmanagerproplisteners__';


    if isa(hListener(1),'event.proplistener')
        propName=PROPKEY;
    else
        propName=KEY;
    end

    if~isprop(hTarget,propName)
        p=addprop(hTarget,propName);
        p.Transient=true;
        p.Hidden=true;
    end
    info=get(hTarget,propName);
    if~isempty(info)
        info=[info;hListener];
    else
        info=hListener;
    end
    set(hTarget,propName,info);
end



function localObjectBeingDestroyedCallback(obj,evd,hThis,doPropagate)%#ok<INUSD>








    hObj=evd.Source;
    if isequal(hThis.RootNode,hObj)
        classname=localGetClassName(hObj);
        if localDoIncludeClassCreation(hThis,classname)
            if isobject(hThis)&&strcmpi(get(hThis,'Enable'),'on')
                hEvent=localCreateEvent(hThis,obj,evd);
                notify(hThis,'NodeChanged',hEvent);
            end
        end
    end
end


function localObjectChildRemovedCallback(obj,evd,hThis)









    hChild=evd.Child;
    classname=localGetClassName(hChild);
    if localDoIncludeClassCreation(hThis,classname)
        if isobject(hThis)&&strcmpi(get(hThis,'Enable'),'on')
            hEvent=localCreateEvent(hThis,obj,evd);
            notify(hThis,'NodeChanged',hEvent);
        end
    end
end


function localObjectChildAddedCallback(obj,evd,hThis)






    hChild=evd.Child;

    localAddListenersRecurse(hThis,hChild);

    classname=localGetClassName(hChild);
    if localDoIncludeClassCreation(hThis,classname)
        if isobject(hThis)&&strcmpi(get(hThis,'Enable'),'on')
            hEvent=localCreateEvent(hThis,obj,evd);
            notify(hThis,'NodeChanged',hEvent);
        end
    end
end



function localPropertyPostCallback(obj,evd,hThis,doPropagate)







    hTarget=evd.AffectedObject;
    if isobject(hThis)&&strcmpi(get(hThis,'Enable'),'on')
        if doPropagate||localDoIncludeEventsForTarget(hThis,hTarget)
            hEvent=localCreateEvent(hThis,obj,evd);
            notify(hThis,'NodeChanged',hEvent);
        end
    end
end


function hEvent=localCreateEvent(hThis,src,evd)%#ok<INUSL>


    hEvent=objutil.eventwrapper;


    hEventInfo=[];
    if isa(evd,'event.PropertyEvent')
        hEventInfo=objutil.propertyevent;
        set(hEventInfo,'Type','PropertyPostSet');
        set(hEventInfo,'Source',evd.Source);
        set(hEventInfo,'AffectedObject',evd.AffectedObject);
        set(hEventInfo,'NewValue',evd.AffectedObject.(evd.Source.Name));
    else
        switch evd.EventName
        case 'ObjectChildRemoved'
            hEventInfo=objutil.childremovedevent;
            set(hEventInfo,'Type',evd.EventName);
            set(hEventInfo,'Source',evd.Source);
            set(hEventInfo,'Child',evd.Child);

        case 'ObjectChildAdded'
            hEventInfo=objutil.childaddedevent;
            set(hEventInfo,'Type',evd.EventName);
            set(hEventInfo,'Source',evd.Source);
            set(hEventInfo,'Child',evd.Child);
        end
    end

    if isempty(hEventInfo)
        disp('')
    end

    set(hEvent,'EventInfo',hEventInfo);
end



function fH=localCreateFunctionHandle(fHin,varargin)

    fH=@(es,ed)fHin(es,ed,varargin{:});
end


function propNames=localGetPropNames(hProps)

    propNames=cell(size(hProps));
    for k=1:length(propNames)
        propNames{k}=hProps(k).Name;
    end
end




function localChildContainerUpdateCallback(ax,~,hThis,childContainer)

    if isequal(ax.ChildContainer,childContainer)
        return
    end


    evd=objutil.childremovedevent;
    evd.Source=get(ax,'Parent');
    evd.Child=ax;
    localObjectChildRemovedCallback(evd.Source,evd,hThis);



    evd=objutil.childaddedevent;
    evd.Source=get(ax,'Parent');
    evd.Child=ax;
    localObjectChildAddedCallback(evd.Source,evd,hThis);
end
