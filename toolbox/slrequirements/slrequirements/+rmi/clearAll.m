function result=clearAll(objs,silent)





    if ischar(objs)
        len=1;
        [~,obj,~]=rmi.resolveobj(objs);
        objs=obj;
    else
        len=length(objs);
    end

    if nargin<2
        silent=false;
    end

    if silent
        result=getString(message('Slvnv:rmi:clearAll:OK'));
    else
        if len==1
            objName=rmi.objname(objs);
            dialogTitle=getString(message('Slvnv:rmi:clearAll:DeleteAllLinks',objName));
            if isa(objs,'Simulink.SubSystem')
                confirmMessage={getString(message('Slvnv:rmi:clearAll:DeleteAllRequirementsForThisObject')),...
                getString(message('Slvnv:rmi:clearAll:WillNotDeleteRequirementsForAnyChild'))};
            else
                confirmMessage=getString(message('Slvnv:rmi:clearAll:DeleteAllRequirementsForThisObject'));
            end
        else
            dialogTitle=getString(message('Slvnv:rmi:clearAll:DeleteAll'));
            confirmMessage=getString(message('Slvnv:rmi:clearAll:DeleteAllRequirementsForNObjects',len));
        end

        result=questdlg(confirmMessage,dialogTitle,...
        getString(message('Slvnv:rmi:clearAll:OK')),...
        getString(message('Slvnv:rmi:clearAll:Cancel')),...
        getString(message('Slvnv:rmi:clearAll:Cancel')));
        if isempty(result)
            result=getString(message('Slvnv:rmi:clearAll:Cancel'));
        end
    end

    if strcmp(result,getString(message('Slvnv:rmi:clearAll:OK')))

        try
            doClearAll(objs,silent);
        catch ex
            if~isempty(strfind(ex.message,'rmi.resolveobj'))


                wopt=warning('query','backtrace');
                warning('off','backtrace');
                warning(ex.message);
                if strcmp(wopt.state,'on')
                    warning('on','backtrace');
                end
            else

                rethrow(ex);
            end
        end
    end

end

function doClearAll(objs,silent)

    for i=1:length(objs)

        if ischar(objs)

            obj=objs;
        else

            obj=objs(i);

            if rmisl.inLibrary(obj)||rmisl.inSubsystemReference(obj)
                if silent
                    continue;
                else
                    error(message('Slvnv:rmi:clearAll:InLibrary'));
                end
            end
        end


        leftover_reqs=[];


        protectSurrogateLinks=rmi.settings_mgr('get','protectSurrogateLinks');
        if isempty(protectSurrogateLinks)||protectSurrogateLinks
            reqs=rmi.getReqs(obj);
            if isempty(reqs)
                continue;
            end
            surrogate_link_idx=find(strcmp('doors',{reqs.reqsys}));
            if~isempty(surrogate_link_idx)
                if protectSurrogateLinks
                    leftover_reqs=reqs(surrogate_link_idx);
                else
                    dialogTitle=getString(message('Slvnv:rmi:clearAll:DeleteAllLinksSurrogateItem'));
                    dialogMessage={getString(message('Slvnv:rmi:clearAll:ObjectIsLinkedToSurrogate',rmi.objname(obj))),...
                    getString(message('Slvnv:rmi:clearAll:SuchLinksAreCreated')),...
                    getString(message('Slvnv:rmi:clearAll:IfYouChooseToCancel'))};
                    reply=questdlg(dialogMessage,dialogTitle,...
                    getString(message('Slvnv:rmi:clearAll:Keep')),...
                    getString(message('Slvnv:rmi:clearAll:Delete')),...
                    getString(message('Slvnv:rmi:clearAll:CancelAll')),...
                    getString(message('Slvnv:rmi:clearAll:Keep')));
                    if isempty(reply)||strcmp(reply,getString(message('Slvnv:rmi:clearAll:CancelAll')))
                        return
                    end
                    if strcmp(reply,getString(message('Slvnv:rmi:clearAll:Delete')))
                        protectSurrogateLinks=false;
                    else
                        protectSurrogateLinks=true;
                        leftover_reqs=reqs(surrogate_link_idx);
                    end
                    rmi.settings_mgr('set','protectSurrogateLinks',protectSurrogateLinks);
                end
            end
        end


        rmi.setReqs(obj,leftover_reqs,-1,-1);

        if~silent
            rmiut.hiliteAndFade(obj);
        end


        if~ischar(obj)&&rmisl.is_signal_builder_block(obj)

            if isa(obj,'Simulink.SubSystem')
                obj=obj.Handle;
            end



            blkInfo=rmisl.sigb_get_info(obj);
            origGroupRepCnt=blkInfo.groupReqCnt;
            blkInfo.blockH=obj;
            if isfield(blkInfo,'groupCnt')&&~isempty(blkInfo.groupCnt)&&...
                isfield(blkInfo,'groupReqCnt')&&~isempty(blkInfo.groupReqCnt)
                if isempty(leftover_reqs)
                    blkInfo.groupReqCnt=zeros(1,blkInfo.groupCnt);
                elseif length(leftover_reqs)==blkInfo.groupCnt
                    blkInfo.groupReqCnt=ones(1,blkInfo.groupCnt);
                else
                    rmi.setReqs(obj,{},-1,-1);
                    warning(message('Slvnv:rmi:clearAll:SigBuilderCleared'));
                    blkInfo.groupReqCnt=zeros(1,blkInfo.groupCnt);
                end

                if~all(origGroupRepCnt==blkInfo.groupReqCnt)
                    rmisl.sigb_write_info(blkInfo);
                    vnv_panel_mgr('sbForceRefresh',obj);
                end
            end
        end
    end
end


