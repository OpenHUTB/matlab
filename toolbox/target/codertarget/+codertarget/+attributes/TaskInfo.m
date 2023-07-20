classdef TaskInfo<matlab.mixin.SetGet



    properties
        InBackground=true
        InForeground=false
        Default='background'
        Visible=false
    end
    methods(Access={?codertarget.attributes.ExternalModeInfo,?codertarget.attributes.TaskInfo})
        function h=TaskInfo(inVal)
            if nargin>0
                if isstruct(inVal)
                    if isfield(inVal,'inbackground')
                        h.InBackground=inVal.inbackground;
                    end
                    if isfield(inVal,'inforeground')
                        h.InForeground=inVal.inforeground;
                    end
                    if isfield(inVal,'visible')
                        h.Visible=inVal.visible;
                    end
                    if isfield(inVal,'default')
                        h.Default=inVal.default;
                    end
                else
                    inVal=h.input2bool(inVal);
                    h.InBackground=inVal;
                    h.InForeground=~inVal;
                    h.Visible=false;
                    if inVal
                        h.Default='background';
                    else
                        h.Default='foreground';
                    end
                end
            else
                h.InBackground=false;
                h.InForeground=true;
                h.Default='foreground';
                h.Visible=false;
            end
        end
    end
    methods(Access='private')
        function val=input2bool(~,val)
            if~ischar(val)&&~islogical(val)
                DAStudio.error('codertarget:targetapi:InvalidLogicalProperty','InBackground');
            end
            if isempty(val)
                val=false;
            elseif ischar(val)
                val=~isequal(val,'false')&&~isequal(val,'0');
            end
        end
    end

    methods
        function obj=set.InBackground(obj,val)
            obj.InBackground=obj.input2bool(val);
            if~obj.InBackground
                obj.InForeground=true;%#ok<MCSUP>
            end
        end
        function obj=set.InForeground(obj,val)
            obj.InForeground=obj.input2bool(val);
            if~obj.InForeground
                obj.InBackground=true;%#ok<MCSUP>
            end
        end
        function obj=set.Default(obj,val)
            if ischar(val)
                lower(val);
                if~ismember(lower(val),{'foreground','background'})
                    DAStudio.error('codertarget:targetapi:IllegalStringProperty','Default','''foregound'', ''background''');
                end
            else
                DAStudio.error('codertarget:targetapi:IllegalStringProperty','Default','''foregound'', ''background''');
            end
            if obj.InForeground&&obj.InBackground %#ok<MCSUP>
                obj.Default=lower(val);
            elseif obj.InForeground %#ok<MCSUP>
                obj.Default='foreground';
            elseif obj.InBackground %#ok<MCSUP>
                obj.Default='background';
            else
                assert(false);
            end
        end
        function obj=set.Visible(obj,val)
            val=obj.input2bool(val);
            if val&&obj.InForeground&&obj.InBackground %#ok<MCSUP>
                obj.Visible=val;
            else
                obj.Visible=false;
            end
        end
    end
end