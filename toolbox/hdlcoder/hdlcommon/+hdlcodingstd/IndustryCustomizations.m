

classdef IndustryCustomizations<hdlcodingstd.BaseCustomizations
    properties

        MultiplierBitWidth=struct('enable',true,'width',16,'rule','2.10.6.5');



        ModuleInstanceEntityNameLength=struct('enable',true,'length',[2,32],'rule','1.1.2.1');




        SignalPortParamNameLength=struct('enable',true,'length',[2,40],'rule','1.1.3.3');


        DetectDuplicateNamesCheck=struct('enable',true,'rule','1.1.1.5');


        LineLength=struct('enable',true,'length',110,'rule','3.1.4.5');


        MinimizeClockEnableCheck=struct('enable',false,'rule','2.3.3.4');


        RemoveResetCheck=struct('enable',false,'rule','2.3.3.5');


        AsynchronousResetCheck=struct('enable',true,'rule','2.3.3.6');


        InitialStatements=struct('enable',true,'rule','2.3.4.1');


        ConditionalRegionCheck=struct('enable',true,'length',1,'rule','2.6.2.1');



        CascadedConditionalAssignmentCheck=struct('enable',false,'rule','2.6.2.1a');



        IfElseChain=struct('enable',true,'length',7,'rule','2.7.3.1c');



        NonIntegerTypes=struct('enable',true,'rule','3.2.4.1');


        IfElseNesting=struct('enable',true,'depth',3,'rule','2.7.3.1a');


        HDLKeywords=struct('enable',true,'rule','1.1.1.3');



        MinimizeVariableUsage=struct('enable',false,'rule','2.7.x,x');



RulesBasicCodingPractices


RulesRTLDescriptionTechniques


