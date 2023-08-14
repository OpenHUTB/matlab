function varargout=cg_widgets_ddg_cb(src,action,varargin)





    if isnumeric(src)&&ishandle(src)
        blockObj=get_param(src,'Object');
    else
        blockObj=src.getBlock;
    end

    [~,isLocked]=blockObj.getDialogSource.isLibraryBlock(src);

    switch(action)
    case 'preapply_cb'

        if(nargin==4)
            sigObjCache=varargin{1};
            dlg=varargin{2};
        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','cg_widgets_ddg_cb.m');
        end

        dlgSrc=dlg.getSource;
        [varargout{1},varargout{2}]=dlgSrc.preApplyCallback(dlg);
        dlg.refresh;

    case 'postapply_cb'

        if(nargin~=2)
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','cg_widgets_ddg_cb.m');
        end

        if~isLocked
            bd=bdroot(blockObj.Handle);
            set_param(bd,'dirty','on');
        end

        varargout={true,''};

    case 'postrevert_cb'

        if(nargin==3)
            sigObjCache=varargin{1};
        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','cg_widgets_ddg_cb.m');
        end

        state_restore_RTWInfo(sigObjCache,blockObj);

        varargout={true,''};

    case 'close_cb'

        if(nargin==5)
            closeAction=varargin{1};
            sigObjCache=varargin{2};

        else
            DAStudio.error('Simulink:dialog:InCorrectArgForSigProp','cg_widgets_ddg_cb.m');
        end

        blockObjStillValid=true;

        switch(closeAction)
        case 'ok'

        case 'cancel'
            lastErrorDiag=sllasterror;


            try
                blockHandle=blockObj.Handle;
                bd=bdroot(blockHandle);
                isModelDirty=get_param(bd,'dirty');
                state_restore_RTWInfo(sigObjCache,blockObj);
                if~isLocked
                    set_param(bd,'dirty',isModelDirty);
                end
            catch e %#ok








                blockObjStillValid=false;


                sllasterror(lastErrorDiag);


            end
        end

        if~isempty(sigObjCache)
            if(blockObjStillValid)
                openHandleIdx=find(sigObjCache.Editing{1}==blockObj.handle);
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

            end
            sigObjCache.ActiveTab=0;
        end


        if strcmp(blockObj.BlockType,'DataStoreMemory')
            dataStoreRWddg_cb(blockObj.Handle,'unhilite');
        end




    otherwise
        DAStudio.error('Simulink:dialog:UnknownCaseEncountered','cg_widgets_ddg_cb.m');
    end
end




function state_restore_RTWInfo(~,~)
end


