classdef Transformation

























    properties(SetAccess=private)
StartVersion
EndVersion
TargetVersion
TargetClass
Class
Mappings
CustomTransform
    end

    methods
        function obj=Transformation(class,targetClass,mappings,customTransform,startVer,endVer,targetVer)
            obj.StartVersion=startVer;
            obj.EndVersion=endVer;
            obj.TargetVersion=targetVer;
            obj.Class=class;
            obj.TargetClass=targetClass;
            obj.Mappings=obj.createMappingSubstitutions(mappings);
            obj.CustomTransform=customTransform;
        end

        function newSettings=apply(transform,settings)

            newSettings=settings;
            for idx=1:numel(transform.Mappings)
                targetID=transform.Mappings(idx).id;
                subs=transform.Mappings(idx).substitution;
                if~isempty(subs)
                    type=transform.Mappings(idx).type;
                    newSettings=lApplySubstitution(newSettings,subs,targetID,type);
                else
                    value=transform.Mappings(idx).value;
                    if~isempty(value)
                        newSettings=setValue(newSettings,targetID,value);
                    end
                end


                unit=transform.Mappings(idx).unit;
                if~isempty(unit)
                    newSettings=setUnit(newSettings,targetID,unit);
                end



                priority=transform.Mappings(idx).priority;
                if~isempty(priority)
                    newSettings=setPriority(newSettings,targetID,priority);
                    newSettings=setSpecify(newSettings,targetID,'on');
                end

            end

            newSettings=setClass(newSettings,transform.TargetClass);

            newSettings=setVersion(newSettings,transform.TargetVersion);

            newSettings=applyCustomTransform(newSettings,transform.CustomTransform);
        end

        function mappings=createMappingSubstitutions(obj,mappings)
            for idx=1:numel(mappings)
                if~isempty(mappings(idx).substitution)
                    mappings(idx).substitution=...
                    simscape.internal.componentforwarding.Substitution(...
                    mappings(idx).substitution);
                end
            end
        end
    end

end

function newSettings=lApplySubstitution(newSettings,subs,targetID,type)

    subsID=subs.ID;
    subsString=getValue(newSettings,subsID);
    if~isempty(subsString)
        newSettings=setValue(newSettings,targetID,subs.getValueString(subsString));
    end


    theUnit=getUnit(newSettings,subsID);
    if~isempty(theUnit)
        newSettings=setUnit(newSettings,targetID,theUnit);
    end


    if strcmp(type,'variable')
        thePriority=getPriority(newSettings,subsID);
        if~isempty(thePriority)
            newSettings=setPriority(newSettings,targetID,thePriority);
        end
        theSpecify=getSpecify(newSettings,subsID);
        if~isempty(theSpecify)
            newSettings=setSpecify(newSettings,targetID,theSpecify);
        end
    end


    theRTConfig=getRTConfig(newSettings,subsID);
    if~isempty(theRTConfig)&&strcmp(type,'parameter')
        newSettings=setRTConfig(newSettings,targetID,theRTConfig);
    end
end
