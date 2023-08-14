classdef MenuOptionsExclusionEditor




    properties
allPropMap
CallbackAction
    end

    methods
        function this=MenuOptionsExclusionEditor()
            this.allPropMap=containers.Map('KeyType','char','ValueType','any');
            this.setPropDefaults();
        end

        function setPropDefaults(this)

            this.CallbackAction=struct('OpenExclusionEditor','OpenExclusionEditor',...
            'AddSubsystemToExclusions','AddSubsystemToExclusions');

            propMap=[];
            propMap=this.addToPropMap(propMap,'CD6',DAStudio.message('sl_pir_cpp:creator:subSystemAndContents'),...
            DAStudio.message('ModelAdvisor:engine:ExclusionRationaleSubsystem'),'Subsystem',true);
            propMap=this.addToPropMap(propMap,'CD9',DAStudio.message('sl_pir_cpp:creator:modelreference'),...
            DAStudio.message('ModelAdvisor:engine:ExclusionRationaleBlock'),'Block',false);

            for idx=1:numel(propMap)
                id=propMap(idx).id;
                if(this.allPropMap.isKey(id))
                    continue;
                end
                this.allPropMap(id)=propMap(idx);
            end
        end

        function propMap=addToPropMap(~,propMap,id,propDesc,name,Type,includeChildren)
            tempPropMap.propDesc=propDesc;
            tempPropMap.Type=Type;
            tempPropMap.id=id;
            tempPropMap.rationale=name;
            tempPropMap.includeChildren=includeChildren;
            tempPropMap.sid='off';
            tempPropMap.checkType='CloneDetection';
            if isempty(propMap)
                propMap=tempPropMap;
            else
                propMap(end+1)=tempPropMap;
            end
        end

        function propMap=getProperties(this,ssid,sel)
            try
                propMap=[];

                modelObject=get_param(sel.handle,'object');

                if~contains(class(modelObject),'Stateflow.')
                    ssid=strrep(getfullname(sel.handle),newline,' ');
                end

                if ishandle(modelObject)&&strcmpi(modelObject.Type,'block')
                    if strcmpi(modelObject.BlockType,'subsystem')
                        propMap=this.createPropMap(propMap,'CD6',ssid,modelObject.Name);
                    else
                        propMap=this.createPropMap(propMap,'CD9',ssid,modelObject.Name);
                    end
                end
            catch MEx
                rethrow(MEx);
            end
        end

        function propMap=createPropMap(this,propMap,id,value,Name)
            newProp=this.getPropSchema(id);
            assert(~isempty(newProp));
            newProp.value=value;
            newProp.name=Name;
            newProp.rationale=sprintf(newProp.rationale,newProp.name);
            if isempty(propMap)
                propMap=newProp;
            else
                propMap(end+1)=newProp;
            end
        end

        function result=getAllPropMap(this)
            result=this.allPropMap;
        end

        function prop=getPropSchema(this,id)
            prop='';
            if this.allPropMap.isKey(id)
                prop=this.allPropMap(id);
            end
        end
    end
end


