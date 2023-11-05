classdef FigureCodeGenController<handle

    properties
        CodeGenerationProxy;
        InteractionListener;
        ShowCodeToolstripInteractionListener;
        CodeGenerator;
        Figure;
        ActionRegistrator;
        UIDestroyedListener;
        FigureActivatedListener;
        UnselectCodeGenCheckboxOnPanelCloseListener;
        SidePanelDestroyedOnBrowserRefreshListener;
        SidePanelSelectedListener;
        CodeGenClearActionsListener;
        CLOSEPANEL_CHANNEL='/figure/sidePanel/closePanel';
        SIDEPANELACTIONS_CHANNEL='/figure/sidePanel/actions';
        SIDEPANEL_BROWSER_REFRESH='/figure/sidePanel/browserRefresh';
    end

    events(Hidden)
CodeGenWidgetStateChanged
    end

    methods
        function this=FigureCodeGenController(f)
            this.ActionRegistrator=matlab.internal.editor.figure.Registrator;
            this.CodeGenerationProxy=matlab.internal.editor.CodeGenerationProxy(this.ActionRegistrator);
            if~isprop(f,'CodeGenerationProxy')
                pCodeGenerationProxy=addprop(f,'CodeGenerationProxy');
                pCodeGenerationProxy.Hidden=true;
                f.CodeGenerationProxy=this.CodeGenerationProxy;
            end
            if isprop(f,'FigureChannelId')
                channel=get(f,'FigureChannelId');
            else
                channel=matlab.ui.internal.FigureServices.getUniqueChannelId(f);
            end
            this.InteractionListener=event.listener(this.CodeGenerationProxy,'InteractionOccured',@(e,d)this.interactionHandler);
            this.FigureActivatedListener=event.listener(f,'FigureActivated',@(e,d)this.updateCodeOnFigureSidePanelActivation(d));
            this.SidePanelSelectedListener=message.subscribe(strcat(this.SIDEPANELACTIONS_CHANNEL,'/sidepanel/codegen/',channel),@(msg)this.updateCodeOnFigureSidePanelActivation(msg),'autoUnsub',true,'enableDebugger',false);
            this.ShowCodeToolstripInteractionListener=event.proplistener(f,f.findprop('isCodeGenCheckboxSelected'),'PostSet',@(e,d)this.showCodeInteractionHandler);
            this.SidePanelDestroyedOnBrowserRefreshListener=message.subscribe(strcat(this.SIDEPANEL_BROWSER_REFRESH),@(msg)this.updateCodeGenStateOnBrowserRefresh(msg),'autoUnsub',true,'enableDebugger',false);
            this.Figure=f;
            this.UIDestroyedListener=event.listener(this.Figure,'ObjectBeingDestroyed',@(e,d)localDelete(this));
            codeGenerationObjInitializationFcn=@()this.initializeCodeGeneratorOnFigureViewReady();
            matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(this.Figure,codeGenerationObjInitializationFcn);
        end
    end

    methods(Access=private)
        function interactionHandler(this)




            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            channel="";
            if isprop(this.Figure,'MOLToolstripMggId')
                channel=this.Figure.MOLToolstripMggId;
            end



            if isCodeGenSelected(this)&&(~isSidePanelCodeGenInstanceValid(this)||~isWidgetVisible(this))
                matlab.graphics.internal.codegenwidget.FigureCodeGenManager.createWidgetUI(this.Figure);
                this.Figure.SidePanelCodeGenInstance.isWidgetVisible=true;
                subscribeToUnselectCodeGenCheckboxListenerIfNeeded(this,channel);
                this.attachCodeGenClearActionListener();
            end



            if~isCodeGeneratorInstanceValid(this)
                this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.Figure,this.ActionRegistrator);
            end
            code=this.CodeGenerator.generateCode;
            if length(code)>1
                code=strjoin(code,'\n');
            end
            code=string(code);
            if isempty(code)
                code=strcat("% ",getString(message('figuredatatools:figurecodegenwidgetjs:EmptyCodeGenerationString')));
            end
            if isCodeGenSelected(this)&&isWidgetVisible(this)
                this.Figure.SidePanelCodeGenInstance.setCode(code);
            end
            fcm.updateCodeGenStruct(channel,code);
        end

        function showCodeInteractionHandler(this)


            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            channel="";
            if isprop(this.Figure,'MOLToolstripMggId')
                channel=this.Figure.MOLToolstripMggId;
            end

            if isCodeGenSelected(this)
                if~isempty(fcm.CodeGenMap)&&isKey(fcm.CodeGenMap,channel)
                    codeGenStruct=fcm.CodeGenMap(channel);
                    if~isempty(codeGenStruct.Code)
                        matlab.graphics.internal.codegenwidget.FigureCodeGenManager.createWidgetUI(this.Figure);
                        this.Figure.SidePanelCodeGenInstance.isWidgetVisible=true;
                        subscribeToUnselectCodeGenCheckboxListenerIfNeeded(this,channel);
                        this.attachCodeGenClearActionListener();
                        code=codeGenStruct.Code;
                        if this.Figure.isCodeGenCheckboxSelected&&isWidgetVisible(this)
                            this.Figure.SidePanelCodeGenInstance.setCode(code);
                        end
                    else
                        if isSidePanelCodeGenInstanceValid(this)
                            this.Figure.SidePanelCodeGenInstance.isWidgetVisible=false;
                        end
                    end
                end
            else
                if~isempty(fcm.CodeGenMap)&&isKey(fcm.CodeGenMap,channel)
                    if isSidePanelCodeGenInstanceValid(this)
                        this.Figure.SidePanelCodeGenInstance.isWidgetVisible=false;
                    end





                    if isUnselectCheckboxListenerValid(this)
                        this.UnselectCodeGenCheckboxOnPanelCloseListener.delete;
                    end
                    this.UnselectCodeGenCheckboxOnPanelCloseListener=[];
                    matlab.graphics.internal.sidepanel.hideSidePanel('codegen',this.Figure);
                end
            end
        end

        function updateCodeGenStateOnBrowserRefresh(this,msg)


            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            this.toggleCheckBox(msg.event);
            fcm.resetCodeGenCheckboxProperty();
        end

        function updateCodeOnFigureSidePanelActivation(this,~)


            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            channel="";





            if isequal(this.Figure,get(groot,'CurrentFigure'))&&isSidePanelCodeGenInstanceValid(this)
                if isvalid(this.Figure)&&isprop(this.Figure,'MOLToolstripMggId')
                    channel=this.Figure.MOLToolstripMggId;
                end







                if~isempty(fcm.CodeGenMap)&&isKey(fcm.CodeGenMap,channel)
                    codeGenStruct=fcm.CodeGenMap(channel);
                    if~isempty(codeGenStruct.Code)

                        if~isCodeGeneratorInstanceValid(this)
                            this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.Figure,this.ActionRegistrator);
                        end
                        code=this.CodeGenerator.generateCode;
                        if length(code)>1
                            code=strjoin(code,'\n');
                        end
                        code=string(code);
                        if isempty(code)
                            code=strcat("% ",getString(message('figuredatatools:figurecodegenwidgetjs:EmptyCodeGenerationString')));
                        end


                        if~isempty(fcm.CodeGenMap)&&isKey(fcm.CodeGenMap,channel)&&~isequal(fcm.CodeGenMap(channel),code)
                            if isWidgetVisible(this)
                                this.Figure.SidePanelCodeGenInstance.setCode(code);
                                subscribeToUnselectCodeGenCheckboxListenerIfNeeded(this,channel);
                            end
                            fcm.updateCodeGenStruct(channel,code);
                        end
                    end
                end
            end
        end

        function toggleCheckBox(this,~)




            widgetAndCheckboxState=false;
            if isSidePanelCodeGenInstanceValid(this)&&~isequal(this.Figure.SidePanelCodeGenInstance.isWidgetVisible,widgetAndCheckboxState)
                this.Figure.SidePanelCodeGenInstance.isWidgetVisible=widgetAndCheckboxState;
            end
            if isCodeGenSelected(this)
                this.Figure.isCodeGenCheckboxSelected=widgetAndCheckboxState;
                notify(this,'CodeGenWidgetStateChanged');
            end
        end

        function attachCodeGenClearActionListener(this)


            if isSidePanelCodeGenInstanceValid(this)
                this.CodeGenClearActionsListener=event.listener(this.Figure.SidePanelCodeGenInstance,...
                'CodeGenWidgetClearButtonAction',@(~,~)this.clearButtonAction());
            end
        end

        function clearButtonAction(this)

            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            channel="";
            if isvalid(this.Figure)&&isprop(this.Figure,'MOLToolstripMggId')
                channel=this.Figure.MOLToolstripMggId;
            end
            if~isempty(this.CodeGenerator)&&isvalid(this.CodeGenerator)
                this.ActionRegistrator.clear();
                code=this.CodeGenerator.generateCode;
                if length(code)>1
                    code=strjoin(code,'\n');
                end
                code=string(code);
                if isempty(code)
                    code=strcat("% ",getString(message('figuredatatools:figurecodegenwidgetjs:EmptyCodeGenerationString')));
                end
                if isWidgetVisible(this)
                    this.Figure.SidePanelCodeGenInstance.setCode(code);
                end
                fcm.updateCodeGenStruct(channel,code);
            end
        end

        function initializeCodeGeneratorOnFigureViewReady(this)






            this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.Figure,this.ActionRegistrator);
        end
    end
