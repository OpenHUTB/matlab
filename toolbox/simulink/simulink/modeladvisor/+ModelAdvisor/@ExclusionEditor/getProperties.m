function propMap=getProperties(this,ssid,sel)




    try
        propMap=[];

        modelObject=get_param(sel.handle,'object');

        if isempty(strfind(class(modelObject),'Stateflow.'))
            ssid=strrep(getfullname(sel.handle),sprintf('\n'),' ');
        end

        noMask=false;
        if strfind(class(modelObject),'Stateflow.')
            if isa(modelObject,'Stateflow.Chart')
                Name=modelObject.Name;
                propMap=addToPropMap(this,propMap,'P1',ssid,Name);
            elseif isa(modelObject,'Stateflow.State')
                Name=modelObject.getFullName;

            elseif isa(modelObject,'Stateflow.Transition')
                text=[modelObject.getDisplayLabel,' at ',modelObject.getFullName];
                value.condition=1;
                value.type='transitionEvent';


            elseif isa(modelObject,'Stateflow.AtomicSubchart')
                Name=modelObject.Name;
                cssid=Simulink.ID.getSID(modelObject);
                propMap=addToPropMap(this,propMap,'P1',cssid,Name);
                subchartMan=Stateflow.SLINSF.SubchartMan(modelObject.Id);
                linkStatStr=get_param(subchartMan.subchartH,'StaticLinkStatus');
                if~isempty(linkStatStr)&&strcmpi(linkStatStr,'resolved')
                    libName=modelObject.subChart.Path;
                    propMap=addToPropMap(this,propMap,'P7',libName,libName);
                end
            end
        elseif ishandle(modelObject)&&strcmpi(modelObject.Type,'block')
            if strcmpi(modelObject.BlockType,'subsystem')
                chartId=isChart(modelObject.Handle);
                if chartId~=0
                    if Stateflow.SLUtils.isStateflowBlock(modelObject.Handle)


                        sfBType=get_param(modelObject.Handle,'SFBlockType');
                        switch(sfBType)
                        case{'Chart','State Transition Table'}
                            propMap=addToPropMap(this,propMap,'P1',ssid,modelObject.Name);
                            propMap=addToPropMap(this,propMap,'P8',sfBType,sfBType);
                            propMap=addToPropMap(this,propMap,'P9',ssid,modelObject.Name);
                        otherwise

                            propMap=addToPropMap(this,propMap,'P8',sfBType,sfBType);
                            propMap=addToPropMap(this,propMap,'P9',ssid,modelObject.Name);
                        end
                    end
                    if~isempty(modelObject.ReferenceBlock)
                        propMap=addToPropMap(this,propMap,'P7',modelObject.ReferenceBlock,modelObject.ReferenceBlock);
                    end
                    noMask=true;
                else
                    propMap=addToPropMap(this,propMap,'P9',ssid,modelObject.Name);
                    propMap=addToPropMap(this,propMap,'P6',ssid,modelObject.Name);
                    if~isempty(modelObject.ReferenceBlock)
                        propMap=addToPropMap(this,propMap,'P7',modelObject.ReferenceBlock,modelObject.Name);
                    end
                end
            else
                propMap=addToPropMap(this,propMap,'P8',modelObject.BlockType,modelObject.BlockType);
                propMap=addToPropMap(this,propMap,'P9',ssid,modelObject.Name);
                if~isempty(modelObject.ReferenceBlock)
                    propMap=addToPropMap(this,propMap,'P7',modelObject.ReferenceBlock,modelObject.ReferenceBlock);
                end
            end

            if~isempty(modelObject.MaskType)&&~noMask;
                propMap=addToPropMap(this,propMap,'P10',modelObject.MaskType,modelObject.MaskType);
            end

        end
    catch MEx
        rethrow(MEx);
    end


    function chartId=isChart(blockH)
        chartId=0;
        try
            chartId=Stateflow.SLUtils.isStateflowBlock(blockH);
            if chartId~=0
                chartId=sfprivate('block2chart',blockH);
            end
        catch
            chartId=0;
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


