function objCopy(obj,reqStr,model,isSf)









    if nargin<2
        [isSf,objH,~]=rmi.resolveobj(obj);
        reqStr=rmi.getRawReqs(objH,isSf);
    else
        objH=obj;
    end
    try
        has_reqs=false;
        if~isempty(reqStr)&&~strncmp(reqStr,'{}',2)
            reqs=rmi.parsereqs(reqStr);
            idx=strcmp({reqs(:).reqsys},'doors');
            reqs(idx)=[];
            if~isempty(reqs)
                has_reqs=true;
            end
            reqstr=rmi.reqs2str(reqs);
        else
            reqstr='{}';
        end

        if nargin<3
            model=rmisl.getmodelh(objH);
        end


        rmi.setRawReqs(objH,isSf,reqstr,model);

        rmi.guidGet(objH,reqstr,model);


        if has_reqs&&strcmp(get_param(model,'ReqHilite'),'on')
            if isSf
                style=sf_style('req');
                sf_set_style(objH,style);
            else
                set_param(obj,'HiliteAncestors','reqHere');
            end
        end






        if has_reqs&&strcmp(get_param(model,'hasReqInfo'),'off')
            set_param(model,'hasReqInfo','on');
        end







    catch Mex
        error(message('Slvnv:reqmgt:objCopy:InfoDuplicateFailed',Mex.message));
    end
end

