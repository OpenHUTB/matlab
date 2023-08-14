function result=getCommentString(obj)



    result='';
    reqs=rmi.getReqs(obj);

    if isa(obj,'double')






        try
            modelH=bdroot(obj);

            if modelH~=obj
                linkStatus=get_param(obj,'StaticLinkStatus');
                if any(strcmp(linkStatus,{'implicit','resolved'}))
                    reqsInLib=rmi.getReqs(obj,true);
                    if~isempty(reqsInLib)
                        reqs=[reqs;reqsInLib];
                    end
                end



                if~isempty(get_param(modelH,'DataDictionary'))
                    [ddReqs,ddNames,ddSources]=rmide.getVarReqsForObj(obj);
                    if~isempty(ddReqs)
                        ddPrefix=[cell(size(reqs));strcat(strcat(ddSources',':'),ddNames')];
                        reqs=[reqs;ddReqs];
                    end
                end
            end
        catch ME %#ok<NASGU>

        end

    end

    if isempty(reqs)
        return;
    else

        doHide=~[reqs.linked]|strcmp({reqs.reqsys},'doors');
        if any(doHide)
            reqs(doHide)=[];
            if isempty(reqs)
                return;
            end
            if exist('ddPrefix','var')
                ddPrefix(doHide)=[];
            end
        end
    end

    if builtin('_license_checkout','Simulink_Requirements','quiet')
        disp(getString(message('Slvnv:rmi:licenseErrorDlg:FailedToCheckoutLicense')));
        return;
    end


    descriptions=cell(size(reqs));
    for i=1:numel(reqs)
        descriptions{i}=slreq.internal.getDescriptionOrDestSummary(reqs(i));
    end


    descriptions=strrep(descriptions,'/*','**');
    descriptions=strrep(descriptions,'*/','**');


    for i=1:length(descriptions)
        if exist('ddPrefix','var')&&~isempty(ddPrefix{i})
            prefix=['[',ddPrefix{i},'] '];
        else
            prefix='';
        end
        if i==1
            result=sprintf('*  %d. %s%s',i,prefix,descriptions{i});
        else
            result=sprintf('%s\n*  %d. %s%s',result,i,prefix,descriptions{i});
        end
    end
end


