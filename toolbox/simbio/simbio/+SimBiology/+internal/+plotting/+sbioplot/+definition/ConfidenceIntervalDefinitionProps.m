classdef ConfidenceIntervalDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    properties(Access=public)
        SupportsProfileLikelihood=false;
        ProfileLikelihood='bar';
        Layout='split';
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.SupportsProfileLikelihood=obj.SupportsProfileLikelihood;
            info.ProfileLikelihood=obj.ProfileLikelihood;
            info.Layout=obj.Layout;
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'SupportsProfileLikelihood',input.SupportsProfileLikelihood,...
            'ProfileLikelihood',input.ProfileLikelihood,...
            'Layout',input.Layout);
        end
    end

end