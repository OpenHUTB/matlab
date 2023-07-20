function oName=getObjectName(ps,obj,oType)






    if isempty(obj)
        oName='[]';
        return;
    end

    if ischar(obj)||isa(obj,'Simulink.SubSystem')


        if nargin<3
            oType='';
        end
        oName=getObjectName(ps,rptgen_sf.block2chart(obj),oType);
    elseif isempty(findprop(obj,'Name'))
        if isa(obj,'Stateflow.Transition')
            oName=get(obj,'LabelString');
            if strcmp(oName,'?')||isempty(oName)


                if sf('get',get(obj,'ID'),'.isDefault')
                    oType='DefaultTransition';
                else
                    oType='Transition';
                end
                oName=getDefaultName(obj,oType);
            else
                oName=getFirstLine(oName);
            end
        elseif isa(obj,'Stateflow.Note')||isa(obj,'Stateflow.Annotation')
            oName=get(obj,'Text');
            if strcmp(oName,'?')||isempty(oName)
                oName=getDefaultName(obj,'Annotation');
            else
                oName=getFirstLine(oName);
            end
        elseif isa(obj,'Stateflow.Port')
            oName=get(obj,'LabelString');
            if strcmp(oName,'?')||isempty(oName)
                oName=getDefaultName(obj,'Port');
            end
        else
            if nargin<3
                oType=getObjectType(ps,obj);
            end

            oName=getDefaultName(obj,oType);
        end
    else
        oName=strrep(get(obj,'Name'),newline,' ');
    end


    function oName=getDefaultName(obj,oType)

        if isempty(findprop(obj,'ID'))
            oName=oType;
        else



            oName=sprintf('%s%i',oType,get(obj,'SSIdNumber'));
        end


        function oName=getFirstLine(oName)

            crIdx=find(oName==newline);
            if~isempty(crIdx)
                if crIdx(1)==length(oName)
                    oName=oName(1:crIdx(1)-1);
                else
                    oName=[oName(1:crIdx(1)-1),'...'];
                end
            end

