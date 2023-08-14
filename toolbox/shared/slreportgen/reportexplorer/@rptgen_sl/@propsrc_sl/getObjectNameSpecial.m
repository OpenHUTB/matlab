function oName=getObjectNameSpecial(ps,obj,objType,d,isFullName)






    oName=ps.getObjectName(obj,objType);

    if isFullName
        oParent=locParent(obj);
        nameCell={oName};
        while~isempty(oParent)
            nameCell={ps.makeLinkScalar(oParent,'','link',d),'/',...
            nameCell{:}};
            oParent=locParent(oParent);
        end
        oName=createDocumentFragment(d,nameCell{:});
    end





    function par=locParent(obj)

        if isa(obj,'Simulink.BlockDiagram')
            par=[];
        elseif isa(obj,'Simulink.Object')
            par=up(obj);
        else
            par=get_param(obj,'Parent');
        end
