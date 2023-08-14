classdef InterruptGroup<codertarget.Info





    properties(SetAccess='protected',GetAccess='public')
        Name char='';
        IrqInfo codertarget.interrupts.Interrupt=codertarget.interrupts.Interrupt.empty;
        IsrDefinitionSignature='void $(ISR_NAME) (void)';
    end
    properties
        BuildConfigurationInfo codertarget.attributes.BuildConfigurationInfo=codertarget.attributes.BuildConfigurationInfo.empty;
    end

    methods
        function obj=InterruptGroup(GroupName)
            obj.Name=GroupName;
        end

        function IntNames=getInterruptNames(obj)
            IntNames='';
            if~isempty(obj.IrqInfo)
                IntNames={obj.IrqInfo.Name};
            end
        end

        function IntNumber=getInterruptNumbers(obj)
            IntNumber=[];
            if~isempty(obj.IrqInfo)
                IntNumber=[obj.IrqInfo.Number];
            end
        end

        function Intr=getInterrupt(obj,InterruptName)
            Intr=codertarget.interrupts.Interrupt.empty;
            IntNames=getInterruptNames(obj);

            if~isempty(IntNames)&&~isempty(intersect(IntNames,InterruptName))
                Intr=obj.IrqInfo(ismember(IntNames,InterruptName));
            end
        end

        function IrqGroupStruct=getInterruptGroupStruct(obj)
            props=properties(obj);
            assert(~isempty(obj.IrqInfo),'Cannot generate interrupt structure with empty IrqInfo.');
            for i=1:numel(props)
                if isequal(props{i},'IrqInfo')
                    if~isempty(obj.IrqInfo)
                        if~isfield(IrqGroupStruct,props{i})
                            IrqGroupStruct.(props{i})=getInterruptStruct(obj.IrqInfo(1));
                        end

                        for j=2:numel(obj.(props{i}))
                            IrqGroupStruct.(props{i})(end+1)=getInterruptStruct(obj.IrqInfo(j));
                        end
                    else
                        IrqGroupStruct.(props{i})=[];
                    end
                else
                    IrqGroupStruct.(props{i})=get(obj,props{i});
                end
            end
        end

        function setIsrDefinitionSignature(obj,value)
            validateattributes(value,{'char','string'},{'nonempty'},'','ISR definition signature');

            obj.IsrDefinitionSignature=value;
        end

        function Intr=addNewInterrupt(obj,InterruptName,InterruptNumber)
            if ischar(InterruptNumber)||isstring(InterruptNumber)
                InterruptNumber=str2double(InterruptNumber);
            end
            IntrNames=getInterruptNames(obj);
            if~isempty(IntrNames)
                assert(isempty(intersect(IntrNames,InterruptName)),'%s interrupt already exists.',InterruptName);
            end
            IntrNnumbers=getInterruptNumbers(obj);
            if~isempty(IntrNnumbers)
                assert(isempty(intersect(IntrNnumbers,InterruptNumber)),'ISR with number %d already exists.',InterruptNumber);
            end
            obj.IrqInfo(end+1)=codertarget.interrupts.Interrupt(InterruptName,InterruptNumber);
            Intr=obj.IrqInfo(end);
        end

        function Intr=addNewInterruptStruct(obj,IrqInfoStruct)
            assert(isa(IrqInfoStruct,'struct'),'Input should be structure.');
            assert(isfield(IrqInfoStruct,'Name'),'Input structure should contain a name field.');
            assert(isfield(IrqInfoStruct,'Number'),'Input structure should contain a number field.');


            Intr=addNewInterrupt(obj,IrqInfoStruct.Name,IrqInfoStruct.Number);
            if isfield(IrqInfoStruct,'Maskable')
                setMaskable(Intr,IrqInfoStruct.Maskable);
            end
            if isfield(IrqInfoStruct,'Priority')
                setPriority(Intr,IrqInfoStruct.Priority);
            end

            if isfield(IrqInfoStruct,'EventsInfo')
                for i=1:numel(IrqInfoStruct.EventsInfo)
                    if~isempty(IrqInfoStruct.EventsInfo(i))
                        addNewEventStruct(Intr,IrqInfoStruct.EventsInfo(i));
                    end
                end
            end
        end

        function removeInterrupt(obj,InterruptName)
            Intr=getInterrupt(obj,InterruptName);
            if~isempty(Intr)
                obj.IrqInfo(ismember(getInterruptNames(obj),InterruptName))=[];
            end
        end
    end

    methods(Access='public')
        function addNewBuildConfigurationInfo(h,valueToSet)
            h.addNewElementToArrayProperty(h,'BuildConfigurationInfo',valueToSet);
        end
        function allBCs=getBuildConfigurationInfo(h,varargin)
            p=inputParser;
            p.addParameter('os','any');
            p.addParameter('toolchain','any');
            p.parse(varargin{:});
            res=p.Results;
            allBCs=[];
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                isSupportedOS=isequal(res.os,'any')||...
                isequal(bcObj.SupportedOperatingSystems,{'all'})||...
                ismember(res.os,bcObj.SupportedOperatingSystems);
                isSupportedToolchain=isequal(res.toolchain,'any')||...
                isequal(bcObj.SupportedToolchains,{'all'})||...
                ismember(res.toolchain,bcObj.SupportedToolchains);
                if isSupportedOS&&isSupportedToolchain
                    allBCs=[allBCs,bcObj];%#ok<AGROW>
                end
            end
        end
    end
end


