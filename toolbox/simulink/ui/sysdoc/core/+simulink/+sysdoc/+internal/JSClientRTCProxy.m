

classdef(Abstract)JSClientRTCProxy<handle
    properties(Access=public)
    end


    properties(Constant)
        RTC_EMPTY_CONTENT='{"className":"RootNode","children":[{"className":"RichTextParagraphNode","align":"left","children":[{"className":"RichTextNode","text":""}]}]}';
        NOTES_BASE_CHANNEL='/sysdocrtc';
    end

    methods(Static)





        function setRTCEditMode(studioTag,editMode)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onSetEditMode';
            message.publish(sysdocRTCChannel,struct('func',funcString,'isReadOnly',~editMode));
        end

        function onRTCEditAction(studioTag,actionTag)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onRTCEditAction';
            message.publish(sysdocRTCChannel,struct('func',funcString,'actionTag',actionTag));
        end


        function onSaveDocument(studioTag,sid,modelName)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onSaveDocument';
            message.publish(sysdocRTCChannel,struct('func',funcString,'sid',sid,'model',modelName));
        end

        function onPrintPage(studioTag,sid,modelName)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onPrintPage';
            message.publish(sysdocRTCChannel,struct('func',funcString,'sid',sid,'model',modelName));
        end

        function onPrintJSONContent(studioTag,sid,model,jsonContent)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onPrintRichText';
            message.publish(sysdocRTCChannel,...
            struct('func',funcString,'sid',sid,'model',model,'content',jsonContent));
        end

        function sendJSONContentToRTC(studioTag,jsonContent)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            if isempty(jsonContent)
                jsonContent=JSClientRTCProxy.RTC_EMPTY_CONTENT;
            end
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onLoadDocument';
            message.publish(sysdocRTCChannel,struct('func',funcString,'jsonContent',jsonContent));
        end

        function sendPing(studioTag)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            sysdocRTCChannel=['/',studioTag,JSClientRTCProxy.NOTES_BASE_CHANNEL];
            funcString='onPing';
            message.publish(sysdocRTCChannel,struct('func',funcString));
        end



        function varargout=receiveJSONContentFromRTC(varargin)
            varargout{1}=[];




            if nargin<1

                return;
            end

            Action=varargin{1};

            currentStudioTag=varargin{2};
            args=varargin(3:end);

            switch(Action)

            case 'onSaveDocument'

                modelName=args{1};
                studioWidgetMgr=getModelStudioWidgetManagerFromTag(currentStudioTag,modelName);
                if isempty(studioWidgetMgr)



                    return;
                end
                studioWidgetMgr.saveJSONContentFromRTC(args{2},args{3});
            case 'onRTCEditorLoaded'

                app=simulink.SystemDocumentationApplication.getInstance();
                varargout{1}=app.getRTCRequestFrontController().onRTCEditorLoaded(currentStudioTag);
            case 'onActionChange'

                contentWidget=getContentWidgetFromTag(currentStudioTag);
                if isempty(contentWidget)

                    return;
                end
                contentWidget.actionChanged(args{1},args{2},args{3});








            case 'onHelperPageAction'

                studioWidgetMgr=getStudioWidgetManagerFromTag(currentStudioTag);
                if isempty(studioWidgetMgr)

                    return;
                end
                studioWidgetMgr.helperPageAction(args{1});

            case 'onPrintRTCContent'
                app=simulink.SystemDocumentationApplication.getInstance();
                sysdoc=app.getSystemDocumentation(args{1});
                if isempty(sysdoc)

                    return;
                end
                sysdoc.printContents(args{3},args{1},args{2});

            case 'returnPong'
                import simulink.sysdoc.internal.JSClientRTCProxy;
                JSClientRTCProxy.setDonePingPong(true,currentStudioTag)
            end
        end
    end

    methods(Static,Access={?sysdoc.NotesTester,?SysDocTestInterface})



        function setDonePingPong(donePingPong,currentStudioTag)
            app=simulink.SystemDocumentationApplication.getInstance();
            app.getRTCRequestFrontController().setDonePingPong(donePingPong,currentStudioTag);
        end

        function donePingPong=getDonePingPong(currentStudioTag)
            app=simulink.SystemDocumentationApplication.getInstance();
            donePingPong=app.getRTCRequestFrontController().getDonePingPong(currentStudioTag);
        end
    end

end









function contentWidget=getContentWidgetFromTag(studioTag)
    contentWidget=[];
    studioWidgetMgr=getStudioWidgetManagerFromTag(studioTag);
    if isempty(studioWidgetMgr)
        return;
    end
    contentWidget=studioWidgetMgr.getContentWidget();
end

function studioWidgetMgr=getStudioWidgetManagerFromTag(studioTag)
    import simulink.sysdoc.internal.SysDocUtil;
    studioWidgetMgr=[];
    studio=DAS.Studio.getStudio(studioTag);
    if~SysDocUtil.isNotEmptyAndValid(studio)
        return;
    end
    studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
end

function studioWidgetMgr=getModelStudioWidgetManagerFromTag(studioTag,modelName)
    import simulink.sysdoc.internal.SysDocUtil;
    studioWidgetMgr=[];
    studio=DAS.Studio.getStudio(studioTag);
    if~SysDocUtil.isNotEmptyAndValid(studio)
        return;
    end
    studioWidgetMgr=SysDocUtil.getModelStudioWidgetManager(studio,modelName);
end
