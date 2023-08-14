



classdef(Hidden)SldvExportFcnSchedulerInfo<coder.internal.MTreeVisitor

    properties(Hidden,GetAccess=public,SetAccess=private)
Code
Tree
    end

    properties(Access=protected)
Status
NumFcns
IsInsideSchedulingIf
ScheduleInfo
    end

    methods(Hidden)




        function this=SldvExportFcnSchedulerInfo(code)
            this.Code=code;
            this.Tree=mtree(code);
        end




        function[status,scheduleInfo]=extract(this)

            this.Status=true;
            this.NumFcns=0;
            this.IsInsideSchedulingIf=false;
            this.ScheduleInfo=sldv.code.xil.internal.SldvExportFcnSchedulerInfo.defaultSchedulingInfo();


            this.visitNodeList(this.Tree.root,[]);


            status=this.Status;
            scheduleInfo=this.ScheduleInfo;
        end




        function out=visitFUNCTION(this,node,inp)
            this.handleFunctionNode(node);
            out=this.visitFUNCTION@coder.internal.MTreeVisitor(node,inp);
        end




        function out=visitSUBSCR(this,node,inp)


            stmtNode=Parent(node);
            exprNode=Left(node);
            idxNode=Right(node);
            if iskind(exprNode,'ID')&&strcmp(string(exprNode),this.ScheduleInfo.FcnTriggerPortVarName)&&...
                iskind(idxNode,'INT')&&...
                ~isnull(stmtNode)&&iskind(stmtNode,'EQUALS')

                lhsNode=Left(stmtNode);
                if~isnull(lhsNode)&&iskind(lhsNode,'ID')


                    this.ScheduleInfo.CallInfo(end+1)=sldv.code.xil.internal.SldvExportFcnSchedulerInfo.defaultCallInfo(...
                    string(lhsNode),'',str2double(string(idxNode)));
                end
            end


            out=this.visitSUBSCR@coder.internal.MTreeVisitor(node,inp);
        end




        function out=visitIF(this,node,inp)

            if~isempty(this.ScheduleInfo.CallInfo)

                ifCondNode=Left(Arg(node));
                if iskind(ifCondNode,'ID')&&...
                    strcmp(string(ifCondNode),this.ScheduleInfo.CallInfo(end).VarName)
                    this.IsInsideSchedulingIf=true;
                end
            end


            out=this.visitIF@coder.internal.MTreeVisitor(node,inp);


            this.IsInsideSchedulingIf=false;
        end




        function out=visitCALL(this,node,inp)

            if this.IsInsideSchedulingIf
                this.ScheduleInfo.CallInfo(end).FunName=string(Left(node));
            end


            out=this.visitCALL@coder.internal.MTreeVisitor(node,inp);
        end
    end

    methods(Access=protected)



        function handleFunctionNode(this,node)

            if this.NumFcns>0
                this.Status=false;
                return
            end
            this.NumFcns=this.NumFcns+1;



            lastArgName='';
            inArg=Ins(node);
            while~isnull(inArg)
                if iskind(inArg,'ID')
                    lastArgName=string(inArg);
                else
                    lastArgName='';
                end
                inArg=Next(inArg);
            end
            if isempty(lastArgName)
                this.Status=false;
            end
            this.ScheduleInfo.FcnTriggerPortVarName=lastArgName;
        end
    end

    methods(Static,Hidden)
        function out=defaultSchedulingInfo()
            out=struct(...
            'FcnTriggerPortVarName','',...
            'CallInfo',repmat(sldv.code.xil.internal.SldvExportFcnSchedulerInfo.defaultCallInfo(),[1,0])...
            );
        end
        function out=defaultCallInfo(varName,funName,index)
            if nargin<3
                index=-1;
            end
            if nargin<2
                funName='';
            end
            if nargin<1
                varName='';
            end
            out=struct(...
            'VarName',varName,...
            'FunName',funName,...
            'Index',index);
        end
    end
end
