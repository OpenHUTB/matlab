function setPropDefaults(this)


    propMap=[];
    propMap=addToPropMap(propMap,'CD6',DAStudio.message('sl_pir_cpp:creator:subSystemAndContents'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleSubsystem'),'Subsystem',true,{'All Checks'});
    propMap=addToPropMap(propMap,'CD9',DAStudio.message('sl_pir_cpp:creator:modelreference'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleBlock'),'Block',false,{'All Checks'});

    for idx=1:numel(propMap)
        id=propMap(idx).id;
        assert(~this.allPropMap.isKey(id));
        this.allPropMap(id)=propMap(idx);
    end



    function propMap=addToPropMap(propMap,id,propDesc,name,Type,includeChildren,checkids)
        s.propDesc=propDesc;
        s.Type=Type;
        s.id=id;
        s.rationale=name;
        s.includeChildren=includeChildren;
        s.checkIDs=checkids;
        s.sid='off';
        s.checkType='CloneDetection';
        if isempty(propMap)
            propMap=s;
        else
            propMap(end+1)=s;
        end
