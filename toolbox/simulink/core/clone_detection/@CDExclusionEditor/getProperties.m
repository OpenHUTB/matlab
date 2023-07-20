function propMap=getProperties(this,ssid,sel)



    try
        propMap=[];

        modelObject=get_param(sel.handle,'object');

        if~contains(class(modelObject),'Stateflow.')
            ssid=strrep(getfullname(sel.handle),newline,' ');
        end

        if ishandle(modelObject)&&strcmpi(modelObject.Type,'block')
            if strcmpi(modelObject.BlockType,'subsystem')
                propMap=addToPropMap(this,propMap,'CD6',ssid,modelObject.Name);
            else
                propMap=addToPropMap(this,propMap,'CD9',ssid,modelObject.Name);
            end
        end
    catch MEx
        rethrow(MEx);
    end



    function propMap=addToPropMap(this,propMap,id,value,Name)
        newProp=this.getPropSchema(id);
        assert(~isempty(newProp));
        newProp.value=value;
        newProp.name=Name;
        newProp.rationale=this.getRationale(newProp);
        if isempty(propMap)
            propMap=newProp;
        else
            propMap(end+1)=newProp;
        end


