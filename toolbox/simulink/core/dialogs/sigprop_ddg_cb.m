function[varargout]=sigprop_ddg_cb(action,portObj,varargin)




    assert(~isempty(portObj),DAStudio.message('Simulink:dialog:UnexptdEmptyForSigProp'));

    switch(action)
    case 'preapply_cb'

        if(nargin==4)
            sigObjCache=varargin{1};
            dlg=varargin{2};
        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','sigprop_ddg_cb.m');
        end

        busMode=get_param(bdroot(portObj.Parent),'StrictBusMsg');
        if(~strcmpi(busMode,'None')&&...
            ~strcmpi(busMode,'Warning')&&...
            portObj.supportsSignalPropagation)
            set_param(portObj.Handle,'ShowPropagatedSignals',...
            slprivate('onoff',dlg.getWidgetValue('DisplayPropagatedSignalLabels')));
        end

        varargout={true,''};

    case 'postapply_cb'

        if(nargin==3)
            lineObj=varargin{1};
        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','sigprop_ddg_cb.m');
        end



        if(~isempty(lineObj))
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',lineObj);
        end

        bd=bdroot(portObj.Handle);
        set_param(bd,'dirty','on');

        varargout={true,''};

    case 'postrevert_cb'

        if(nargin==4)
            lineObj=varargin{1};
            sigObjCache=varargin{2};
        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','sigprop_ddg_cb.m');
        end



        if(~isempty(lineObj))
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',lineObj);
        end

        varargout={true,''};

    case 'close_cb'

        if(nargin==5)
            closeAction=varargin{1};
            sigObjCache=varargin{2};
            dialog=varargin{3};
        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','sigprop_ddg_cb.m');
        end

        Simulink.CodeMapping.remove_mapping_listener(portObj,dialog);

        portObjStillValid=true;

        switch(closeAction)
        case 'ok'

        case 'cancel'
            lastErrorDiag=sllasterror;


            try
                portHandle=portObj.Handle;
                bd=bdroot(portHandle);
                isModelDirty=get_param(bd,'dirty');
                set_param(bd,'dirty',isModelDirty);
            catch e %#ok








                portObjStillValid=false;


                sllasterror(lastErrorDiag);


            end
        end

        if~isempty(sigObjCache)
            if(portObjStillValid)
                openHandleIdx=find(sigObjCache.Editing{1}==portObj.handle);
            else




                if isempty(sigObjCache.Editing{1})
                    openHandleIdx=[];
                else
                    assert(length(sigObjCache.Editing{1})==1);
                    openHandleIdx=1;
                end
            end
            if~isempty(openHandleIdx)
                assert(length(openHandleIdx)==1);

                sigObjCache.Editing{1}(openHandleIdx)=[];
                sigObjCache.Editing{2}(openHandleIdx)=[];
                sigObjCache.Editing{3}(openHandleIdx)=[];
            end
            sigObjCache.ActiveTab=0;
        end

    otherwise
        DAStudio.error('Simulink:dialog:UnknownCaseEncountered','sigprop_ddg_cb.m');
    end
end




