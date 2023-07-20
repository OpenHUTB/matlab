function res=isUsingScheduleEditor(mdl)




    res=false;
    mgrBlk=soc.internal.connectivity.getTaskManagerBlock(mdl,true);
    if isempty(mgrBlk)||(iscell(mgrBlk)&&numel(mgrBlk)>1),return;end
    if isequal(get_param(mgrBlk,'UseScheduleEditor'),'off'),return;end
    res=true;
end
