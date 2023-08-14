classdef NegativeModelParameterConstraint<Advisor.authoring.ModelParameterConstraint



















































    properties
        UnsupportedParameterValues={};
    end

    properties(SetAccess=protected,Hidden=true)
        locUnsupportedParameterValues={};
    end

    methods
        function this=NegativeModelParameterConstraint(varargin)

            if nargin==2&&(isa(varargin{1},'matlab.io.xml.dom.Element'))

                this.scanDOMNode(varargin{1});
                this.setID(varargin{2});
                this.UnsupportedParameterValues=this.locUnsupportedParameterValues;

            elseif nargin==1&&isstruct(varargin{1})

                defStruct=varargin{1};


                requiredFields={'ParameterName','UnsupportedParameterValues'};
                actualFields=fieldnames(defStruct);

                for n=1:length(requiredFields)
                    if~any(strcmp(actualFields,requiredFields{n}))
                        DAStudio.error('Advisor:engine:CCConstructorMandatoryParameterMissing',requiredFields{n},'NegativeModelParameterConstraint');
                    end
                end


                actualFields={'ParameterName',actualFields{~strcmp(actualFields,'ParameterName')}};


                for n=1:length(actualFields)
                    property=actualFields{n};
                    switch property
                    case 'ParameterName'
                        this.setParameterName(defStruct.(property));

                    case 'UnsupportedParameterValues'
                        this.UnsupportedParameterValues=defStruct.(property);

                    case 'PreRequisiteConstraintIDs'
                        this.setPreRequisiteConstraintIDs(defStruct.(property));

                    case 'FixValue'
                        this.setFixValue(this.convertValue(defStruct.(property)));

                    case 'ID'
                        this.setID(defStruct.(property));

                    case 'IsInformational'
                        this.IsInformational=defStruct.(property);

                    otherwise
                        DAStudio.error('Advisor:engine:CCUnknownPropDefStruct',property,'NegativeModelParameterConstraint');
                    end
                end
            elseif nargin~=0
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','NegativeModelParameterConstraint');
            end
        end

        function unsupportedValues=getUnsupportedValues(this)
            unsupportedValues=this.UnsupportedParameterValues;
        end

        function set.UnsupportedParameterValues(this,values)
            this.UnsupportedParameterValues={};
            this.setLocUnsupportedParameterValues(values);
            this.UnsupportedParameterValues=this.getLocUnsupportedValues();
        end

        function addUnsupportedParameterValue(this,value)
            if this.isSupportedValue(value)
                this.locUnsupportedParameterValues{end+1}=value;
            else
                DAStudio.error('Advisor:engine:CCUnsupportedModelParameterValue',value,this.ParameterName);
            end
        end

        function unsupportedValues=getLocUnsupportedValues(this)
            unsupportedValues=this.locUnsupportedParameterValues;
        end

        function setLocUnsupportedParameterValues(this,values)
            this.locUnsupportedParameterValues={};
            if~iscell(values)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setUnsupportedParameterValues');
            end

            for n=1:length(values)
                this.addUnsupportedParameterValue(this.convertValue(values{n}));
            end
        end

        function[status,resultData]=check(this,system)
            status=true;
            resultData=[];
            cs=this.getActiveConfigSet(system);
            sysRoot=bdroot(system);







            if cs.isValidParam(this.ParameterName)

                this.CurrentValue=this.getCurrentParameterValue(sysRoot);

                [bStatus,this.UnsupportedParameterValues]=this.resolveAndCompareCurrentAndCompareValues(sysRoot,this.UnsupportedParameterValues);

                if bStatus
                    status=false;

                    resultData=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(resultData,'Model',Simulink.ID.getSID(sysRoot),...
                    'Parameter',this.ParameterName,...
                    'RecommendedValue',this.UnsupportedParameterValues,...
                    'CurrentValue',this.CurrentValue);

                    resultData.IsInformer=this.IsInformational;

                    if this.HasFix
                        this.FixIt=true;
                    end
                else
                    this.Status=true;
                end


                this.WasChecked=true;
            else
                this.CheckingErrorMessage=DAStudio.message('Advisor:engine:CCInactiveModelParameter');
                status=false;
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


            data.UnsupportedValues=this.UnsupportedParameterValues;
        end

        function p=getDocumentation(this)
            p=Advisor.Paragraph;


            p.addItem('<h3>Negative Model Parameter Constraint</h3>');
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

            vcell=this.getUnsupportedValues();

            for i=1:length(vcell)
                vcell{i}=this.value2String(vcell{i});
            end

            p.addItem(['Unsupported Parameter Values: ',...
            Advisor.authoring.OutputFormatting.cell2String(vcell)]);
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



        function scanConstraintSpecificNode(this,node)


            if node.getNodeType==1
                nodeName=char(node.getNodeName);

                switch nodeName
                case 'parameter'

                    this.setParameterName(this.getXMLNodeTextContent(node));
                case 'value'


                    this.checkValueDataType(node);

                    if this.getHasScalarValue()
                        this.addUnsupportedParameterValue(this.getXMLNodeTextContent(node));
                    else


                        this.addUnsupportedParameterValue(this.parseComplexValueNode(node));
                    end
                otherwise
                    DAStudio.error('Advisor:engine:CCUnknownXMLNode',nodeName);
                end
            end
        end
    end
end

