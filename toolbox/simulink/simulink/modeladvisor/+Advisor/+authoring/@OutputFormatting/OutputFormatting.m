classdef OutputFormatting<handle






    properties(Access=private)
        Type='';
        Description='';
        CheckStatus='Warn';
        ResultDescriptionPass='';
        ResultDescriptionFail='';
        RecommendedActions='';
        Constraints;
        DataFileName;
        ErrorSeverity=0;
    end

    methods(Access=public)
        [Description,Status,RecAction]=getResultDetailsInfo(this)

        function this=OutputFormatting(type)


            if~ischar(type)||~any(strcmpi(type,{'check','action'}))
                DAStudio.error('Advisor:engine:CCOFUnsupportedOutputFormatting');
            else
                this.Type=type;
            end
        end


        function setResultStatus(this,status)
            if~ischar(status)||~any(strcmpi(status,{'Pass','Warn','Fail'}))
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setResultStatus');
            else
                this.CheckStatus=status;
            end
        end

        function setConstraints(this,constraints)
            if~isa(constraints,'containers.Map')
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setConstraints');
            end

            this.Constraints=constraints;
        end

        function setDataFileName(this,name)
            this.DataFileName=name;
        end

        function setErrorSeverity(this,severity)

            this.ErrorSeverity=severity;
        end

        function setResultDescriptionPass(this,description)
            if~ischar(description)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setResultDescriptionPass');
            end

            this.ResultDescriptionPass=description;
        end

        function setResultDescriptionFail(this,description)
            if~ischar(description)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setResultDescriptionFail');
            end

            this.ResultDescriptionFail=description;
        end

        function setRecommendedActions(this,recAct)
            if~ischar(recAct)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setRecommendedActions');
            end

            this.RecommendedActions=recAct;
        end

        function setDescription(this,description)
            if~ischar(description)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setDescription');
            end

            this.Description=description;
        end

        function output=getFormattedOutput(this,system)
            output='';



            if this.checkAllConstraintTypes('Advisor.authoring.ModelParameterConstraint')

                if strcmp(this.Type,'check')
                    output=this.getModelParameterOutput(system);
                else
                    output=this.getModelParameterActionOutput(system);
                end
            else





            end
        end


        function parseMessageDOMNode(this,messageParentNode)
            evalMessages=false;
            messageType=messageParentNode.getAttribute('type');
            if strcmp(messageType,'catalog')
                evalMessages=true;
            end


            messageNodes=messageParentNode.getChildNodes;

            for n=0:messageNodes.getLength-1
                if messageNodes.item(n).getNodeType==1
                    nodeName=char(messageNodes.item(n).getNodeName);

                    switch nodeName
                    case 'Description'
                        this.setDescription(this.getMessageNodeContent(messageNodes.item(n),evalMessages));
                    case 'PassMessage'
                        this.setResultDescriptionPass(this.getMessageNodeContent(messageNodes.item(n),evalMessages));
                    case 'FailMessage'
                        this.setResultDescriptionFail(this.getMessageNodeContent(messageNodes.item(n),evalMessages));
                    case 'RecommendedActions'
                        this.setRecommendedActions(this.getMessageNodeContent(messageNodes.item(n),evalMessages));
                    otherwise


                    end
                end
            end
        end
    end

    methods(Access=private)



        ft=getModelParameterOutput(this,system)

        ft=getModelParameterActionOutput(this,system)




        function status=checkAllConstraintTypes(this,type)
            status=true;
            constraintCell=this.Constraints.values;

            for n=1:length(constraintCell)
                if~isa(constraintCell{n},type)
                    status=false;
                    return;
                end
            end
        end

        function status=checkForSpecificConstraintType(this,type)
            status=false;
            constraintCell=this.Constraints.values;

            for n=1:length(constraintCell)
                if isa(constraintCell{n},type)
                    status=true;
                    return;
                end
            end
        end



        function statusString=getStatusString(this,constraint)
            span=Advisor.Element;
            span.setTag('span');

            if constraint.Status
                span.setAttribute('class','ResultStatusStringPass');
                span.setContent(DAStudio.message('Advisor:engine:Pass'));
            else
                if this.ErrorSeverity==0
                    span.setAttribute('class','ResultStatusStringWarn');
                    span.setContent(DAStudio.message('Advisor:engine:Warn'));
                else
                    span.setAttribute('class','ResultStatusStringFail');
                    span.setContent(DAStudio.message('Advisor:engine:Fail'));
                end
            end
            statusString=span.emitHTML;
        end


        function link=createLinkToDataFile(this)

            link=Advisor.Text(this.DataFileName);
            if exist(this.DataFileName,'file')==2
                link.setHyperlink(['matlab:%20open%20',this.DataFileName]);
            end
        end

        function status=getConstraintOutputStatus(this,constraint)
            status=true;



            if constraint.Status==true&&any(strcmp(this.CheckStatus,{'Warn','Fail'}))
                status=false;
            end





            status=status&&constraint.getOutputStatus();
        end
    end

    methods(Hidden,Static)

        function string=cell2String(cell)
            string='';
            for n=1:length(cell)
                string=[string,cell{n}];%#ok<AGROW>
                if n~=length(cell)
                    string=[string,', '];%#ok<AGROW>
                end
            end
        end
    end

    methods(Static=true,Access=private)
        function str=getMessageNodeContent(node,evalMessages)

            if node.hasChildNodes()
                nodeValue=strtrim(char(node.getFirstChild.getNodeValue()));
            else
                nodeValue='';
            end

            if~evalMessages
                str=nodeValue;
            else
                str=DAStudio.message(nodeValue);
            end
        end
    end
end

