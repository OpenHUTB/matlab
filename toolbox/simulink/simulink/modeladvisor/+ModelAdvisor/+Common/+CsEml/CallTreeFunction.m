
classdef CallTreeFunction<ModelAdvisor.Common.CsEml.CallTreeBase

    methods(Access=public)

        function this=CallTreeFunction(parentNode,inferenceReport,irFunctionId,callStart,callEnd)
            this=this@ModelAdvisor.Common.CsEml.CallTreeBase(parentNode);
            this.m_IrFunctionId=irFunctionId;
            this.m_InstanceInfo=ModelAdvisor.Common.CsEml.InstanceInfo.empty;
            if nargin==3
                callStart=0;
                callEnd=0;
            end
            this.m_CallStart=callStart;
            this.m_CallEnd=callEnd;
            this.privateInitialize(inferenceReport);
        end

        function irFunctionId=getIrFunctionId(this)
            irFunctionId=this.m_IrFunctionId;
        end

        function callStart=getCallStart(this)
            callStart=this.m_CallStart;
        end

        function callEnd=getCallEnd(this)
            callEnd=this.m_CallEnd;
        end

        function addInstancesToCallTree(this,blockInstances)
            irFunctionIds=blockInstances.getIrFunctionId();
            li=this.m_IrFunctionId==irFunctionIds;
            this.m_InstanceInfo=blockInstances(li);
            numChildren=this.getNumberOfChildren();
            for i=1:numChildren
                child=this.getChild(i);
                child.addInstancesToCallTree(blockInstances);
            end
        end

        function callTreeNodes=getCallTreeNodes(this,irFunctionId)
            callTreeNodes=ModelAdvisor.Common.CsEml.CallTreeFunction.empty;
            if irFunctionId==this.m_IrFunctionId
                callTreeNodes=this;
            end
            numChildren=this.getNumberOfChildren();
            for i=1:numChildren
                child=this.getChild(i);
                newCallTreeNodes=child.getCallTreeNodes(irFunctionId);
                callTreeNodes=[callTreeNodes;newCallTreeNodes];%#ok<AGROW>
            end
        end

        function table=toHtml(this)
            table=Advisor.Element('table','width','100%','class','noborder');


            parentNode=this.getParent();
            flag=true;
            level=0;
            while flag
                if isa(parentNode,'ModelAdvisor.Common.CsEml.CallTreeFunction')
                    level=level+1;
                    actualNode=parentNode;
                    parentNode=actualNode.getParent();
                else
                    flag=false;
                end
            end


            actualNode=this;
            parentNode=this.getParent();
            flag=true;
            rows=[];
            while flag
                tr=Advisor.Element('tr');
                td1=Advisor.Element('td','width','35%');


                td3=Advisor.Element('td','width','5%');
                td4=Advisor.Element('td','width','5%');
                td5=Advisor.Element('td','width','50%');
                tr.addContent(td1);

                tr.addContent(td3);
                tr.addContent(td4);
                tr.addContent(td5);

                if level>0
                    if level>1
                        td1.addContent(['<span style="visibility: hidden;">',repmat('&rarr;',1,level-1),'</span>']);
                    end
                    td1.addContent('<font style="color: #B0B0B0;">&rarr;</font>');
                    level=level-1;
                end
                td1.addContent(parentNode.getFunctionTypeText());
                td1.addContent('&nbsp;');
                td1.addContent(parentNode.getFunctionNameText());

                td3.addContent(actualNode.getFunctionTypeText())
                [codeLine,lineNumber]=actualNode.getCodeLineText();
                td4.addContent(lineNumber);
                td5.addContent(codeLine);
                if isempty(rows)
                    rows=tr;
                else
                    rows(end+1)=tr;
                end
                if isa(parentNode,'ModelAdvisor.Common.CsEml.CallTreeFunction')
                    actualNode=parentNode;
                    parentNode=actualNode.getParent();
                else
                    flag=false;
                end
            end
            rows=fliplr(rows);
            for i=1:numel(rows)
                table.addContent(rows(i));
            end
        end

        function text=getFunctionTypeText(this)
            functionType=this.m_InstanceInfo.getFunctionType();
            text=this.formatFunctionType(functionType);
        end

        function text=getFunctionNameText(this)
            functionName=this.m_InstanceInfo.getFunctionName();
            functionType=this.m_InstanceInfo.getFunctionType();
            switch functionType
            case ModelAdvisor.Common.CsEml.FunctionType.Function
                text=Advisor.Text(functionName);
            case ModelAdvisor.Common.CsEml.FunctionType.EntryAction
                text=Advisor.Text('Entry action');
            case ModelAdvisor.Common.CsEml.FunctionType.DuringAction
                text=Advisor.Text('During action');
            case ModelAdvisor.Common.CsEml.FunctionType.ExitAction
                text=Advisor.Text('Exit action');
            case ModelAdvisor.Common.CsEml.FunctionType.Condition
                text=Advisor.Text('Condition');
            case ModelAdvisor.Common.CsEml.FunctionType.TransitionAction
                text=Advisor.Text('Transition action');
            case ModelAdvisor.Common.CsEml.FunctionType.ConditionAction
                text=Advisor.Text('Condition action');
            otherwise
                text=Advisor.Text('unknown');
            end
        end

        function[codeLine,lineNumber]=getCodeLineText(this)
            parentNode=this.getParent();
            switch class(parentNode)
            case 'CsEml.CallTreeBlock'
                lineNumber=this.formatLineNumber();
                string=this.getFunctionNameText();

                codeLine=Advisor.Element('span','class','codefragment');
                codeLine.addContent(string);

            case 'CsEml.CallTreeFunction'
                parentScriptCode=parentNode.getScriptCode();
                lineBreaks=find(parentScriptCode==10);
                i2=this.position(1);
                i3=this.position(2);
                previousLineBreaks=find(i2>lineBreaks);
                followingLineBreaks=find(i3<lineBreaks);
                if isempty(previousLineBreaks)
                    i1=1;
                    lineNumber=this.formatLineNumber(1);
                else
                    i1=lineBreaks(previousLineBreaks(end))+1;
                    num=numel(previousLineBreaks)+1;
                    lineNumber=this.formatLineNumber(num);
                end
                if isempty(followingLineBreaks)
                    i4=numel(parentScriptCode);
                else
                    i4=lineBreaks(followingLineBreaks(1))-1;
                end

                string1=parentScriptCode(i1:i2-1);
                string2=parentScriptCode(i2:i3);
                string3=parentScriptCode(i3+1:i4);

                string1=strrep(string1,char(10),'<br/>');
                string2=strrep(string2,char(10),'<br/>');
                string3=strrep(string3,char(10),'<br/>');





                fragmentSpan=Advisor.Element('span','class','codefragment');
                fragmentSpan.addContent(string2);

                codeLine=Advisor.Element('span','class','code');
                codeLine.addContent(string1);
                codeLine.addContent(fragmentSpan);
                codeLine.addContent(string3);
            otherwise
                codeLine=Advisor.Text('?');
                lineNumber=this.formatLineNumber();
            end
        end

        function instanceInfo=getInstanceInfo(this)
            instanceInfo=this.m_InstanceInfo;
        end

        function functionName=getFunctionName(this)
            functionName=this.m_InstanceInfo.getFunctionName();
        end

        function functionType=getFunctionType(this)
            functionType=this.m_InstanceInfo.getFunctionType();
        end

        function scriptCode=getScriptCode(this)
            scriptCode=this.m_InstanceInfo.getScriptCode();
        end

    end

    methods(Access=private)

        function privateInitialize(this,inferenceReport)
            IR=inferenceReport.getIR();
            if~this.isCalledRecursively()
                irFunction=IR.Functions(this.m_IrFunctionId);
                callSites=irFunction.CallSites;
                if~isempty(callSites)
                    callArray=[...
                    [callSites.CalledFunctionID]',...
                    [callSites.TextStart]',...
                    [callSites.TextLength]'];
                    callArray=unique(callArray,'rows');
                    for i=1:size(callArray,1)
                        calledIrFunctionId=callArray(i,1);
                        calledIrFunction=IR.Functions(calledIrFunctionId);
                        if calledIrFunction.TextLength>0
                            calledIrScriptId=calledIrFunction.ScriptID;
                            if calledIrScriptId>0
                                calledIrScript=IR.Scripts(calledIrScriptId);
                                if calledIrScript.IsUserVisible
                                    callStart=callArray(i,2)+1;
                                    callEnd=callArray(i,2)+callArray(i,3);
                                    callTreeFunction=ModelAdvisor.Common.CsEml.CallTreeFunction(...
                                    this,inferenceReport,calledIrFunctionId,callStart,callEnd);
                                    this.addChild(callTreeFunction);
                                end
                            end
                        end
                    end
                end
            end
        end

        function result=isCalledRecursively(this)
            result=false;
            parent=this.getParent();
            while~isa(parent,'ModelAdvisor.Common.CsEml.CallTreeBlock')
                if this.m_IrFunctionId==parent.getIrFunctionId()
                    result=true;
                    break;
                else
                    parent=parent.getParent();
                end
            end
        end

        function span=formatLineNumber(~,lineNumber)
            span=Advisor.Element('span','class','line-number');
            if nargin==2
                lineNunmberString=sprintf('L%d:&nbsp;',lineNumber);
            else
                lineNunmberString='-';
            end
            span.setContent(lineNunmberString);
        end

        function html=formatFunctionType(~,functionType)
            html=Advisor.Element('span','class','function-type');
            switch functionType
            case CsEml.FunctionType.Function,text='f(x)';
            case CsEml.FunctionType.EntryAction,text='en';
            case CsEml.FunctionType.DuringAction,text='du';
            case CsEml.FunctionType.ExitAction,text='ex';
            case CsEml.FunctionType.Condition,text='[...]';
            case CsEml.FunctionType.TransitionAction,text='/{...}';
            case CsEml.FunctionType.ConditionAction,text='{...}';
            otherwise,text='?';
            end
            html.setContent(text);
        end

    end

    properties
        m_IrFunctionId;
        m_InstanceInfo;
        m_CallStart;
m_CallEnd

    end

end

