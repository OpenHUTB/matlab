function pSID=getGraphicalParentSID(sid)





    try
        obj=Simulink.ID.getHandle(sid);

        if isnumeric(obj)
            obj=get_param(obj,'Object');
        end

        parent=obj.getParent();

        if~isempty(parent)
            pSID=Simulink.ID.getSID(parent);
        else
            pSID='';
        end
    catch E %#ok<NASGU>
        pSID='';
    end
end