end

function ret=isCodeGenSelected(this)


    ret=~isempty(this.Figure.isCodeGenCheckboxSelected)&&this.Figure.isCodeGenCheckboxSelected;
end

function ret=isCodeGeneratorInstanceValid(this)


    ret=~isempty(this.CodeGenerator)&&isvalid(this.CodeGenerator)&&isCodeGeneratorAxesHandleValid(this);
end

function ret=isCodeGeneratorAxesHandleValid(this)




    hAx=findobj(this.Figure,'-isa','matlab.graphics.axis.AbstractAxes');
    validHandlesState=all(arrayfun(@(x)isvalid(x),this.CodeGenerator.AxesHandles));
    numelComparisionState=isequal(numel(hAx),numel(this.CodeGenerator.AxesHandles));
    handleElementsComparisionState=false;
    if numelComparisionState
        handleElementsComparisionState=true;
        for i=1:length(this.CodeGenerator.AxesHandles)
            if~ismember(this.CodeGenerator.AxesHandles(i),hAx)
                handleElementsComparisionState=false;
                break;
            end
        end
    end
    ret=validHandlesState&&numelComparisionState&&handleElementsComparisionState;
end

function ret=isSidePanelCodeGenInstanceValid(this)


    ret=~isempty(this.Figure.SidePanelCodeGenInstance)&&isvalid(this.Figure.SidePanelCodeGenInstance);
