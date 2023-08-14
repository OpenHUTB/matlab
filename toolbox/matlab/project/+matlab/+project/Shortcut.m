classdef Shortcut<matlab.internal.project.util.EntryPoint














    properties(Dependent)

        Name;

        Group;
    end


    methods(Access=public,Hidden=true)
        function obj=Shortcut(javaEntryPointManager,file)
            obj=obj@matlab.internal.project.util.EntryPoint(javaEntryPointManager,file);
            obj.FileReturnTransform=@(x)string(x);
        end

        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            [~,index]=sort([objArray.File]);
            sortedArray=objArray(index);
        end
    end

    methods
        function name=get.Name(obj)
            getName=@(x)x.getName();
            name=string(obj.getEntryPointProperty(getName));
        end

        function group=get.Group(obj)
            getGroup=@(x)x.getGroup();
            group=string(shortcutGroup(obj.getEntryPointProperty(getGroup)));
        end

        function set.Name(obj,name)
            validateattributes(name,{'char','string'},{'scalartext','nonempty'},'','name');

            if isstring(name)
                name=char(name);
            end

            setName=@(x)x.setName(char(obj.File),name);
            obj.setEntryPointManagerProperty(setName);
        end

        function set.Group(obj,group)
            validateattributes(group,{'char','string'},{'scalartext','nonempty'},'','group');

            if isstring(group)
                group=char(group);
            end

            setGroup=@(x)x.setGroup(char(obj.File),group);
            obj.setEntryPointManagerProperty(setGroup);
        end

    end

end

function group=shortcutGroup(entryPointGroup)
    if isempty(entryPointGroup)
        import com.mathworks.toolbox.slproject.resources.SlProjectResources;
        group=char(SlProjectResources.getString('Tab.SimulinkProjectShortcuts.NoGroupName'));
    else
        group=char(entryPointGroup.getName());
    end
end

