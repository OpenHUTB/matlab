classdef MenuCallbackUtils


    methods(Static)
        function slicerOpen(callbackInfo)
            modelH=callbackInfo.model.Handle;
            createSlicerDDG(modelH);
        end

        function slicerAddTarget(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)
                objs=getSelectedObjects(callbackInfo);

                uiObj.show();

                addSelectedHandles(objs);
            end

            function addSelectedHandles(h)
                dlgSrc=uiObj.getDialogSource;
                sigList=dlgSrc.sigListPanel;


                h=h(h>0);
                filt=arrayfun(@(x)strcmp(get(x,'Type'),'block'),h);
                blkH=h(filt);

                hasChange=false;
                mex={};
                for i=1:length(blkH)
                    if any([sigList.Model.terminalBlocks.Handle]==blkH(i))
                        mex{end+1}=MException('Slicer:SelectionIsExclusionPoint',...
                        getString(message('Sldv:ModelSlicer:gui:SelectionIsExclusionPoint',getfullname(blkH(i)))));%#ok<AGROW>                
                    elseif sigList.Model.modelSlicer.isBlockValidTarget(blkH(i))
                        sigList.Model.addBlock(blkH(i));
                        hasChange=true;
                    else
                        mex{end+1}=slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint(blkH(i));%#ok<AGROW>
                    end
                end


                filt2=arrayfun(@(x)strcmp(get(x,'Type'),'line'),h);
                lineH=h(filt2);

                for i=1:length(lineH)
                    p=get(lineH(i),'SrcPortHandle');
                    if any([sigList.Model.terminalBlocks.Handle]==p)


                        mex{end+1}=MException('Slicer:SelectionIsExclusionPoint',...
                        getString(message('Sldv:ModelSlicer:gui:SelectionIsExclusionPoint',getfullname(get(p,'Parent')))));%#ok<AGROW>      
                    elseif sigList.Model.modelSlicer.isPortValidTarget(p)
                        sigList.Model.addSignal(p);
                        hasChange=true;
                    else
                        mex{end+1}=slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint(p);%#ok<AGROW>
                    end
                end

                if~isempty(mex)

                    modelslicerprivate('MessageHandler','open',sigList.Model.modelSlicer.model);
                    for i=1:length(mex)
                        modelslicerprivate('MessageHandler','warning',mex{i},sigList.Model.modelSlicer.model)
                    end
                    modelslicerprivate('MessageHandler','close');
                end


                if hasChange
                    scfg=dlgSrc.Model;
                    if scfg.requireAutoRefresh
                        sigList.Model.refresh;
                    else
                        uiObj.refresh;
                    end
                end
            end
        end

        function slicerAddTerminal(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)

                objs=getSelectedObjects(callbackInfo);

                uiObj.show();

                addSelectedBlockHandles(objs);
            end
            function addSelectedBlockHandles(h)
                dlgSrc=uiObj.getDialogSource;
                sigList=dlgSrc.sigListPanel;
                mex={};
                h=h(h>0);
                hasChange=false;
                for i=1:numel(h)
                    if strcmp(get(h(i),'Type'),'block')

                        ms=sigList.Model.modelSlicer;
                        if any([sigList.Model.elements.Handle]==h(i))
                            mex{end+1}=MException('Slicer:SelectionIsExclusionPoint',...
                            getString(message('Sldv:ModelSlicer:gui:SelectionIsStartingPoint',getfullname(h(i)))));%#ok<AGROW>
                        elseif ms.isBlockValidTarget(h(i))
                            sigList.Model.addTerminal(h(i));
                            hasChange=true;
                        else
                            mex{end+1}=slslicer.internal.DiagnosticsGenerator.getErrorForExclusionPoint(h(i));%#ok<AGROW>
                        end
                    end
                end
                if~isempty(mex)

                    modelslicerprivate('MessageHandler','open',sigList.Model.modelSlicer.model);
                    for i=1:length(mex)
                        modelslicerprivate('MessageHandler','warning',mex{i},sigList.Model.modelSlicer.model);
                    end
                    modelslicerprivate('MessageHandler','close');
                end
                if hasChange
                    scfg=dlgSrc.Model;
                    if scfg.requireAutoRefresh
                        sigList.Model.refresh;
                    else
                        uiObj.refresh;
                    end
                end
            end
        end

        function slicerShowInSlice(callbackInfo)
            modelH=callbackInfo.model.Handle;

            [sliceMapper,isTopModel]=sldvprivate('sliceActiveModelMapper','get',modelH);
            out=~isempty(sliceMapper);

            objs=getSelectedObjects(callbackInfo);
            objs(objs==-1)=[];

            if isTopModel
                sliceMapper.highlightInSlice(objs);
            else
                sliceMapper.highlightInSlice(objs,get_param(modelH,'Name'));
            end
        end

        function slicerShowInOrig(callbackInfo)
            modelH=callbackInfo.model.Handle;
            objs=getSelectedObjects(callbackInfo);
            objs(objs==-1)=[];
            slcrMapObj=sldvprivate('sliceMdlMapperObj','get',modelH);
            slcrMapObj.highlightInOrig(objs);
        end

        function slicerSelectSubsystem(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)
                obj=getSelectedObjects(callbackInfo);
                Transform.SubsystemSliceUtils.addToSlice(obj,uiObj);
            end
        end
    end
end

function objs=getSelectedObjects(cbInfo)
    if~isempty(cbInfo.userdata)
        objs=cbInfo.userdata;
    else
        selection=cbInfo.getSelection;
        objs=vectorSelection(selection);
    end
end

function obj=vectorSelection(select)
    cnt=numel(select);
    obj=[];
    for idx=1:cnt
        objH=select(idx).Handle;
        obj(end+1)=objH;%#ok<AGROW>
    end
end
