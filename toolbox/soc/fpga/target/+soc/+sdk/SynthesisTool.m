classdef(Sealed=true)SynthesisTool<matlab.mixin.SetGet




    properties(Access='public')
        Name='';
    end
    methods
        function set.Name(h,name)
            name=convertStringsToChars(name);
            if~soc.sdk.internal.isValidName(name)
                error(message('socsdk:utils:NameInvalid','SynthesisTool'));
            end
            name=convertStringsToChars(name);
            h.Name=name;
        end
    end
    methods(Access='public')
        function h=SynthesisTool(name)
            name=convertStringsToChars(name);
            h.Name=name;
        end
    end
end
