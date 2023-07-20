classdef BaseAxesInteractionContainer<matlab.graphics.interaction.interactioncontainers.InteractionContainer




    properties(Transient,Hidden)
        is2d(1,1)logical=true;
        AxesVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
NumDataSpaces
    end

    properties(Transient,Hidden,SetObservable=true)
        CurrentMode='none';
    end

    properties(Hidden)
        Ever3d(1,1)logical=false;
    end

    properties(Dependent,Transient)
Strategy
    end

    properties(Hidden,Transient)
Strategy_I
        StrategyMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods(Abstract)
        newint=createInteraction(hObj,int,ax,fig);
        newint=createWebInteraction(hObj,int,ax,fig);

        int=addInternalInteractions(hObj,ax,fig);

        ret=shouldRecreateInteractionsAfterStateUpdate(hObj,ax,is2dim,numDataSpaces);
        ret=shouldRecreateWebModeInteractions(hObj,is2dim);

        ret=shouldCreateDefaultWebInteractions(hObj,ax,can);

        strat=getDefaultStrategy(hObj);
    end

    methods
        function set.is2d(obj,d)
            if~d
                obj.Ever3d=true;
            end
            obj.is2d=d;
        end

        function findConflicts(hObj,array)
            hObj.findDuplicateInteractions(array);
            hObj.findConflictingInteractions(array);
        end

        function findConflictingInteractions(~,array)
            numfound=0;
            for i=1:numel(array)
                if isa(array(i),'matlab.graphics.interaction.interactions.PanInteraction')||...
                    isa(array(i),'matlab.graphics.interaction.interactions.RotateInteraction')||...
                    isa(array(i),'matlab.graphics.interaction.interactions.RegionZoomInteraction')

                    numfound=numfound+1;
                end
            end

            if numfound>1
                me=MException(message('MATLAB:graphics:interaction:ConflictFound'));
                throwAsCaller(me);
            end
        end

        function findDuplicateInteractions(~,array)
            b=cell(numel(array),1);
            for i=1:numel(array)
                b{i}=class(array(i));
            end

            a=unique(b);
            if(numel(a)~=numel(array))
                me=MException(message('MATLAB:graphics:interaction:DuplicateFound'));
                throwAsCaller(me);
            end
        end

        function updateInteractionsAfterDisablingThem(hObj)
            ax=hObj.GObj;
            try
                is2dim=true;
                numDataSpaces=1;
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.createDefaultInteractionsOnAxes(ax,is2dim,numDataSpaces);
            catch
            end
        end

        function updateInteractions(hObj)
            ax=hObj.GObj;
            try
                is2dim=ax.GetLayoutInformation.is2D;
                numDataSpaces=hObj.NumDataSpaces;
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.createDefaultInteractionsOnAxes(ax,is2dim,numDataSpaces);
            catch
            end
        end

        function setupInteractions(hObj,is2dim,numDataSpaces)

            ax=hObj.GObj;
            can=hObj.Canvas;

            visibilityChanged=~isequal(ax.InteractionContainer.AxesVisible,ax.Visible);
            hObj.AxesVisible=ax.Visible;
            if(strcmp(ax.HandleVisibility,'off'))
                hObj.clearList();
                return;
            end

            if strcmp(hObj.CurrentMode,'none')
                shouldRecreateInteractions=hObj.shouldRecreateInteractionsAfterStateUpdate(ax,is2dim,numDataSpaces);



                if visibilityChanged||shouldRecreateInteractions
                    hObj.clearList();
                end

                hObj.is2d=is2dim;
                hObj.NumDataSpaces=numDataSpaces;

                if strcmp(hObj.Enabled,'off')
                    hObj.clearList();
                    return;
                end

                if isempty(hObj.List)||~hasValidInteractions(hObj.List)
                    hObj.clearList();

                    intarray=hObj.unpackageInteractionsArray(ax,is2dim);

                    if hObj.shouldCreateDefaultWebInteractions(ax,can)
                        list=hObj.createDefaultWebAxesInteractions(intarray);
                        interactions=matlab.graphics.interaction.internal.WebInteractionsList(can,list);
                    else
                        l1=hObj.createDefaultAxesInteractions(intarray);
                        l2={};
                        if~matlab.graphics.interaction.internal.isWebAxes(ax)
                            l2=hObj.addAllJavaAxesInternalInteractions();
                        end

                        list=[l1,l2];
                        interactions=matlab.graphics.interaction.internal.InteractionsList(list);
                    end

                    hObj.List=interactions;
                end
            elseif isa(can,'matlab.graphics.primitive.canvas.HTMLCanvas')
                shouldRecreateWebModeInteractions=hObj.shouldRecreateWebModeInteractions(is2dim);

                if visibilityChanged||shouldRecreateWebModeInteractions
                    hObj.clearList();
                end

                if isempty(hObj.List)||~isvalid(hObj.List)
                    hObj.List=matlab.graphics.interaction.webmodes.setupModeInteraction(ax,can,hObj.CurrentMode,is2dim);
                    hObj.is2d=is2dim;
                end
            end
        end

        function intarray=unpackageInteractionsArray(hObj,ax,is2dim)
            intarray=hObj.InteractionsArray;
            if isa(intarray,'matlab.graphics.interaction.interface.BaseInteractionSet')
                intarray=intarray.createInteractionArray(ax,is2dim);
            end
        end

        function list=createDefaultAxesInteractions(hObj,intarray)
            ais=hObj.getStrategy;
            fig=hObj.Figure;
            ax=hObj.GObj;

            list1=hObj.createDefaultSetAxesInteractions(fig,ax,ais,intarray);
            list2=hObj.createAxesSpecificInteractions(fig,ax,ais);
            list=[list1,list2];
        end

        function list=createDefaultSetAxesInteractions(hObj,fig,ax,ais,intarray)
            list={};
            for i=1:numel(intarray)
                currentinteraction=intarray(i);

                newint=hObj.createInteraction(currentinteraction,ax,fig);

                for j=1:numel(newint)
                    newint(j).strategy=ais;
                    newint(j).enable();
                    list{end+1}=newint(j);
                end
            end
        end

        function list=createAxesSpecificInteractions(hObj,fig,ax,ais)

            list={};
            internalints=hObj.addInternalInteractions(ax,fig);
            for j=1:numel(internalints)
                if~isempty(internalints(j))
                    internalints(j).strategy=ais;
                    internalints(j).enable();
                    list{end+1}=internalints(j);
                end
            end
        end

        function list=addAllJavaAxesInternalInteractions(hObj)
            ax=hObj.GObj;








            list={};
            if strcmp(ax.Visible,'off')
                invisibleAxesHandler=matlab.graphics.interaction.uiaxes.InvisibleAxesEnterExit(ax);
                invisibleAxesHandler.enable();
                list{end+1}=invisibleAxesHandler;
            end

        end

        function list=createDefaultWebAxesInteractions(hObj,intarray)
            can=hObj.Canvas;
            ax=hObj.GObj;

            list={};
            for i=1:numel(intarray)
                currentinteraction=intarray(i);
                newint=hObj.createWebInteraction(currentinteraction,can,ax);

                for j=1:numel(newint)
                    can.InteractionsManager.registerInteraction(ax,newint(j));
                    list{end+1}=newint(j);
                end
            end

        end

        function set.Strategy(obj,s)
            obj.Strategy_I=s;
            obj.StrategyMode='manual';
        end

        function s=get.Strategy(obj)
            s=obj.Strategy_I;
        end

        function s=getStrategy(obj)
            if strcmp(obj.StrategyMode,'auto')
                s=obj.getDefaultStrategy();
                obj.Strategy=s;
            end

            s=obj.Strategy;
        end

        function set.CurrentMode(obj,mode)
            fig=ancestor(obj.GObj,'figure');
            if(~strcmp(mode,obj.CurrentMode))
                if(strcmp(mode,'none'))
                    obj.CurrentMode='none';
                    matlab.graphics.interaction.webmodes.figureModeInteractionOnExit(fig);
                else
                    obj.CurrentMode=mode;
                    matlab.graphics.interaction.webmodes.figureModeInteractionOnEnter(fig);
                end
            end
        end
    end
end

