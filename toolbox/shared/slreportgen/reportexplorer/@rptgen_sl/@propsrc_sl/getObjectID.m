function id=getObjectID(ps,obj,objType)







    if iscell(obj)
        obj=obj{1};
    end

    if nargin<3||isempty(objType)
        objType=ps.getObjectType(obj);
    end

    isSig=false;
    isAnno=false;
    switch lower(objType)
    case{'block','blk'}
        objType='blk';
    case{'system','sys'}
        objType='sys';
    case{'model','mdl'}
        objType='mdl';
    case{'signal','sig'}
        objType='sig';
        isSig=true;
    case{'annotation','anno'}
        objType='anno';
        isAnno=true;
    case{'configset'}
        objType='configset';
    case{'variable','var','workspacevar','simulink workspace variable'}
        objType='var';
    otherwise
        error(message('RptgenSL:rsl_propsrc_sl:unrecognizedObjectTypeError',objType));
    end

    try
        if isa(obj,'Simulink.Object')
            fn=obj.getFullName;
        elseif isa(obj,'Simulink.Parameter')
            fn=obj.getBoundObjectName();
        else
            fn=getfullname(obj);
        end

        if isSig

            if isa(obj,'Simulink.Object')
                portNum=obj.PortNumber;
            else
                portNum=get_param(obj,'PortNumber');
            end
            id=sprintf('sl-%s-%s-%i',...
            objType,...
            fn,...
            portNum);
        elseif isAnno

            if isa(obj,'Simulink.Object')
                pos=obj.Position;
            else
                pos=get_param(obj,'Position');
            end
            id=sprintf('sl-%s-%s-[%i-%i]',...
            objType,...
            fn,...
            pos(1),pos(2));
        else
            id=sprintf('sl-%s-%s',...
            objType,...
            fn);
        end

    catch ex %#ok<NASGU>
        id=sprintf('sl-%s-%s',...
        objType,...
        rptgen.toString(obj,0));
    end



    if~get(rptgen.appdata_rg,'DebugMode')
        id=char(mlreportgen.utils.normalizeLinkID(id));
    end

