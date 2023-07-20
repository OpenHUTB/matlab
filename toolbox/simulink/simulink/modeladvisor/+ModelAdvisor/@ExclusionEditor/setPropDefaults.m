function setPropDefaults(this)




    propMap=[];
    propMap=addToPropMap(propMap,'P1',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusChartWithAllDescendants'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleChart'),'Subsystem',true,{'All Checks'});


    propMap=addToPropMap(propMap,'P3',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusState'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleState'),'Stateflow',false,{'All Checks'});
    propMap=addToPropMap(propMap,'P4',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusTransition'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleTransition'),'Stateflow',false,{'All Checks'});
    propMap=addToPropMap(propMap,'P5',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusTemporalEvent'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleEvent'),'Stateflow',false,{'All Checks'});
    propMap=addToPropMap(propMap,'P6',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusSubsystem'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleSubsystem'),'Subsystem',true,{'All Checks'});
    propMap=addToPropMap(propMap,'P7',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusLibraryBlock'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleLibrary'),'Library',true,{'All Checks'});
    propMap=addToPropMap(propMap,'P8',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusBlockType'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleBlockType'),'BlockType',false,{'All Checks'});
    propMap=addToPropMap(propMap,'P9',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusBlock'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleBlock'),'Block',false,{'All Checks'});
    propMap=addToPropMap(propMap,'P10',DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusMaskType'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationaleMaskType'),'MaskType',true,{'All Checks'});

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
        s.checkType='ModelAdvisor';
        if isempty(propMap)
            propMap=s;
        else
            propMap(end+1)=s;
        end
