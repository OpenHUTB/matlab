function id=getObjectID(ps,object,objType)







    isHashed=false;
    if isempty(object)
        id='';

    elseif ischar(object)||isa(object,'Simulink.SubSystem')


        if nargin<3
            objType='';
        end
        id=getObjectID(ps,rptgen_sf.block2chart(object),objType);

    elseif isa(object,'Stateflow.Root')
        id='sf-root';

    elseif isa(object,'Simulink.Root')
        id='sl-root';

    elseif isa(object,'Stateflow.Clipboard')
        id='sf-clipboard';

    elseif isa(object,'Stateflow.SLFunction')
        slObject=object.getDialogProxy;
        id=getObjectID(rptgen_sl.propsrc_sl,slObject);
        isHashed=true;

    else
        if nargin<3||isempty(objType)
            objType=getObjectType(ps,object);
        end
        objType=strrep(objType,' ','-');
        id=sprintf('sf-%s-%i',lower(objType),get(object,'id'));
    end



    if~get(rptgen.appdata_rg,'DebugMode')&&~isHashed
        id=char(mlreportgen.utils.normalizeLinkID(id));
    end
