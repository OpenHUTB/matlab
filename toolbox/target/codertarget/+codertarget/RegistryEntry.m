classdef(Sealed=true,Hidden)RegistryEntry<matlab.mixin.SetGet

    properties(SetAccess='private')
DefFiles
Type
    end
    properties(Dependent)
Values
    end
    properties(Hidden,SetAccess='private',GetAccess='private')
ActualValues
    end
    properties(Hidden,Constant)
        SupportedTypes={'codertarget.attributes.AttributeInfo',...
        'codertarget.rtos.RTOSInfo',...
        'codertarget.parameter.ParameterInfo',...
        'codertarget.scheduler.SchedulerInfo',...
        'codertarget.targethardware.TargetHardwareInfo',...
        'matlabshared.targetsdk.Target'}

    end

    methods(Access={?codertarget.Registry})
        function h=RegistryEntry(type)
            mlock;
            h.Type=type;
        end
    end

    methods
        function clean(h)
            h.ActualValues=[];
            h.DefFiles=[];
        end
        function out=isempty(h)
            out=isempty(h.Values);
        end
        function out=ismember(h,ldefFile)
            out=ismember(ldefFile,h.DefFiles);
        end
        function out=get(h,ldefFile)
            if isempty(h.Values)
                out=[];
            else
                if isnumeric(ldefFile)
                    assert(~isempty(ldefFile));
                    out=h.Values(ldefFile);
                elseif ischar(ldefFile)
                    idx=ismember(h.DefFiles,ldefFile);
                    out=h.Values(idx);
                else
                    assert(false);
                end
            end
        end
        function set(h,lDefFile,value)
            validateattributes(lDefFile,{'char','cell'},{'nonempty'});
            validateattributes(value,{h.Type},{'nonempty'});
            if iscell(lDefFile)
                assert(numel(lDefFile)==numel(value));
            end
            if~isempty(h.Values)
                if iscell(lDefFile)
                    for ii=1:numel(lDefFile)
                        h.set(lDefFile{ii},value(ii));
                    end
                elseif ischar(lDefFile)
                    if ismember(lDefFile,h.DefFiles);
                        idx=ismember(h.DefFiles,lDefFile);
                        h.Values(idx)=value;
                    else
                        h.DefFiles{end+1}=lDefFile;
                        h.Values(end+1)=value;
                    end
                else
                    assert(false);
                end
            else
                h.DefFiles={lDefFile};
                h.Values=value;
            end
        end
        function set.Type(h,val)
            if ismember(val,h.SupportedTypes)
                h.Type=val;
            else
                assert(false);
            end
        end
        function out=get.Values(h)
            out=h.ActualValues;
        end
        function set.Values(h,val)
            if isa(val,h.Type)
                h.ActualValues=val;
            end
        end
        function set.DefFiles(h,val)
            if iscell(val)
                h.DefFiles=val;
            end
        end
    end
end