classdef FigureCodeGenManager<handle

    properties(Hidden)
        FigureCodeGenFeatureFlag matlab.lang.OnOffSwitchState='off'
        FigureCodeGenDebug matlab.lang.OnOffSwitchState='off'

        CodeGenMap=[]
    end

    properties(Hidden,Constant)
        CODEGEN_PANEL_ID='codegen'
        CODEGEN_REGION='bottom'
        CODEGEN_CREATE_PANEL_COLLAPSED=false
        CODEGEN_DOM_NODE_ID='figureCodeGenWidgetDiv'
    end

    methods(Static)
        function obj=getInstance()
mlock
            persistent instance
            if isempty(instance)
                instance=matlab.graphics.internal.codegenwidget.FigureCodeGenManager();
            end
            obj=instance;
        end

        function useFigureCodeGenWidget()

            import matlab.graphics.internal.*;

            factory=FigureToolstripActionFactory.getInstance();
            factory.setCodeGenEnabledState(matlab.lang.OnOffSwitchState.on);
        end

        function createWidgetUI(parentFigure)


            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;
            divFigure=[];
            if parentFigure.isCodeGenCheckboxSelected
                doAddPanel=false;
                if isempty(parentFigure.SidePanelCodeGenInstance)||~isvalid(parentFigure.SidePanelCodeGenInstance)
                    channel="";

                    if isprop(parentFigure,'MOLToolstripMggId')
                        channel=parentFigure.MOLToolstripMggId;
                    end


                    parentFigure.SidePanelCodeGenInstance=matlab.graphics.internal.codegenwidget.FigureCodeGen(channel);
                    doAddPanel=true;
                end

                generatedCodeStr=getString(message('MATLAB:graphics:figurecodegenwidget:generatedCode'));
                if~isempty(parentFigure.Name)
                    widgetName=strcat(generatedCodeStr," (",parentFigure.Name,")");
                elseif~isempty(parentFigure.Tag)
                    widgetName=strcat(generatedCodeStr," (",parentFigure.Tag,")");
                elseif~isempty(parentFigure.Number)
                    widgetName=strcat(generatedCodeStr," (Figure ",string(parentFigure.Number),")");
                else
                    widgetName=getString(message('MATLAB:graphics:figurecodegenwidget:figureGeneratedCode'));
                end

                fcm=FigureCodeGenManager.getInstance;
                panel_id=fcm.CODEGEN_PANEL_ID;
                panel_region=fcm.CODEGEN_REGION;
                panel_collapsed=fcm.CODEGEN_CREATE_PANEL_COLLAPSED;
                panel_node_id=fcm.CODEGEN_DOM_NODE_ID;
                matlab.graphics.internal.sidepanel.showSidePanel(divFigure,...
                panel_id,widgetName,panel_region,panel_collapsed,parentFigure,panel_node_id,doAddPanel);
            end
        end

        function updateCodeGenStruct(channelId,code)

            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            if isempty(fcm.CodeGenMap)
                fcm.CodeGenMap=containers.Map;
            end
            codeGenWidgetStruct=struct('Code',code);
            fcm.CodeGenMap(channelId)=codeGenWidgetStruct;
        end

        function resetCodeGenInfoMap(channelId)


            import matlab.graphics.internal.codegenwidget.FigureCodeGenManager;

            fcm=FigureCodeGenManager.getInstance;
            if~isempty(fcm.CodeGenMap)&&isKey(fcm.CodeGenMap,channelId)
                remove(fcm.CodeGenMap,channelId);
            end
            if isempty(fcm.CodeGenMap)
                fcm.CodeGenMap=[];
            end
        end

        function resetCodeGenCheckboxProperty()



            hFigArray=findobjinternal(0,'Type','Figure','isCodeGenCheckboxSelected',1);
            for i=1:numel(hFigArray)
                if isvalid(hFigArray(i))
                    hFigArray(i).isCodeGenCheckboxSelected=false;
                    if isprop(hFigArray(i),'SidePanelCodeGenInstance')&&isvalid(hFigArray(i).SidePanelCodeGenInstance)
                        hFigArray(i).SidePanelCodeGenInstance.isWidgetVisible=false;
                    end
                end
            end
        end
    end
end