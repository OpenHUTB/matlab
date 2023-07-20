


function link=getLinkFromID(this,linkSet,sid)







    if ischar(sid)
        [token,remain]=strtok(sid,'#');
        if~isempty(remain)
            sid=remain(2:end);
        else
            sid=token;
        end

        sid=int32(str2num(sid));%#ok<ST2NM>
    else
        sid=int32(sid);
    end


    linkSetObj=this.getModelObj(linkSet);

    link=[];


    cLink=linkSetObj.links{sid};
    if~isempty(cLink)
        link=this.wrap(cLink);
    end
end
