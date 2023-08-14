function[hcomponent,hcontainer]=javacomponentdoc_helper(varargin)







    position=[20,20,60,20];
    parent=[];
    callback='';

    if(nargin>=1)
        component=varargin{1};
    end

    if(nargin>=2)
        position=varargin{2};
    end

    if(nargin>=3)
        parent=varargin{3};
    end

    if(nargin==4)
        callback=varargin{4};
    end





    [hcomponent,position,parent]=parseAndValidateArguments(component,position,parent);


    [hcontainer,parent,hgCleansJava,javaCleansHG]=applyArgumentsAndShow(hcomponent,position,parent);


    addJavaCallbacks(hcomponent,hcontainer,callback);


    customizeSwingHandleForPainting(hcomponent);


    enableAutoCleanup(getHGOwnerForCleanup(hcontainer,parent),hcomponent,hgCleansJava,javaCleansHG);

end


function[hcomponent,position,parent]=parseAndValidateArguments(component,position,parent)
    hcomponent=validateSwingComponent(component);
    position=validatePosition(position);
    parent=validateParent(parent);
end


function retVal=validateSwingComponent(component)
    if ischar(component)

        component=javaObjectEDT(component);
    elseif iscell(component)

        component=javaObjectEDT(component{:});
    elseif isa(component,'java')
    elseif isa(component,'handle')
        try

            component=java(component);
        catch ex %#ok
            assert(false,'Invalid specification of the swing component');
        end
    else
        assert(false,'Invalid specification of the swing component');
    end
    retVal=handle(javaObjectEDT(component),'callbackproperties');
end


function customizeSwingHandleForPainting(hcomponent)
    if isa(java(hcomponent),'javax.swing.JComponent')



        hcomponent.setOpaque(true);
    end
end


function position=validatePosition(position)
    if(isempty(position))
        position=[20,20,60,20];
    end

    if(isa(position,'java.lang.String'))
        position=validateLayoutConstraint(char(position));
    end
end


function parent=validateParent(parent)

    if~(isempty(parent)||ishghandle(parent))
        assert(false,'Invalid parent specification');
    end
end




function owner=getHGOwnerForCleanup(hcontainer,parent)
    if(isempty(hcontainer))

        owner=ancestor(parent,'figure');
    else


        owner=hcontainer;
    end
end


function[hgProxy,parent,hgCleansJava,javaCleansHG]=applyArgumentsAndShow(hcomponent,position,parent)
    if isempty(parent)
        parent=gcf;
    end
    component=java(hcomponent);



    if isa(parent,'matlab.ui.internal.mixin.CanvasHostMixin')



        if(isnumeric(position))
            hgProxy=hgjavacomponent('Parent',parent,'JavaPeer',java(hcomponent),'Units','pixels','Position',position,'Serializable','off');

            set(hgProxy,'UserData',char(component.getClass.getName));
            hgCleansJava=@(o,e)deleteComponent(o,e,hcomponent);
            javaCleansHG=@(o,e)delete(hgProxy);

        elseif(ischar(position))
            hgProxy=[];
            figParent=parent;


            peer=getJavaFrame(figParent);
            peer.addchild(java(hcomponent),position);
            hgCleansJava=@(o,e)deleteComponent(o,e,hcomponent);
            javaCleansHG=@(o,e)removeComponent(o,e,peer,component);
        else

            assert(false,'Position can either be numeric or a string');
        end




    elseif isa(parent,'matlab.ui.container.Toolbar')





        hgProxy=parent;
        peer=get(hgProxy,'JavaContainer');
        if isempty(peer)
            drawnow('update');
            peer=get(hgProxy,'JavaContainer');
        end
        peer.add(component);
        hgCleansJava=@(o,e)deleteComponent(o,e,hcomponent);
        javaCleansHG=@(o,e)removeComponent(o,e,peer,component);



    elseif(isa(parent,'matlab.ui.container.toolbar.ToggleSplitTool')||...
        isa(parent,'matlab.ui.container.toolbar.SplitTool'))





        hgProxy=parent;
        toolbar=get(hgProxy,'Parent');
        peer=get(hgProxy,'JavaContainer');
        parPeer=get(toolbar,'JavaContainer');
        if isempty(parPeer)
            drawnow('update');
        end
        if isempty(peer)
            drawnow('update');
            peer=get(hgProxy,'JavaContainer');
        end
        peer.add(component);
        hgCleansJava=@(o,e)deleteComponent(o,e,hcomponent);
        javaCleansHG=@(o,e)removeComponent(o,e,peer,component);
    else
        assert(false,'Invalid input');
    end
