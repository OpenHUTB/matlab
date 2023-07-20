function varargout=catReqs(obj,reqs)







    try
        if ischar(obj)


            if any(obj==':')

                modelH=get_param(strtok(obj,':'),'Handle');
            else

                modelH=get_param(strtok(obj,'/'),'Handle');
            end
        else
            modelH=rmisl.getmodelh(obj(1));
        end
        isExternal=rmidata.isExternal(modelH);
    catch ME %#ok<NASGU>
        isExternal=true;
    end

    if isExternal





        reqs=slreq.uri.correctDestinationUriAndId(reqs);

        if ischar(obj)||length(obj)==1
            slreq.internal.catLinks(obj,reqs);
            if nargout>0
                result=slreq.utils.linkToStruct(slreq.utils.getLinks(obj));
            end
        else

            for i=1:length(obj)
                slreq.internal.catLinks(obj(i),reqs);
                if nargout>0
                    result{i}=slreq.utils.linkToStruct(slreq.utils.getLinks(obj(i)));%#ok<AGROW>
                end
            end
        end

    else



        if ischar(obj)||length(obj)==1

            result=rmi.getReqs(obj,-1,-1);

            result=catReqsPrim(result,reqs);

            rmi.setReqs(obj,result,-1,-1);
        elseif length(obj)>1

            for i=1:length(obj)
                result{i}=rmi.getReqs(obj(i),-1,-1);%#ok<AGROW>
                result{i}=catReqsPrim(result{i},reqs);%#ok<AGROW>
                rmi.setReqs(obj(i),result{i},-1,-1);
            end
        else

            error(message('Slvnv:reqmgt:catReqs:NoObject'));
        end
    end

    if nargout>0
        varargout{1}=result;
    end

end


function result=catReqsPrim(reqs,creqs)

    if isempty(creqs)
        result=reqs;
    elseif isempty(reqs)
        result=creqs(:);
    else
        result=[reqs(:);creqs(:)];
    end
end
