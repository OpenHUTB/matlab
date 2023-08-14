classdef(Sealed)Options<handle
    properties
        PrettyPrint=false;
    end

    methods(Access=private)
        function this=Options()

        end
    end

    methods
        function set.PrettyPrint(this,value)
            if~islogical(value)
                DAStudio.error('Advisor:engine:UnsupportedPropertyValueDT','PrettyPrint');
            else
                this.PrettyPrint=value;
            end
        end
    end

    methods(Static)
        function this=getInstance()

            persistent AdvisorOptions;
            if isempty(AdvisorOptions)||~isvalid(AdvisorOptions)
                AdvisorOptions=Advisor.Options();
            end

            this=AdvisorOptions;
        end

        function value=getOption(optionName)
            opt=Advisor.Options.getInstance();

            if isprop(opt,optionName)
                value=opt.(optionName);
            else
                DAStudio.error('Advisor:engine:UnknownProperty',optionName);
            end
        end
    end
end