classdef SignalSelectorSourceData<BindMode.BindModeSourceData






    properties(SetAccess=protected,GetAccess=public)
        modelName;


        clientName=BindMode.ClientNameEnum.SSM;

        isGraphical=true;
        modelLevelBinding=false;
        sourceElementPath;
        hierarchicalPathArray;
        sourceElementHandle;

        allowMultipleConnections=true;



        requiresDropDownMenu=true;
        dropDownElements;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)



        UpdateCallback=[];


        VisualListener=[];


        CloseListener=[];


        webScopeClientID='';
    end

    methods
        function newObj=SignalSelectorSourceData(modelName,sourceElementPath,allowMultipleConnections,...
            dropDownElementsNum,isGraphical,dropDownPrefix)

            newObj.modelName=modelName;



            newObj.allowMultipleConnections=allowMultipleConnections;

            newObj.sourceElementPath=sourceElementPath;
            try
                newObj.sourceElementHandle=get_param(sourceElementPath,'Handle');
            catch ME
                if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    newObj.sourceElementHandle=-1;
                end
            end
            newObj.hierarchicalPathArray=BindMode.utils.getHierarchicalPathArray(newObj.sourceElementPath);


            if(allowMultipleConnections&&strcmpi(dropDownPrefix,getString(message('Spcuilib:scopes:BindToDisplayType'))))

                try
                    scopeSpecObj=get_param(newObj.sourceElementHandle,'ScopeSpecificationObject');
                    if~isempty(scopeSpecObj)&&~isempty(scopeSpecObj.Block)
                        hApp=scopeSpecObj.Block.UnifiedScope;
                        cb=@(~,~)newObj.visualChangedCallback;
                        newObj.VisualListener=event.listener(hApp,'VisualChanged',cb);
                        newObj.CloseListener=event.listener(hApp,'CloseDialogsEvent',...
                        @(~,~)newObj.viewerWindowClosedCallback);
                    end
                catch ex
                    if strcmp(ex.identifier,'Simulink:Commands:ParamUnknown')

                    else
                        disp('Listeners not supported');
                    end
                end
            end




            newObj.dropDownElements=compose([dropDownPrefix,' %i'],1:dropDownElementsNum);



            newObj.isGraphical=isGraphical;
        end



        function delete(obj)
            obj.onViewerBindModeStatusChange(obj.sourceElementHandle);

            try
                bannerTimer=timerfind('Tag','ModelRefBanner');
            catch
                bannerTimer=[];
            end
            if~isempty(bannerTimer)


                for i=1:numel(bannerTimer)
                    if isvalid(bannerTimer(i))

                        bannerTimer(i).TimerFcn();
                        stop(bannerTimer(i));
                    end
                end
            end
        end
    end

    methods(Hidden)

        function setUpdateCallback(this,cb)
            this.UpdateCallback=cb;
        end


        function result=allowBindWhenSimulating(this)

            result=false;



            isScope=strcmp('Scope',get_param(this.sourceElementHandle,'BlockType'));

            if~isScope


                viewerMask=Simulink.Mask.get(this.sourceElementHandle);
                isMPlay=~isempty(viewerMask)&&contains(viewerMask.Type,'MPlay');
            end
            if(isScope&&strcmp(get(this.sourceElementHandle,'Floating'),'on'))||(~isScope&&isMPlay)
                result=true;
            end
        end

        function result=allowStateflowBinding(this)

            result=true;



            isScope=strcmp('Scope',get_param(this.sourceElementHandle,'BlockType'));

            if~isScope


                viewerMask=Simulink.Mask.get(this.sourceElementHandle);
                isMPlay=~isempty(viewerMask)&&contains(viewerMask.Type,'MPlay');
            end
            if~isScope&&isMPlay
                result=false;
            end
        end

        function result=allowModelReferenceBinding(this)

            result=false;



            blockType=get_param(this.sourceElementHandle,'BlockType');
            isScope=strcmp('Scope',blockType)||strcmp('WebTimeScopeBlock',blockType);

            if isScope
                result=true;
            end
        end
    end


    methods(Hidden)



        function setDropDownElements(this,dropDownElementsNum,dropDownPrefix)
            this.dropDownElements=compose([dropDownPrefix,' %i'],1:dropDownElementsNum);
        end



        function setRequiresDropDownMenu(this,dropDownMenuFlag)
            this.requiresDropDownMenu=dropDownMenuFlag;
        end

        function setWebScopeClientID(this,clientID)
            this.webScopeClientID=clientID;
            this.sendUpdateToWebScopeVisual(true);
        end
    end


    methods(Hidden)



        function visualChangedCallback(this,~)
            scopeSpecObj=get_param(this.sourceElementHandle,'ScopeSpecificationObject');
            hApp=scopeSpecObj.Block.UnifiedScope;
            scopeNumAxes=length(hApp.Visual.Displays);

            if(scopeNumAxes~=numel(this.dropDownElements))
                this.setDropDownElements(scopeNumAxes,getString(message('Spcuilib:scopes:BindToDisplayType')));
            end
        end

        function webScopeVisualChanged(this,scopeNumAxes)
            if(scopeNumAxes~=numel(this.dropDownElements))
                this.setDropDownElements(scopeNumAxes,getString(message('Spcuilib:scopes:BindToDisplayType')));
            end
        end



        function viewerWindowClosedCallback(this,~)
            this.onViewerBindModeStatusChange(this.sourceElementHandle);
            BindMode.BindMode.disableBindMode(get_param(bdroot(this.sourceElementHandle),'Object'));
        end



        function onViewerBindModeStatusChange(this,hBlock)
            if(this.webScopeClientID)
                this.sendUpdateToWebScopeVisual(false);
            else
                Function='Simulink.scopes.source.SignalSelectorController.Util';
                try


                    feval(Function,'DialogClosing',hBlock);
                catch
                end
            end
        end

        function sendUpdateToWebScopeVisual(this,toggleOnOrOff)
            channel=['/webscope',this.webScopeClientID];
            msg.action=['onSignalSelectorChange',this.webScopeClientID];
            msg.params.toggle=toggleOnOrOff;
            message.publish(channel,msg);
        end
    end
end
