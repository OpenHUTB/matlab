classdef InheritRuleCustomizer<Simulink.Customizer







    properties(SetAccess=private)
        mCustomRules;
    end

    methods(Access=public)
        function registerCustomRules(obj,rules)
            try
                Simulink.InheritRuleCustomizer.verifyRules(rules);
            catch me
                throwAsCaller(me);
            end



            obj.mCustomRules=[obj.mCustomRules;...
            setdiff(setdiff(rules(:),obj.mBuiltinRules),...
            obj.mCustomRules)];
        end

        function rules=getCustomRules(obj)
            rules=obj.mCustomRules;
        end
    end

    methods(Access=public,Hidden)

        function clear(obj)
            obj.mCustomRules={};
        end
    end

    methods(Access=public,Static,Hidden)
        function customizer=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj);

                localStaticObj=Simulink.InheritRuleCustomizer();
            end
            customizer=localStaticObj;
        end
    end

    properties(Constant)
        mBuiltinRules={'Inherit: Inherit via internal rule';...
        'Inherit: Inherit via back propagation';...
        'Inherit: Same as input';...
        'Inherit: Same as first input';...
        'Inherit: Same as second input';...
        'Inherit: All ports same datatype';...
        'Inherit: Inherit from ''Breakpoint data''';...
        'Inherit: Inherit from ''Constant value''';...
        'Inherit: Inherit from ''Table data''';...
        'Inherit: Logical (see Configuration Parameters: Optimization)';...
        'Inherit: Same as accumulator';...
        'Inherit: Same as product output';...
        'Inherit: Same as output';...
        'Inherit: Same as Simulink';...
'Inherit: Same word length as input'
        };
    end

    methods(Access=private)
        function obj=InheritRuleCustomizer()
            mlock;
            obj.mCustomRules={};
        end


        function delete(object)%#ok
        end
    end

    methods(Access=private,Static)
        function verifyRules(rules)
            rules=rules(:);
            if~iscell(rules)
                throw(MException('Simulink:tools:RegRuleInvalidSignature',...
                DAStudio.message('Simulink:tools:RegRuleInvalidSignature',...
                'rules')));
            end
            me=[];
            for i=1:length(rules)
                rule=rules{i};
                if~isempty(regexp(rule,'[|{},]','once'))
                    if isempty(me)
                        me=MException('Simulink:tools:RegRuleInvalidRuleSet',...
                        DAStudio.message('Simulink:tools:RegRuleInvalidRuleSet'));
                    end
                    causeME=MException('Simulink:tools:RegRuleInvalidChar',...
                    DAStudio.message('Simulink:tools:RegRuleInvalidChar',...
                    rule));
                    me=addCause(me,causeME);
                end

                if~strncmp(rule,'Inherit: ',9);
                    if isempty(me)
                        me=MException('Simulink:tools:RegRuleInvalidRuleSet',...
                        DAStudio.message('Simulink:tools:RegRuleInvalidRuleSet'));
                    end
                    causeME=MException('Simulink:tools:RegRuleInvalidPrefix',...
                    DAStudio.message('Simulink:tools:RegRuleInvalidPrefix',...
                    rule));
                    me=addCause(me,causeME);
                end
            end
            if~isempty(me)
                throw(me);
            end
        end
    end
end

