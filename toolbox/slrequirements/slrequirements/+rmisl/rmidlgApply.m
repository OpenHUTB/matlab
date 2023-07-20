function[success,info,newCount]=rmidlgApply(dlgSrc,reqs)





    totalObjects=length(dlgSrc.objectH);
    if totalObjects>1

        cat_performed=0;
        sigbfound=0;
        newCount=0;
        info='';
        for i=1:totalObjects
            obj=dlgSrc.objectH(i);
            if rmi('ishandlevalid',obj)
                if strcmp(dlgSrc.source,'simulink')&&rmisl.is_signal_builder_block(obj)
                    sigbfound=1;
                else
                    try
                        rmi.catReqs(obj,reqs);
                        cat_performed=cat_performed+1;
                    catch Mex
                        info=sprintf('%s\n%s',info,Mex.message);
                    end
                end
            else
                warning(message('Slvnv:reqmgt:rmidlg_apply:InvalidObjectHandle',sprintf('%f',obj)));
            end
        end

        if cat_performed==totalObjects
            success=true;
            info='';
        else
            success=false;
            info=sprintf('%s\n%s',...
            getString(message('Slvnv:reqmgt:rmidlg_apply:x0numberintegerOutOf1numberinteger',cat_performed,totalObjects)),...
            info);
        end


        if sigbfound
            msgbox(getString(message('Slvnv:reqmgt:rmidlg_apply:RequirementsNotAddedToSigBuilder')),...
            getString(message('Slvnv:reqmgt:rmidlg_apply:Requirements')));
        end

    else

        if rmi('ishandlevalid',dlgSrc.objectH(1))
            try
                rmi.setReqs(dlgSrc.objectH(1),reqs,dlgSrc.index,dlgSrc.count);
            catch Mex
                errordlg(Mex.message,getString(message('Slvnv:reqmgt:rmidlg_apply:RequirementsFailedModifyLinks')));
            end
            success=true;
            info='';
            newCount=length(reqs);
        else
            success=false;
            info=getString(message('Slvnv:reqmgt:rmidlg_apply:FailedApplyChangesObject',sprintf('%f',dlgSrc.objectH(1))));
            newCount=-1;
        end
    end
end