RulesDesignMethodologyGuidelines


        ShowPassingRules=struct('enable',true);
    end

    properties(Constant,Access=private)
        bool2string={'Ignore','Check '};
        boolean2string={'false','true'};
    end

    methods(Static)
        function cso=loadobj(obj)
            cso=hdlcodingstd.IndustryCustomizations();
            props=fields(obj);
            for itr=1:length(props)
                sub_props=fields(obj.(props{itr}));
                for itr_sub=1:length(sub_props)
                    cso.(props{itr}).(sub_props{itr_sub})=obj.(props{itr}).(sub_props{itr_sub});
                end
            end
        end
    end

    methods(Access=private)
        function checkForAllowedFields(this,property,value)
            if~isequal(fields(this.(property)),fields(value))
                error(message('hdlcommon:IndustryStandard:UnknownFieldForCSO',property));
            end

            if isfield(value,'rule')&&~ischar(value.rule)
                error(message('hdlcommon:IndustryStandard:InvalidFieldForCSO',property,'rule'))
            end

            if~any([islogical(value.enable),isnumeric(value.enable)])
                error(message('hdlcommon:IndustryStandard:InvalidFieldForCSO',property,'enable'))
            end


            rest_of_fields=setdiff(fields(value),{'enable','rule'});
            for itr=1:length(rest_of_fields)
                field_name=rest_of_fields{itr};
                field_val=value.(field_name);
                if any([~isnumeric(field_val),~isreal(field_val),isnan(field_val),isinf(field_val),any(field_val<0)])
                    error(message('hdlcommon:IndustryStandard:InvalidFieldForCSO',property,field_name))
                end
            end
        end
    end


    methods
        function this=set.MultiplierBitWidth(this,value)
            assert(isfield(value,'enable'),'required field ''enable'' not found');
            assert(islogical(value.enable),'''enable'' field needs to be logical value; use true or false');
            this.checkForAllowedFields('MultiplierBitWidth',value);
            this.MultiplierBitWidth=value;
        end

        function this=set.ModuleInstanceEntityNameLength(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('ModuleInstanceEntityNameLength',value);
            if(numel(value.length)~=2||(value.length(1)>=value.length(2)))
                property='ModuleInstanceEntityNameLength';field_name='length';
                error(message('hdlcommon:IndustryStandard:InvalidFieldForCSO',property,field_name));
            end
            this.ModuleInstanceEntityNameLength=value;
        end

        function this=set.SignalPortParamNameLength(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('SignalPortParamNameLength',value);
            if(numel(value.length)~=2||(value.length(1)>=value.length(2)))
                property='SignalPortParamNameLength';field_name='length';
                error(message('hdlcommon:IndustryStandard:InvalidFieldForCSO',property,field_name));
            end
            this.SignalPortParamNameLength=value;
        end

        function this=set.LineLength(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('LineLength',value);
            this.LineLength=value;
        end

        function this=set.InitialStatements(this,value)
            assert(isfield(value,'enable'));

            this.checkForAllowedFields('InitialStatements',value);
            this.InitialStatements=value;
        end

        function this=set.ConditionalRegionCheck(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('ConditionalRegionCheck',value);
            this.ConditionalRegionCheck=value;
        end

        function this=set.CascadedConditionalAssignmentCheck(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('CascadedConditionalAssignmentCheck',value);
            this.CascadedConditionalAssignmentCheck=value;
        end

        function this=set.IfElseChain(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('IfElseChain',value);
            this.IfElseChain=value;
        end

        function this=set.NonIntegerTypes(this,value)
            assert(isfield(value,'enable'));

            this.checkForAllowedFields('NonIntegerTypes',value);
            this.NonIntegerTypes=value;
        end

        function this=set.IfElseNesting(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('IfElseNesting',value);
            this.IfElseNesting=value;
        end


        function this=set.MinimizeVariableUsage(this,value)
            assert(isfield(value,'enable'));

            this.checkForAllowedFields('MinimizeVariableUsage',value);
            this.MinimizeVariableUsage=value;
        end

        function this=set.HDLKeywords(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('HDLKeywords',value);
            this.HDLKeywords=value;
        end

        function this=set.ShowPassingRules(this,value)
            assert(isfield(value,'enable'));
            this.checkForAllowedFields('ShowPassingRules',value);
            this.ShowPassingRules=value;
        end
    end

    methods
        function saveObj=saveobj(this)
            saveObj=struct();
            props=properties(this);
            for itr=1:length(props)
                sub_props=fields(this.(props{itr}));
                for itr_sub=1:length(sub_props)
                    saveObj.(props{itr}).(sub_props{itr_sub})=this.(props{itr}).(sub_props{itr_sub});
                end
            end
        end


        function code=serialize(this)
            refobj=hdlcodingstd.IndustryCustomizations();
            code='hdlcodingstd.IndustryCustomizations(';
            props=properties(this);

            for itr=1:length(props)
                currprop=this.(props{itr});
                refobj_prop=refobj.(props{itr});

                if(~isequal(refobj_prop,currprop))
                    code=[code,'''',props{itr},''',',coder.internal.tools.TML.tostr(this.(props{itr})),','];%#ok<AGROW>
                end
            end
            if code(end)==','
                code(end)=')';
            else
                code=[code,')'];
            end
        end

        function strOut=forwardPropertyName(this,strIn)%#ok<INUSL>
            strOut=strIn;
        end

        function this=IndustryCustomizations(varargin)
            this=this@hdlcodingstd.BaseCustomizations(varargin{:});
            this.setupRulesAndDefaults();


            mlock;

            for itr=1:2:length(varargin)
                this.(varargin{itr})=varargin{itr+1};
            end
        end




        function flag=isRuleReported(this,ruleID)


            if(length(ruleID)<1||length(ruleID)>7)
                error('unknown option/rule-ID')
            end

            switch(ruleID(1))
            case '1'
                flag=this.RulesBasicCodingPractices.enable;
                ruleStruct=this.RulesBasicCodingPractices;
            case '2'
                flag=this.RulesRTLDescriptionTechniques.enable;
                ruleStruct=this.RulesRTLDescriptionTechniques;
            case '3'
                flag=this.RulesDesignMethodologyGuidelines.enable;
                ruleStruct=this.RulesDesignMethodologyGuidelines;
            otherwise
                error(['unknown rule ID - ',ruleID]);
            end

            if(length(ruleID)<3)
                return
            end

            if(~flag)
                return
            end

            names=setdiff(fieldnames(ruleStruct),'enable');
            for itr=1:length(names)
                if strncmpi(ruleID,ruleStruct.(names{itr}).prefix,length(ruleStruct.(names{itr}).prefix))
                    flag=ruleStruct.(names{itr}).enable;
                    return
                end
            end
            error(['unknown rule ID - ',ruleID]);
        end

        function str=toString(this)
            names=fieldnames(this);


            names=setdiff(names,{'RulesBasicCodingPractices','RulesRTLDescriptionTechniques','RulesDesignMethodologyGuidelines','ShowPassingRules'});

            str=sprintf('IndustryCustomizations Structure\n\n');
            for itr=1:length(names)

                if(any(regexp(names{itr},'_')))
                    continue;
                end
                status=this.bool2string{this.(names{itr}).enable+1};
                str=[str,sprintf('\n %s \n\t %s rule %s \n',...
                this.forwardPropertyName(names{itr}),...
                status,...
                hdlcodingstd.Report.mungeRule('CGSL-',this.(names{itr}).rule))];%#ok<AGROW>
                extra_fields=setdiff(fieldnames(this.(names{itr})),{'rule','enable'});
                for itr2=1:length(extra_fields)
                    extra_field_value=this.(names{itr}).(extra_fields{itr2});
                    if(isstruct(extra_field_value))
                        status=this.bool2string{extra_field_value.enable+1};
                        str=[str,sprintf('\t %s |  %s \n',status,extra_fields{itr2})];%#ok<AGROW>
                    else
                        str=[str,sprintf('\t %s = %s \n',extra_fields{itr2},coder.internal.tools.TML.tostr(extra_field_value))];%#ok<AGROW>
                    end
                end
            end

            status=this.bool2string{this.ShowPassingRules.enable+1};
            str=[str,sprintf('\n %s \n\t %s \n','ShowPassingRules',status)];
            return
        end

        function disp(this)





            ordered_field_names={'ShowPassingRules',...
            'HDLKeywords','DetectDuplicateNamesCheck','ModuleInstanceEntityNameLength','SignalPortParamNameLength',...
            'MinimizeClockEnableCheck','RemoveResetCheck','AsynchronousResetCheck','InitialStatements',...
            'ConditionalRegionCheck','CascadedConditionalAssignmentCheck','IfElseChain','IfElseNesting',...
            'MinimizeVariableUsage','MultiplierBitWidth',...
            'LineLength','NonIntegerTypes'};


            for itr=1:length(ordered_field_names)
                prop_name=ordered_field_names{itr};
                extra_values=this.(prop_name);
                extra_fields=fieldnames(extra_values);
                if(isfield(this.(prop_name),'rule'))
                    rule_name=['[',hdlcodingstd.Report.mungeRule('CGSL-',this.(prop_name).rule),']'];
                else
                    rule_name='';
                end
                for itr2=1:length(extra_fields)
                    extra_field_prop=extra_fields{itr2};
                    extra_field_value=extra_values.(extra_field_prop);
                    switch(extra_fields{itr2})
                    case 'rule'
                        continue
                    case 'enable'
                        fprintf('%50s: %-6s\t %s\n',sprintf('%s.%s',prop_name,extra_field_prop),this.boolean2string{extra_field_value+1},rule_name);
                    otherwise
                        fprintf('%50s: %-6s\t %s\n',sprintf('%s.%s',prop_name,extra_field_prop),coder.internal.tools.TML.tostr(extra_field_value),rule_name);
                    end
                end
            end

        end
    end

    methods(Access=private)

        function setupRulesAndDefaults(this)

            this.buildFieldsBasicCodingPractices();


            this.buildFieldsRTLDescriptionTechniques();


            this.buildFieldsDesignMethodologyGuidelines();


            this.ShowPassingRules=struct('enable',true);%#ok<MCHV3>
        end

        function buildFieldsBasicCodingPractices(this)
            fields={'NamingConventions',...
            'ClocksAndResets',...
            'InitialReset',...
            'Clocks',...
            'HierarchicalDesign'};
            for itr=1:length(fields)
                this.RulesBasicCodingPractices.(fields{itr})=struct('enable',true,'prefix',['1.',num2str(itr)]);
            end


            this.RulesBasicCodingPractices.HierarchicalDesign.prefix='1.6';

            this.RulesBasicCodingPractices.enable=true;
        end


        function buildFieldsRTLDescriptionTechniques(this)
            fields={'CombinationalLogic',...
            'AlwaysConstructsCombinationalLogic',...
            'FlipFlopInference',...
            'LatchDescription',...
            'TristateBuffer',...
            'AlwaysProcessWithCircuitStructure',...
            'IFStatement',...
            'CASEStatement',...
            'FORStatement',...
            'OperatorDescription',...
            'FiniteStateMachineDescription',...
            'MinimizeVariableUsage',...
            };
            for itr=1:length(fields)
                this.RulesRTLDescriptionTechniques.(fields{itr})=struct('enable',true,'prefix',['2.',num2str(itr)]);
            end
            this.RulesRTLDescriptionTechniques.enable=true;
            this.RulesRTLDescriptionTechniques.MinimizeVariableUsage.enable=false;
        end


        function buildFieldsDesignMethodologyGuidelines(this)
            fields={'CreatingFunctionLibraries',...
            'UsingFunctionLibraries',...
            'TestFacilitationDesign',...
            'SourceCodeDesignDataManagement',...
            };
            for itr=1:length(fields)
                this.RulesDesignMethodologyGuidelines.(fields{itr})=struct('enable',true,'prefix',['3.',num2str(itr)]);
            end


            this.RulesDesignMethodologyGuidelines.SourceCodeDesignDataManagement.prefix='3.5';

            this.RulesDesignMethodologyGuidelines.enable=true;
        end

    end
end


