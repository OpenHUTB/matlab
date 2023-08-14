classdef ModelParameterConstraint<Advisor.authoring.Constraint


















    properties
        ParameterName='';
    end

    properties(SetAccess=protected,Hidden=true)
        CurrentValue;
        FixValue='';
    end

    properties(SetAccess=private,Hidden=true)
        HasInvertedLogic=false;
        HasScalarValue=true;
        ParameterDataType='string';
    end

    methods

        function fixIncompatability(this,system)

            if this.FixIt
                errorMsg=this.isParameterEditable(system);

                if~isa(getActiveConfigSet(bdroot(system)),'Simulink.ConfigSetRef')&&...
                    isempty(errorMsg)

                    try
                        if this.getHasScalarValue()
                            if strcmpi(this.ParameterDataType,'integer')
                                set_param(bdroot(system),this.ParameterName,str2double(this.FixValue));
                            else
                                set_param(bdroot(system),this.ParameterName,this.FixValue);
                            end
                        elseif strcmp(this.ParameterDataType,'struct')



                            currentValue=get_param(bdroot(system),this.ParameterName);
                            props=fieldnames(this.FixValue);

                            for n=1:length(props)
                                fixprop=false;
                                if isobject(currentValue)&&isprop(currentValue,props{n})
                                    fixprop=true;
                                elseif isstruct(currentValue)&&isfield(currentValue,props{n})
                                    fixprop=true;
                                end

                                if fixprop



                                    pv=this.FixValue.(props{n});
                                    if isnumeric(currentValue.(props{n}))
                                        pv=str2double(pv);
                                    end

                                    currentValue.(props{n})=pv;
                                end
                            end

                            set_param(bdroot(system),this.ParameterName,currentValue);
                        else


                            set_param(bdroot(system),this.ParameterName,this.FixValue);
                        end


                        this.FixIt=false;
                        this.WasFixed=true;
                    catch E
                        DAStudio.error('Advisor:engine:CCUnsuccesfulFix',this.ParameterName);
                    end
                else
                    this.FixIt=false;
                end
            end
        end





        function link=getHyperlinkToParameter(this,system)
            link=Advisor.Utils.getHyperlinkToConfigSetParameter(...
            bdroot(system),this.ParameterName);
        end

        function setParameterName(this,ParameterName)
            this.ParameterName=ParameterName;
        end

        function set.ParameterName(this,ParameterName)
            if ischar(ParameterName)&&this.isValidParameterName(ParameterName)
                this.ParameterName=ParameterName;


                this.setHasInvertedLogic(this.isParameterWithInvertedLogic());



                type=this.getParameterDataType(ParameterName);
                this.setParameterDataType(type);

                switch type
                case{'mxArray','cellString','struct','array'}
                    this.setHasScalarValue(false);
                otherwise
                    this.setHasScalarValue(true);
                end
            else
                DAStudio.error('Advisor:engine:CCIncorrectModelParamName',ParameterName);
            end
        end
    end

    methods(Access=protected)

        function setHasScalarValue(this,value)
            this.HasScalarValue=value;
        end

        function value=getHasScalarValue(this)
            value=this.HasScalarValue;
        end

        function setParameterDataType(this,value)
            this.ParameterDataType=value;
        end

        function setHasInvertedLogic(this,value)
            this.HasInvertedLogic=value;
        end

        function value=getHasInvertedLogic(this)
            value=this.HasInvertedLogic;
        end

        status=isSupportedValue(this,Values)


        function setFixValue(this,value)
            if this.isSupportedValue(value)
                this.FixValue=value;
                this.HasFix=true;
            else
                DAStudio.error('Advisor:engine:CCIncorrectFixValue',value,this.ParameterName);
            end
        end


        function scanDOMNode(this,constraintNode)


            constrType=char(constraintNode.getAttribute('status'));

            if~isempty(constrType)
                if strcmp(constrType,'informational')
                    this.IsInformational=true;
                else
                    DAStudio.error('Advisor:engine:CCUnsupportedXMLAttributeValue',constrType,'status');
                end
            end


            childNodes=constraintNode.getChildNodes;

            for n=0:childNodes.getLength-1

                if childNodes.item(n).getNodeType==1
                    nodeName=char(childNodes.item(n).getNodeName);
                    switch nodeName
                    case 'fixvalue'


                        vn=childNodes.item(n);
                        this.checkValueDataType(vn);

                        if this.getHasScalarValue()
                            this.setFixValue(this.getXMLNodeTextContent(vn));
                        else
                            this.setFixValue(this.parseComplexValueNode(vn));
                        end
                    case 'dependson'

                        this.addPreRequisiteConstraintID(this.getXMLNodeTextContent(childNodes.item(n)));
                    otherwise

                        this.scanConstraintSpecificNode(childNodes.item(n));
                    end
                end
            end
        end











        function prompt=getParameterUIPrompt(this,system)
            prompt=Advisor.Utils.getConfigSetParameterUIPrompt(...
            bdroot(system),this.ParameterName);
        end







        function props=getCurrentParameterProperties(this,system)
            cs2=this.getActiveConfigSetV2(system);




            try

                status=cs2.getParamStatus(this.ParameterName);
                isWritable=configset.getParameterInfo(system,this.ParameterName).IsWritable;

                if status==configset.internal.data.ParamStatus.Normal&&isWritable

                    props.Enabled=true;
                elseif status==configset.internal.data.ParamStatus.ReadOnly
                    props.Enabled=false;
                else
                    props.Enabled=false;
                end
            catch err %#ok<NASGU>




                props.Enabled=false;



            end
        end




        function msg=isParameterEditable(this,system)
            parameterProperties=this.getCurrentParameterProperties(system);

            if parameterProperties.Enabled
                msg='';
            else

                msg=DAStudio.message('Advisor:engine:CCInactiveModelParameter');
            end
        end









        function status=isParameterWithInvertedLogic(this)
            data=configset.internal.getConfigSetStaticData;
            try
                pdata=data.getParam(this.ParameterName);
                status=pdata.isInvertValue;
            catch
                status=false;
            end
        end









        function value=parseComplexValueNode(this,node)
            value=[];

            childNodes=node.getChildNodes;
            if childNodes.getLength>0

                [dt,isAScalar]=...
                Advisor.authoring.ModelParameterConstraint.getValueNodeDataType(node);

                if strcmp(dt,'struct')
                    if isAScalar
                        value=this.parseStructValueNode(node);
                    else
                        for n=0:childNodes.getLength-1
                            if childNodes.item(n).getNodeType==1&&...
                                strcmp(char(childNodes.item(n).getNodeName),'element')

                                tempValue=this.parseStructValueNode(childNodes.item(n));

                                if isempty(value)
                                    value=tempValue;
                                else
                                    value(end+1)=tempValue;%#ok<AGROW>
                                end
                            end
                        end
                    end
                elseif strcmp(dt,'array')
                    valueIndex=0;
                    for n=0:childNodes.getLength-1

                        if childNodes.item(n).getNodeType==1&&...
                            strcmp(char(childNodes.item(n).getNodeName),'element')

                            valueIndex=valueIndex+1;
                            nodeValue=this.getXMLNodeTextContent(childNodes.item(n));
                            value{valueIndex}=nodeValue;%#ok<AGROW>                       
                        end
                    end
                end
            end

            if isempty(value)

                value=this.getXMLNodeTextContent(node);
            end
        end


        function value=parseStructValueNode(this,node)
            value=struct();
            propertyNodes=node.getChildNodes();
            for M=0:node.getLength-1
                if propertyNodes.item(M).getNodeType==1
                    parameterName=char(propertyNodes.item(M).getNodeName);
                    nodeValue=this.getXMLNodeTextContent(propertyNodes.item(M));
                    value.(parameterName)=nodeValue;
                end
            end
        end





        function value=getCurrentParameterValue(this,model)
            try


                tempValue=get_param(model,this.ParameterName);

                value=this.convertValue(tempValue);
            catch err
                if isempty(err.cause)
                    DAStudio.error('Advisor:engine:CCUnableReadParameter',this.ParameterName);
                else
                    error(err.cause{1}.message);
                end
            end
        end



        function checkValueDataType(this,vnode)
            dt=this.getValueNodeDataType(vnode);




            if any(strcmp(this.ParameterDataType,{'mxArray','cellString','struct','array'}))

                if~strcmp(dt,'empty')&&~strcmp(this.ParameterDataType,dt)

                    DAStudio.error('Advisor:engine:CCDataTypeMismatch',...
                    this.ParameterName,dt,this.ParameterDataType);

                end
            end
        end









        function[status,resolvedCompareValues]=resolveAndCompareCurrentAndCompareValues(this,sysRoot,CompareValues)


            status=false;%#ok

            [rCurrentVal,resStatus]=Advisor.Utils.Simulink.resolveConfigSetValue(sysRoot,this.ParameterName);

            if(resStatus==true)

                this.CurrentValue=this.value2String(rCurrentVal);



                for i=1:length(CompareValues)
                    if~isnumeric(CompareValues{i})
                        try
                            CompareValues{i}=eval(CompareValues{i});
                        catch
                        end
                    end
                end


                status=any(this.compareParameterValues(CompareValues,rCurrentVal));
            else
                status=any(this.compareParameterValues(CompareValues,this.CurrentValue));
            end

            resolvedCompareValues=CompareValues;
        end
    end


    methods(Abstract,Access=protected)
        scanConstraintSpecificNode(this,node)
    end


    methods(Access=protected,Static)

        status=isValidParameterName(this,ParameterName)


        function cs=getActiveConfigSet(system)
            systemObj=get_param(bdroot(system),'object');
            cs=systemObj.getActiveConfigSet();
        end


        function cs2=getActiveConfigSetV2(system)
            systemObj=get_param(bdroot(system),'object');
            cs=systemObj.getActiveConfigSet();



            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.getRefConfigSet();
                cs2=configset.internal.data.ConfigSetAdapter(cs);
            else
                cs2=configset.internal.data.ConfigSetAdapter(cs);
            end
        end




        function text=getXMLNodeTextContent(node)
            if(node.hasChildNodes())
                text=strtrim(char(node.getFirstChild().getTextContent()));
            else
                text='';
            end
        end






        function isEqual=compareParameterValues(valueArray,value)
            isEqual=false(size(valueArray));

            for n=1:length(valueArray)
                if ischar(valueArray{n})

                    isEqual(n)=strcmpi(valueArray{n},value);
                else
                    isEqual(n)=isequal(valueArray{n},value);
                end
            end
        end


    end

    methods(Static)





        function dt=getParameterDataType(paramName)
            data=configset.internal.getConfigSetStaticData();
            pdata=data.getParam(paramName);
            if iscell(pdata)
                dt=pdata{1}.Type;
            else
                dt=pdata.Type;
            end

            if strcmp(dt,'cellString')
                dt='array';
            elseif strcmp(dt,'string')||strcmp(dt,'mxArray')


                arrayParams={'CustomToolchainOptions'};

                structParams={'CodeCoverageSettings','ReplacementTypes'};

                if any(strcmp(arrayParams,paramName))
                    dt='array';
                elseif any(strcmp(structParams,paramName))
                    dt='struct';
                end
            end
        end



        function createComplexValueNode(doc,vnode,value)
            if isstruct(value)

                props=fieldnames(value);

                if isscalar(value)
                    for n=1:length(props)
                        parameterNode=doc.createElement(props{n});
                        parameterNode.setTextContent(value.(props{n}));
                        vnode.appendChild(parameterNode);
                    end
                else

                    for N=1:length(value)
                        elementNode=doc.createElement('element');
                        for M=1:length(props)
                            parameterNode=doc.createElement(props{M});
                            parameterNode.setTextContent(value(N).(props{M}));
                            elementNode.appendChild(parameterNode);
                        end
                        vnode.appendChild(elementNode);
                    end
                end
            elseif iscell(value)
                for n=1:length(value)
                    parameterNode=doc.createElement('element');
                    parameterNode.setTextContent(value{n});
                    vnode.appendChild(parameterNode);
                end
            end
        end



        function strvalue=value2String(value)
            if ischar(value)
                if isempty(value)


                    strvalue=' ';
                else
                    strvalue=value;
                end
            elseif isstruct(value)
                if isscalar(value)
                    strvalue=evalc('disp(value)');
                else
                    strvalue='';

                    for N=1:length(value)
                        strvalue=[strvalue,evalc('disp(value(N))')];%#ok<AGROW>
                    end
                end
            elseif isnumeric(value)
                strvalue=lower(num2str(value));
            elseif iscell(value)
                strvalue=strjoin(value',', ');
            else
                strvalue='';
            end
        end
    end

    methods(Static,Hidden)




        function value=convertValue(tempValue)
            if isnumeric(tempValue)
                value=num2str(tempValue);

            elseif isstruct(tempValue)

                props=fieldnames(tempValue);



                for M=1:length(tempValue)
                    for n=1:length(props)
                        tempValue(M).(props{n})=Advisor.authoring.ModelParameterConstraint.convertValue(tempValue(M).(props{n}));
                    end
                end
                value=tempValue;

            elseif isobject(tempValue)


                wState=warning('query','MATLAB:structOnObject');

                if strcmpi(wState.state,'on')
                    warning('off','MATLAB:structOnObject');
                    tempValue=struct(tempValue);
                    warning('on','MATLAB:structOnObject');
                else
                    tempValue=struct(tempValue);
                end

                value=Advisor.authoring.ModelParameterConstraint.convertValue(tempValue);

            else

                value=tempValue;
            end
        end
    end

    methods(Static,Access=protected)















        function[dt,isAScalar]=getValueNodeDataType(node)

            childNodes=node.getChildNodes();
            isAScalar=true;

            if childNodes.getLength()>0
                hasOnlyTextNodes=true;
                hasOnlyElementNodes=true;

                for n=0:node.getLength()-1
                    cn=childNodes.item(n);

                    if cn.getNodeType()==node.ELEMENT_NODE
                        hasOnlyTextNodes=false;
                        elementName=char(cn.getNodeName());

                        if~strcmp(elementName,'element')
                            hasOnlyElementNodes=false;
                        else


                            elementChildren=cn.getChildNodes();
                            for M=0:cn.getLength()-1
                                if elementChildren.item(M).getNodeType()==node.ELEMENT_NODE




                                    hasOnlyElementNodes=false;
                                    isAScalar=false;
                                    break;
                                end
                            end
                        end
                    end
                end

                if hasOnlyTextNodes
                    dt='string';
                elseif hasOnlyElementNodes
                    dt='array';
                    isAScalar=false;
                else
                    dt='struct';
                end
            else


                dt='empty';
            end
        end

    end
end

