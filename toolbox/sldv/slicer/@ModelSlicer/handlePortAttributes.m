function handlePortAttributes(obj,checkPortAttributes,fixPortAttributes,sliceMdl,UImode,expandLib,hasGlobal,sliceXfrmr,origAttrMap)




    import Transform.*;
    if checkPortAttributes
        if fixPortAttributes

            updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:CheckingPortAttributes');
            [deviation,simStateSlice]=Transform.detectCompileTimeMismatch(...
            obj,sliceMdl,false,UImode,obj.modelH,expandLib,hasGlobal,sliceXfrmr,origAttrMap);
            if~isempty(deviation)
                updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:FixingPortAttributes');
                simStateSlice=Transform.fixPortAttributes(sliceMdl,deviation,UImode,obj);
            end
            if~isempty(obj.SimState)&&~isempty(simStateSlice)
                applySimStateForSlicedModel(obj,simStateSlice,sliceMdl,sliceXfrmr.sliceMapper);
            else
                save_system(sliceMdl);
            end
        else

            updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:CheckingPortAttributes');
            Transform.detectCompileTimeMismatch(sliceMdl,true,[],obj.modelH,expandLib,hasGlobal,sliceXfrmr);
        end
    else
        save_system(sliceMdl);
        if UImode
            Mex=MException('ModelSlicer:PortVerificationSkipped',...
            getString(message('Sldv:ModelSlicer:gui:PortVerificationSkipped')));
            modelslicerprivate('MessageHandler','warning',Mex,sliceMdl)
        else
            warning('ModelSlicer:PortVerificationSkipped',...
            getString(message('Sldv:ModelSlicer:gui:PortVerificationSkipped')))
        end
    end
end
