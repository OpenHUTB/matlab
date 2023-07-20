







classdef Float2FixedConstrainer<coder.internal.MTreeVisitor

    properties(Access=private)
        functionMTree;
        functionName;
        scriptPath;
        messages;


globalsSupported
doubleToSingle

isMLFBApply
mlfbSID

functionTypeInfo

compiledExprInfoMap

unsupportedFcns



checkForOtherUnSupportFcns
    end

    properties(Constant)
        F2FUNSUPPORTEDFCNMSGID='Coder:FXPCONV:unsupportedFunc';
        D2SUNSUPPORTEDFCNMSGID='Coder:FXPCONV:unsupportedFunc_DTS';
    end


    methods
        function setmlfbSID(this,val)
            this.mlfbSID=val;
        end

        function val=getmlfbSID(this)
            val=this.mlfbSID;
        end

        function setGlobalsSupported(this,val)
            this.globalsSupported=val;
        end

        function setCompiledExprInfo(this,val)
            this.compiledExprInfoMap=val;
        end
    end

    methods

        function this=Float2FixedConstrainer(fMTree,fcnTypeInfo,scriptPath,doubleToSingle,checkOtherUnSupportFcns,mlfbSID)
            if nargin<4
                doubleToSingle=false;
            end
            if nargin<5
                checkOtherUnSupportFcns=false;
            end
            if nargin<6
                mlfbSID=[];
            end

            this.functionMTree=fMTree;
            this.functionName=fcnTypeInfo.functionName;
            this.scriptPath=scriptPath;
            this.messages=coder.internal.lib.Message.empty();

            this.globalsSupported=true;
            this.doubleToSingle=doubleToSingle;
            this.mlfbSID=mlfbSID;
            this.isMLFBApply=~isempty(mlfbSID);
            this.functionTypeInfo=fcnTypeInfo;

            this.treeAttributes=fcnTypeInfo.treeAttributes;

            this.compiledExprInfoMap=coder.internal.lib.Map();

            this.unsupportedFcns={};
            this.checkForOtherUnSupportFcns=checkOtherUnSupportFcns;
        end




        function[messages,unSupportFcnList]=constrain(this)
            data=[];

            if strcmp(this.functionMTree.kind,'FUNCTION')

                if this.functionTypeInfo.isDefinedInAClass()&&this.isAMATLABOperator(this.functionName)
                    if this.doubleToSingle
                        errID='Coder:FXPCONV:DTS_MATLABOperatorInAClass';
                    else
                        errID='Coder:FXPCONV:MATLABOperatorInAClass';
                    end
                    fcnNode=this.functionMTree;
                    this.addMessage(message(errID,this.functionName)...
                    ,fcnNode.leftposition...
                    ,length(fcnNode.Fname)...
                    ,coder.internal.lib.Message.ERR);
                end


                this.checkForNestedFunctions();
            end
            this.visit(this.functionMTree,data);

            messages=this.messages;
            unSupportFcnList=this.unsupportedFcns;
        end

        function output=visit(this,node,input)
            this.fillMxLocationInfo(node);
            output=visit@coder.internal.MTreeVisitor(this,node,input);
        end


        function output=visitEQUALS(this,assignNode,input)
            lhs=assignNode.Left;
            this.visit(lhs,input);

            rhs=assignNode.Right;
            output=this.visit(rhs,input);
        end

        function output=visitCALL(this,callNode,input)
            if strcmp(callNode.Left.kind,'ID')





                callee=string(callNode.Left);
                calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
                if isempty(calleeFcnInfo)

                    switch callee
                    case 'load'
                        if this.doubleToSingle
                            errID='Coder:FXPCONV:DTS_unsupportedLoadFcn';
                        else
                            errID='Coder:FXPCONV:unsupportedLoadFcn';
                        end
                        pos=callNode.leftposition;
                        this.addMessage(message(errID)...
                        ,pos...
                        ,length(callee)...
                        ,coder.internal.lib.Message.ERR);
                        this.unsupportedFcns{end+1}={callee,pos};

                    case{'fopen','fclose','fprintf','fseek','ftell','fwrite'}
                        if this.doubleToSingle
                            errID=coder.internal.Float2FixedConstrainer.D2SUNSUPPORTEDFCNMSGID;
                        else
                            errID=coder.internal.Float2FixedConstrainer.F2FUNSUPPORTEDFCNMSGID;
                        end
                        pos=callNode.leftposition;
                        this.addMessage(message(errID,'',callee)...
                        ,pos...
                        ,length(callee)...
                        ,coder.internal.lib.Message.ERR);
                        this.unsupportedFcns{end+1}={callee,pos};

                    otherwise
                        if this.isMLFBApply
                            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
                            isUserWrittenFcn=~isempty(calleeFcnInfo);



                            if~isUserWrittenFcn


                                simulinkFcns=find_system(bdroot(this.mlfbSID),...
                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                'IsSimulinkFunction','on',...
                                'FunctionName',callee);
                                if length(simulinkFcns)>0 %#ok<ISMT>
                                    if this.doubleToSingle
                                        msgID='Coder:FXPCONV:MLFB_SimulinkFunctionNotSupported_DTS';
                                    else
                                        msgID='Coder:FXPCONV:MLFB_SimulinkFunctionNotSupported';
                                    end
                                    this.addMessage(message(msgID,callee)...
                                    ,callNode.Left.leftposition...
                                    ,length(callee)...
                                    ,coder.internal.lib.Message.ERR);
                                end
                            end
                        end
                        if this.checkForOtherUnSupportFcns
                            this.checkForOtherUnsupportedFcns(callee,callNode.Left,length(callee));
                        end
                    end
                end

                this.visit(callNode.Left,input);
            end

            output=this.visitNodeList(callNode.Right,input);
        end


        function output=visitARGUMENTS(this,argNode,~)
            output=[];
            if this.doubleToSingle
                errID='Coder:FXPCONV:unsupportedFcnArgumentBlock_DTS';
            else
                errID='Coder:FXPCONV:unsupportedFcnArgumentBlock';
            end
            this.addMessage(message(errID,['',this.functionName,''])...
            ,argNode.leftposition...
            ,length(argNode.smart_tree2str)...
            ,coder.internal.lib.Message.ERR);
        end


        function output=visitAT(this,atNode,~)
            output=[];


            isFirstArgOfBsxfun=atNode.Parent.iskind('CALL')&&strcmp(string(atNode.Parent.Left),'bsxfun');

            if~isFirstArgOfBsxfun
                if this.doubleToSingle
                    this.addMessage(message('Coder:FXPCONV:unsupportedFcnHndl_DTS',['',atNode.tree2str(),''])...
                    ,atNode.leftposition...
                    ,length(atNode.smart_tree2str)...
                    ,coder.internal.lib.Message.ERR);
                else
                    this.addMessage(message('Coder:FXPCONV:unsupportedFcnHndl',['',atNode.tree2str(),''])...
                    ,atNode.leftposition...
                    ,length(atNode.smart_tree2str)...
                    ,coder.internal.lib.Message.ERR);
                end
            end
        end


        function output=visitANON(this,node,~)
            output=[];
            if this.doubleToSingle
                this.addMessage(message('Coder:FXPCONV:unsupportedAnonFcn_DTS',['',node.tree2str(),''])...
                ,node.leftposition...
                ,length(node.smart_tree2str)...
                ,coder.internal.lib.Message.ERR);
            else
                this.addMessage(message('Coder:FXPCONV:unsupportedAnonFcn',['',node.tree2str(),''])...
                ,node.leftposition...
                ,length(node.smart_tree2str)...
                ,coder.internal.lib.Message.ERR);
            end
        end


        function output=visitPARFOR(this,node,~)
            output=[];
            if this.doubleToSingle
                this.addMessage(message('Coder:FXPCONV:F2FPARFOR_DTS')...
                ,node.leftposition...
                ,length(node.kind)...
                ,coder.internal.lib.Message.ERR);
            else
                this.addMessage(message('Coder:FXPCONV:F2FPARFOR')...
                ,node.leftposition...
                ,length(node.kind)...
                ,coder.internal.lib.Message.ERR);
            end
        end


        function output=visitGLOBAL(this,globalNode,~)
            output=[];
            if~this.globalsSupported
                if this.isMLFBApply
                    if this.doubleToSingle
                        msgID='Coder:FXPCONV:F2FGLOBALINMLFB_DTS';
                    else
                        msgID='Coder:FXPCONV:F2FGLOBALINMLFB';
                    end
                else
                    msgID='Coder:FXPCONV:F2FGLOBALINHDL';
                end

                this.addMessage(message(msgID)...
                ,globalNode.leftposition...
                ,length(globalNode.kind)...
                ,coder.internal.lib.Message.ERR);
            end
        end

        function output=visitID(this,idNode,~)
            output=[];

            varName=idNode.string;

            if strcmp(varName,'end')
                return;
            end

            varName=idNode.string;

            if~this.doubleToSingle&&strcmp(varName,coder.internal.translator.Phase.FIMATHFCNNAME)
                this.addMessage(message('Coder:FXPCONV:F2F_ReservedNameUsage',coder.internal.translator.Phase.FIMATHFCNNAME)...
                ,idNode.leftposition...
                ,length(varName)...
                ,coder.internal.lib.Message.ERR);
            end





            switch(varName)
            case 'Inf'
                if this.doubleToSingle

                else
                    this.addMessage(message('Coder:FXPCONV:F2FINF')...
                    ,idNode.leftposition...
                    ,length(varName)...
                    ,coder.internal.lib.Message.ERR);
                end
            end

            if length(varName)==namelengthmax&&strlength(this.functionTypeInfo.scriptText)>idNode.rightposition
                nextChar=this.functionTypeInfo.scriptText(idNode.rightposition+1);
                if isvarname(['a',nextChar])
                    this.addMessage(message('Coder:FXPCONV:F2F_LongName',varName,namelengthmax)...
                    ,idNode.leftposition...
                    ,length(varName)...
                    ,coder.internal.lib.Message.ERR);
                end
            end
        end

        function output=visitSUBSCR(this,subScrNode,input)
            output=[];
            if subScrNode.Left.iskind('DOT')&&...
                subScrNode.Left.Left.iskind('ID')&&...
                strcmp(subScrNode.Left.Left.string,'coder')&&...
                subScrNode.Left.Right.iskind('FIELD')

                fieldNode=subScrNode.Left.Right;
                coderNode=subScrNode.Left.Left;
                switch fieldNode.string
                case 'parallel'
                    if this.doubleToSingle
                        this.addMessage(message('Coder:FXPCONV:F2FCODERDOTPARALLEL_DTS')...
                        ,coderNode.leftposition...
                        ,length('coder.parallel')...
                        ,coder.internal.lib.Message.ERR);
                    else
                        this.addMessage(message('Coder:FXPCONV:F2FCODERDOTPARALLEL')...
                        ,coderNode.leftposition...
                        ,length('coder.parallel')...
                        ,coder.internal.lib.Message.ERR);
                    end

                case 'cstructname'
                    if this.doubleToSingle
                        this.addMessage(message('Coder:FXPCONV:F2FCODERCSTRUCTNAME_DTS')...
                        ,coderNode.leftposition...
                        ,length('coder.cstructname')...
                        ,coder.internal.lib.Message.ERR);
                    else
                        this.addMessage(message('Coder:FXPCONV:F2FCODERCSTRUCTNAME')...
                        ,coderNode.leftposition...
                        ,length('coder.cstructname')...
                        ,coder.internal.lib.Message.ERR);
                    end
                end
            end

            vector=subScrNode.Left;
            this.visit(vector,input);

            index=subScrNode.Right;
            this.visitNodeList(index,input);
        end



        function output=visitBINEXPR(this,node,input)
            output=visitBINEXPR@coder.internal.MTreeVisitor(this,node,input);
            switch node.kind
            case 'LDIV'
                this.handleLDIV(node)
            otherwise

            end
        end


        function output=visitDCALL(this,node,~)
            output=[];
            if this.doubleToSingle
                this.addMessage(message('Coder:FXPCONV:unsupportedCommandSyntax_DTS')...
                ,node.leftposition...
                ,(node.rightposition-node.leftposition+1)...
                ,coder.internal.lib.Message.ERR);
            else
                this.addMessage(message('Coder:FXPCONV:unsupportedCommandSyntax')...
                ,node.leftposition...
                ,(node.rightposition-node.leftposition+1)...
                ,coder.internal.lib.Message.ERR);
            end
        end


        function output=visitDOTLP(this,node,~)
            output=[];
            if~strcmp(node.Right.kind,'CHARVECTOR')




                if this.doubleToSingle
                    errID='Coder:FXPCONV:UnsupportedDOTLP_DTS';
                else
                    errID='Coder:FXPCONV:UnsupportedDOTLP';
                end
                this.addMessage(message(errID)...
                ,node.leftposition...
                ,(node.rightposition-node.leftposition+1)...
                ,coder.internal.lib.Message.ERR);
            end
        end

        function output=visitDOT(this,node,in)
            output=this.visit(node.Left,in);

            fieldName=node.Right.string;
            if length(fieldName)==namelengthmax&&strlength(this.functionTypeInfo.scriptText)>node.Right.rightposition
                nextChar=this.functionTypeInfo.scriptText(node.Right.rightposition+1);
                if isvarname(['a',nextChar])
                    this.addMessage(message('Coder:FXPCONV:F2F_LongName',fieldName,namelengthmax)...
                    ,node.Right.leftposition...
                    ,length(fieldName)...
                    ,coder.internal.lib.Message.ERR);
                end
            end
        end

    end

    properties(Constant)
        MATLABOPERATORFUNCTIONS={'plus','minus','uminus','uplus'...
        ,'times','mtimes'...
        ,'rdivide','ldivide','mrdivide','mldivide'...
        ,'power','mpower'...
        ,'lt','gt','le','ge','ne','eq'...
        ,'and','or','not','colon'...
        ,'ctranspose','transpose'...
        ,'horzcat','vertcat'...
        ,'subsref','subsasgn','subsindex'};
    end

    methods(Access=private)

        function fillMxLocationInfo(this,node)
            pos=num2str(node.position);

            if this.compiledExprInfoMap.isKey(pos)
                compiledMxlocInfo=this.compiledExprInfoMap(pos);
                this.treeAttributes(node).CompiledMxLocInfo=compiledMxlocInfo;
            end
        end

        function addMessage(this,messageObj,leftPos,len,msgType)
            assert(coder.internal.lib.Message.isValidMessgeType(msgType));
            this.messages(end+1)=this.getMessage(messageObj,leftPos,len,msgType);
        end

        function[msg]=getMessage(this,messageObj,leftPos,len,msgType)


            msg=coder.internal.Float2FixedConstrainer...
            .BuildMessage(this.functionName...
            ,this.functionTypeInfo.specializationName...
            ,this.scriptPath...
            ,messageObj,leftPos,len,msgType);
        end

        function res=isAMATLABOperator(~,fcnName)
            res=any(strcmp(fcnName,coder.internal.Float2FixedConstrainer.MATLABOPERATORFUNCTIONS));
        end

        function checkForNestedFunctions(this)
            fcnNodes=this.functionMTree.subtree.mtfind('Kind','FUNCTION');
            indices=fcnNodes.indices;
            for ii=2:length(indices)
                idx=indices(ii);
                fcnNode=fcnNodes.select(idx);
                fcnN=string(fcnNode.Fname);
                if this.doubleToSingle
                    errID='Coder:FXPCONV:DTS_NestedFcnsNotSupported';
                else
                    errID='Coder:FXPCONV:NestedFcnsNotSupported';
                end
                this.addMessage(message(errID,fcnN)...
                ,fcnNode.Fname.leftposition...
                ,length(fcnN)...
                ,coder.internal.lib.Message.ERR);
            end
        end



        function output=handleLDIV(this,node)

            nodeTextLen=1;
            this.checkForOtherUnsupportedFcns('mldivide',node,nodeTextLen);
            output=[];
        end





        function checkForOtherUnsupportedFcns(this,fcnName,node,textLength)
            isUnSupportedFcn=coder.internal.Float2FixedConstrainer.isUnsupportedFunction(fcnName,this.doubleToSingle);
            if isUnSupportedFcn
                if this.doubleToSingle
                    errID=coder.internal.Float2FixedConstrainer.D2SUNSUPPORTEDFCNMSGID;
                else
                    errID=coder.internal.Float2FixedConstrainer.F2FUNSUPPORTEDFCNMSGID;
                end
                pos=node.leftposition;
                this.addMessage(message(errID,'',fcnName)...
                ,pos...
                ,textLength...
                ,coder.internal.lib.Message.WARN);
                this.unsupportedFcns{end+1}={fcnName,pos};
            end
        end

    end

    methods(Static)

        function isUnSupported=isUnsupportedFunction(fName,isDoubleToSingle)
            if isDoubleToSingle
                blackList={'load'};
            else
                blackList=coder.internal.getFiBlackListFunctions();
            end
            switch fName
            case blackList,isUnSupported=true;
            otherwise,isUnSupported=false;
            end
        end

        function[msg]=BuildMessage(functionName,fcnSplName,scriptPath,messageObj,leftPos,len,msgType)

            msg=coder.internal.lib.Message();
            msg.functionName=functionName;%#ok<*AGROW>
            msg.specializationName=fcnSplName;%#ok<*AGROW>
            msg.file=scriptPath;
            msg.type=msgType;
            msg.position=leftPos-1;
            msg.length=len;
            msg.text=messageObj.getString();
            msg.id=messageObj.Identifier;
            msg.params=messageObj.Arguments;
        end
    end
end




