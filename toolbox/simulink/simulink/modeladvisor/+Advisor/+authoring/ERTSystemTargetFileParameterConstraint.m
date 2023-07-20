classdef ERTSystemTargetFileParameterConstraint<Advisor.authoring.ModelParameterConstraint





    properties(Constant)
        SupportedParameterValues={DAStudio.message('Advisor:engine:CCERTBasedTarget')};
    end

    methods
        function this=ERTSystemTargetFileParameterConstraint(varargin)

            this.setParameterName('SystemTargetFile');

            if nargin==2&&(isa(varargin{1},'matlab.io.xml.dom.Element'))
                this.scanDOMNode(varargin{1});
                this.setID(varargin{2});

            else
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','ERTSystemTargetFileParameterConstraint');
            end
        end

        function supportedValues=getSupportedValues(this)
            supportedValues=this.SupportedParameterValues;
        end

        function[status,resultData]=check(this,system)
            status=false;
            resultData=[];
            cs=this.getActiveConfigSet(system);
            sysRoot=bdroot(system);







            if cs.isValidParam(this.ParameterName)

                try
                    hasERTTarget=get_param(sysRoot,'IsERTTarget');
                catch
                    DAStudio.error('Advisor:engine:CCUnableReadParameter',this.ParameterName);
                end

                if strcmp(hasERTTarget,'on')
                    status=true;
                    this.Status=true;
                    this.CurrentValue=DAStudio.message('Advisor:engine:CCERTBasedTarget');
                else
                    this.CurrentValue=DAStudio.message('Advisor:engine:CCNonERTTarget');



                    resultData=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(resultData,'Model',Simulink.ID.getSID(sysRoot),...
                    'Parameter',this.ParameterName,...
                    'RecommendedValue',DAStudio.message('Advisor:engine:CCERTBasedTarget'),...
                    'CurrentValue',DAStudio.message('Advisor:engine:CCNonERTTarget'));

                    resultData.IsInformer=this.IsInformational;

                    if this.HasFix
                        this.FixIt=true;
                    end
                end


                this.WasChecked=true;

            else
                this.CheckingErrorMessage=DAStudio.message('Advisor:engine:CCInactiveModelParameter');
            end
        end
    end


    methods(Hidden)
        function data=getConstraintResultData(this)

            data.ResultStatus=this.Status;
            data.ID=this.ID;
            data.IsInformational=this.IsInformational;
            data.PreRequisiteConstraintIDs=this.PreRequisiteConstraintIDs;


            data.ParamterName=this.ParameterName;
            data.CurrentValue=this.CurrentValue;


            data.SupportedValues=this.SupportedParameterValues;
        end

        function p=getDocumentation(this)
            p=Advisor.Paragraph;


            p.addItem('<h3>ERT System Target File Model Parameter Constraint</h3>');
            p.addItem(Advisor.LineBreak);

            p.addItem(['ID: ',this.ID]);
            p.addItem(Advisor.LineBreak);

            if this.IsInformational
                status='yes';
            else
                status='no';
            end
            p.addItem(['Is informational: ',status]);
            p.addItem(Advisor.LineBreak);

            p.addItem(['Parameter Name: ',this.ParameterName]);
            p.addItem(Advisor.LineBreak);

            p.addItem(['Supported Parameter Values: ',this.SupportedParameterValues]);
            p.addItem(Advisor.LineBreak);
            p.addItem(Advisor.LineBreak);

            if~isempty(this.PreRequisiteConstraintIDs)
                preRequisiteConstraintIDs=Advisor.authoring.OutputFormatting.cell2String(this.PreRequisiteConstraintIDs);
            else
                preRequisiteConstraintIDs='none';
            end

            p.addItem(['Pre-requisit Constraints: ',preRequisiteConstraintIDs]);
            p.addItem(Advisor.LineBreak);
            p.addItem(Advisor.LineBreak);
        end
    end

    methods(Access=protected)



        function scanConstraintSpecificNode(this,node)%#ok<INUSD>

            DAStudio.error('Advisor:engine:CCUnknownXMLNode','');
        end
    end
end

