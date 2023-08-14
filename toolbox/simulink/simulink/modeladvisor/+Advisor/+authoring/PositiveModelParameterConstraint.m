classdef PositiveModelParameterConstraint<Advisor.authoring.ModelParameterConstraint


















































    properties
        SupportedParameterValues={};
    end

    properties(SetAccess=protected,Hidden=true)
        locSupportedParameterValues={};
    end

    methods

        function this=PositiveModelParameterConstraint(varargin)

            if nargin==2&&(isa(varargin{1},'matlab.io.xml.dom.Element'))

                this.scanDOMNode(varargin{1});
                this.setID(varargin{2});
                this.SupportedParameterValues=this.locSupportedParameterValues;

            elseif nargin==1&&isstruct(varargin{1})

                defStruct=varargin{1};


                requiredFields={'ParameterName','SupportedParameterValues'};
                actualFields=fieldnames(defStruct);

                for n=1:length(requiredFields)
                    if~any(strcmp(actualFields,requiredFields{n}))
                        DAStudio.error('Advisor:engine:CCConstructorMandatoryParameterMissing',requiredFields{n},'PositiveModelParameterConstraint');
                    end
                end


                actualFields={'ParameterName',actualFields{~strcmp(actualFields,'ParameterName')}};


                for n=1:length(actualFields)
                    property=actualFields{n};
                    switch property
                    case 'ParameterName'
                        this.setParameterName(defStruct.(property));

                    case 'SupportedParameterValues'
                        this.SupportedParameterValues=defStruct.(property);

                    case 'PreRequisiteConstraintIDs'
                        this.setPreRequisiteConstraintIDs(defStruct.(property));

                    case 'FixValue'
                        this.setFixValue(this.convertValue(defStruct.(property)));

                    case 'ID'
                        this.setID(defStruct.(property));

                    case 'IsInformational'
                        this.IsInformational=defStruct.(property);

                    otherwise
                        DAStudio.error('Advisor:engine:CCUnknownPropDefStruct',property,'PositiveModelParameterConstraint');
                    end
                end
            elseif nargin~=0
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','PositiveModelParameterConstraint');
            end
        end


        function supportedValues=getSupportedValues(this)
            supportedValues=this.SupportedParameterValues;
        end

        function set.SupportedParameterValues(this,values)
            this.SupportedParameterValues={};
            this.setLocSupportedParameterValues(values);
            this.SupportedParameterValues=this.getLocSupportedValues();
        end


        function addSupportedParameterValue(this,value)
            if this.isSupportedValue(value)
                this.locSupportedParameterValues{end+1}=value;
            else
                DAStudio.error('Advisor:engine:CCUnsupportedModelParameterValue',value,this.ParameterName);
            end
        end

        function[status,resultData]=check(this,system)
            status=false;
            resultData=[];
            cs=this.getActiveConfigSet(system);
            sysRoot=bdroot(system);







            if cs.isValidParam(this.ParameterName)

                this.CurrentValue=this.getCurrentParameterValue(sysRoot);

                [status,this.SupportedParameterValues]=this.resolveAndCompareCurrentAndCompareValues(sysRoot,this.SupportedParameterValues);

                if status
                    this.Status=true;
                else


                    resultData=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(resultData,'Model',Simulink.ID.getSID(sysRoot),...
                    'Parameter',this.ParameterName,...
                    'RecommendedValue',this.SupportedParameterValues,...
                    'CurrentValue',this.CurrentValue);

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


            p.addItem('<h3>Positive Model Parameter Constraint</h3>');
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

            vcell=this.getSupportedValues();

            for i=1:length(vcell)
                vcell{i}=this.value2String(vcell{i});
            end

            p.addItem(['Supported Parameter Values: ',...
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




        function constraintNode=getXMLNode(this,doc)
            constraintNode=doc.createElement('PositiveModelParameterConstraint');
            if~isempty(this.ID)
                constraintNode.setAttribute('id',this.ID);
            end
            if this.IsInformational
                constraintNode.setAttribute('status','informational');
            end



            parameterNode=doc.createElement('parameter');
            parameterNode.setTextContent(this.ParameterName);
            constraintNode.appendChild(parameterNode);


            for n=1:length(this.SupportedParameterValues)
                valueNode=doc.createElement('value');

                if this.getHasScalarValue()
                    valueNode.setTextContent(this.SupportedParameterValues{n});
                else
                    Advisor.authoring.ModelParameterConstraint.createComplexValueNode(doc,valueNode,this.SupportedParameterValues{n});
                end

                constraintNode.appendChild(valueNode);
            end


            if this.HasFix
                fixNode=doc.createElement('fixvalue');

                if this.getHasScalarValue()
                    fixNode.setTextContent(this.FixValue);
                else
                    Advisor.authoring.ModelParameterConstraint.createComplexValueNode(doc,fixNode,this.FixValue);
                end

                constraintNode.appendChild(fixNode);
            end

            if~isempty(this.PreRequisiteConstraintIDs)
                for n=1:length(this.PreRequisiteConstraintIDs)
                    dependsOnNode=doc.createElement('dependson');
                    dependsOnNode.setTextContent(this.PreRequisiteConstraintIDs{n});
                    constraintNode.appendChild(dependsOnNode);
                end
            end
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
                        this.addSupportedParameterValue(this.getXMLNodeTextContent(node));
                    else


                        this.addSupportedParameterValue(this.parseComplexValueNode(node));
                    end

                otherwise
                    DAStudio.error('Advisor:engine:CCUnknownXMLNode',nodeName);
                end
            end
        end


        function setLocSupportedParameterValues(this,values)
            this.locSupportedParameterValues={};
            if~iscell(values)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setSupportedParameterValues');
            end

            for n=1:length(values)
                this.addSupportedParameterValue(this.convertValue(values{n}));
            end
        end


        function supportedValues=getLocSupportedValues(this)
            supportedValues=this.locSupportedParameterValues;
        end
    end
end