end











function enableAutoCleanup(hgowner,hcomponent,hgCleansJava,javaCleansHG)
    assert(ishghandle(hgowner));
    addlistener(hgowner,'ObjectBeingDestroyed',hgCleansJava);


    jListener=handle.listener(hcomponent,'ObjectBeingDestroyed',javaCleansHG);
    savelistener(hcomponent,jListener);
end


function newConstraint=validateLayoutConstraint(newConstraint)

    assert(isequal(char(newConstraint),char(java.awt.BorderLayout.NORTH))||...
    isequal(char(newConstraint),char(java.awt.BorderLayout.SOUTH))||...
    isequal(char(newConstraint),char(java.awt.BorderLayout.EAST))||...
    isequal(char(newConstraint),char(java.awt.BorderLayout.WEST))||...
    isequal(char(newConstraint),char('Overlay')));

end


function addJavaCallbacks(hcomponent,hcontainer,callback)

    if~isempty(callback)



        lsnrParent=hcontainer;
        if isempty(lsnrParent)
            lsnrParent=get(hcontainer,'parent');
        end
        if mod(length(callback),2)
            error(message('MATLAB:javacomponent:IncorrectUsage'));
        end
        for i=1:2:length(callback)
            lsnrs=getappdata(lsnrParent,'JavaComponentListeners');
            l=javalistener(java(hcomponent),callback{i},callback{i+1});
            setappdata(lsnrParent,'JavaComponentListeners',[l,lsnrs]);
        end
    end
end





function hdl=javalistener(jobj,eventName,response)
    try
        jobj=java(jobj);
    catch ex %#ok
    end


    if~ishandle(jobj)||~isjava(jobj)
        error(message('MATLAB:javacomponent:invalidinput'))
    end

    hSrc=handle(jobj,'callbackproperties');
    allfields=sortrows(fields(set(hSrc)));
    alltypes=cell(length(allfields),1);
    j=1;
    for i=1:length(allfields)
        fn=allfields{i};
        if contains(fn,'Callback')
            fn=strrep(fn,'Callback','');
            alltypes{j}=fn;
            j=j+1;
        end
    end
    alltypes=alltypes(~cellfun('isempty',alltypes));

    if nargin==1

        if nargout
            hdl=alltypes;
        else
            disp(alltypes)
        end
        return;
    end


    valid=any(cellfun(@(x)isequal(x,eventName),alltypes));

    if~valid
        error(message('MATLAB:javacomponent:invalidevent',class(jobj),char(cellfun(@(x)sprintf('\t%s',x),alltypes,'UniformOutput',false))'))
    end

    hdl=handle.listener(handle(jobj),eventName,...
    @(o,e)cbBridge(o,e,response));
    function cbBridge(o,e,response)
        hgfeval(response,java(o),e.JavaEvent)
    end
end




function savelistener(hC,hl)
    for i=1:numel(hC)
        p=findprop(hC(i),'Listeners__');
        if(isempty(p))
            p=schema.prop(hC(i),'Listeners__','handle vector');


            set(p,'AccessFlags.Serialize','off',...
            'AccessFlags.Copy','off',...
            'FactoryValue',[],'Visible','off');
        end

        hC(i).Listeners__=hC(i).Listeners__(ishandle(hC(i).Listeners__));
        hC(i).Listeners__=[hC(i).Listeners__;hl];
    end
end




function deleteComponent(~,~,hcomponent)
    if(ishandle(hcomponent))
        removeJavaCallbacks(hcomponent);
        delete(hcomponent);
    end
end





function removeComponent(~,~,peer,component)
    peer.remove(component);
end




function javaFrame=getJavaFrame(f)

    [lastWarnMsg,lastWarnId]=lastwarn;


    oldJFWarning=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    javaFrame=matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(f);
    warning(oldJFWarning.state,'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    lastwarn(lastWarnMsg,lastWarnId);
end