end

function ret=isWidgetVisible(this)


    ret=isSidePanelCodeGenInstanceValid(this)&&~isempty(this.Figure.SidePanelCodeGenInstance.isWidgetVisible)&&...
    this.Figure.SidePanelCodeGenInstance.isWidgetVisible;
end

function ret=isUnselectCheckboxListenerValid(this)


    ret=~isempty(this.UnselectCodeGenCheckboxOnPanelCloseListener)&&isvalid(this.UnselectCodeGenCheckboxOnPanelCloseListener);
end

function subscribeToUnselectCodeGenCheckboxListenerIfNeeded(this,channel)





    if~isUnselectCheckboxListenerValid(this)
        this.UnselectCodeGenCheckboxOnPanelCloseListener=message.subscribe(strcat(this.CLOSEPANEL_CHANNEL,'/sidepanel/codegen/',channel),@(msg)this.toggleCheckBox(msg),'autoUnsub',true,'enableDebugger',true);
    end
end

function localDelete(this)


    import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

    fcm=FigureCodeGenManager.getInstance;
    channel="";
    if isprop(this.Figure,'MOLToolstripMggId')
        channel=this.Figure.MOLToolstripMggId;
    end
    if~isempty(fcm.CodeGenMap)&&isKey(fcm.CodeGenMap,channel)&&isprop(this.Figure,'MOLToolstripMggId')
        fcm.resetCodeGenInfoMap(this.Figure.MOLToolstripMggId);
    end

    if isSidePanelCodeGenInstanceValid(this)
        this.Figure.SidePanelCodeGenInstance.delete();
    end
    this.ShowCodeToolstripInteractionListener=[];
    this.InteractionListener=[];
    this.FigureActivatedListener=[];
    this.UnselectCodeGenCheckboxOnPanelCloseListener=[];
    this.SidePanelDestroyedOnBrowserRefreshListener=[];
    this.SidePanelSelectedListener=[];
end