classdef CommonSets

    properties(Constant=true)
        ImageType=matlab.system.StringSet({...
        'Intensity',...
        'Binary'});
    end

    methods(Static=true)
        function en=getSet(name)
            persistent instance;
            if isempty(instance)
                instance=vision.CommonSets;
            end

            switch name
            case 'ImageType'
                en=instance.ImageType;
            otherwise
                coder.internal.assert(false,'vision:internal:unhandledCase');
            end
        end

    end
end
