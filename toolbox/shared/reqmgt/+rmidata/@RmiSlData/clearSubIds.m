function clearSubIds(this,sid)




    [mdlName,id]=strtok(sid,':');
    try
        childIds=rmidata.RmiSlData.getNestedIDs(mdlName,id);
        for i=1:length(childIds)
            myId=childIds{i};
            dotHere=find(myId=='.');
            if length(dotHere)==1
                this.repository.setData(mdlName,myId,[]);
            end
        end
    catch %#ok<CTCH>
        error('ERROR in RmiSlData: Unable to clearSubIds for %s',sid);
    end
end
