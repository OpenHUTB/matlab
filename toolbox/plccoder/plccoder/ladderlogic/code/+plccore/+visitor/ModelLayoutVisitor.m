classdef ModelLayoutVisitor<plccore.visitor.AbstractVisitor



    properties(Constant)
        StartXOffset=40
        StartYOffset=40
        JunctionWidth=20
        JunctionHeight=20
        JSRBlockWidth=50
        JSRBlockHeight=50
        JMPLBLBlockWidth=75
        JMPLBLBlockHeight=50
        UnknownBlockWidth=100
        UnknownBlockHeight=150
        ExprBlockWidth=100
        SinglePortHeight=40;
        PortHeightPadding=60;
        BaseHeight=50;
    end

    properties(Access=protected)
Emitter
X0
Y0
    end

    methods
        function obj=ModelLayoutVisitor(mdl_emitter,x0,y0)
            obj.Kind='ModelLayoutVisitor';
            obj.Emitter=mdl_emitter;
            obj.X0=x0;
            obj.Y0=y0;
            obj.showDebugMsg;
        end

        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            import plccore.visitor.*;
            ret=[];
            host.setTag(struct('X0',obj.X0,'Y0',obj.Y0,'Width',0,'Height',0));
            width=0;
            height=0;
            rungs=host.rungs;
            input=host.tag;
            total_count=length(rungs);
            for i=1:total_count
                if obj.debug
                    fprintf('--->Rung Layout: #%d of %d\n',i,total_count);
                end
                rungs{i}.accept(obj,input);
                width=max(width,rungs{i}.tag.Width);
                height=height+rungs{i}.tag.Height+ModelLayoutVisitor.StartYOffset;
                input.Y0=input.Y0+rungs{i}.tag.Height+ModelLayoutVisitor.StartYOffset;
            end
            tag=host.tag;
            tag.Width=width;
            tag.Height=height;
            host.setTag(tag);
        end

        function ret=visitLadderRung(obj,host,input)
            import plccore.visitor.*;
            ret=[];
            host.setTag(input);
            width=0;
            height=0;
            rungops=host.rungOps;
            for i=1:length(rungops)
                rungops{i}.accept(obj,input);
                width=width+rungops{i}.tag.Width+ModelLayoutVisitor.StartXOffset;
                height=max(max(height,rungops{i}.tag.Height),ModelLayoutVisitor.JunctionHeight);
                input.X0=input.X0+rungops{i}.tag.Width+ModelLayoutVisitor.StartXOffset;
            end
            tag=host.tag;
            tag.Width=width;
            tag.Height=height;
            host.setTag(tag);
        end


        function ret=visitRungOpAtom(obj,host,input)
            import plccore.visitor.*;
            ret=[];
            tag=input;

            if ismember(host.instr.name,{'TON','TOF','RTO','CTU','CTD'})
                tag=obj.processTimerCounterOpLayout(host,tag);
                host.setTag(tag);
                return;
            end

            if isa(host.instr,'plccore.ladder.JSRInstr')
                width=ModelLayoutVisitor.JSRBlockWidth;
                height=ModelLayoutVisitor.JSRBlockHeight;
            elseif isa(host.instr,'plccore.ladder.JMPInstr')||isa(host.instr,'plccore.ladder.LBLInstr')
                width=ModelLayoutVisitor.JMPLBLBlockWidth;
                height=ModelLayoutVisitor.JMPLBLBlockHeight;
            elseif isa(host.instr,'plccore.ladder.UnknownInstr')
                width=ModelLayoutVisitor.UnknownBlockWidth;
                height=ModelLayoutVisitor.UnknownBlockHeight;
            else
                instr_blk=host.instr.blockPath;
                [width,height]=ModelEmitter.blockSize(instr_blk);
            end

            if~ismember(host.instr.name,{'XIC','XIO','OTE','OTL','OTU','JSR','JMP','LBL','ONS','RES','CLR','UnknownInstr'})
                argStruct=host.instr.getInstrTypeStruct;
                if~isempty(argStruct)

                    numInput=length(argStruct.inputIndices);
                    numOutput=length(argStruct.outputIndices);
                    numInOut=length(argStruct.inOutIndices);
                else
                    numInput=host.instr.getNumInput;
                    numOutput=host.instr.getNumOutput;
                    numInOut=0;
                end

                if numInput+numInOut>0&&...
                    ~ismember(host.instr.name,{'OSR','OSF'})
                    width=width+obj.ExprBlockWidth;
                end
                if numOutput+numInOut>0
                    width=width+obj.ExprBlockWidth;
                end
            end

            tag.Width=width;
            tag.Height=height;
            host.setTag(tag);
        end

        function ret=visitRungOpTimer(obj,host,input)%#ok<INUSD>
            ret=[];
            assert(false,'Error: invalid timer ir');
        end

        function ret=visitRungOpFBCall(obj,host,input)
            import plccore.visitor.*;
            ret=[];
            call_blk=obj.Emitter.getPOUBlock(host.pou);
            [width,height]=ModelEmitter.blockSize(call_blk);
            tag=input;

            argList=host.pou.argList;
            numInput=0;
            numOutput=0;
            numInOut=0;

            for ii=1:length(argList)
                host.pou.inputScope.getSymbolNames;

                if any(contains(host.pou.inputScope.getSymbolNames,argList(ii)))
                    numInput=numInput+1;
                elseif any(contains(host.pou.outputScope.getSymbolNames,argList(ii)))
                    numOutput=numOutput+1;
                elseif any(contains(host.pou.inOutScope.getSymbolNames,argList(ii)))
                    numInOut=numInOut+1;
                end
            end

            tag.numInputPorts=numInput+numInOut;
            tag.numOutputPorts=numOutput+numInOut;

            if tag.numInputPorts>0
                width=width+obj.ExprBlockWidth;
            end
            if tag.numOutputPorts>0
                width=width+obj.ExprBlockWidth;
            end

            numPorts=max(tag.numOutputPorts,tag.numInputPorts);

            if numPorts>1
                height=height+obj.PortHeightPadding+obj.SinglePortHeight*(numPorts-1);
            end

            tag.Width=width;
            tag.Height=height;
            host.setTag(tag);
        end

        function ret=visitRungOpPar(obj,host,input)
            import plccore.visitor.*;
            ret=[];
            host.setTag(input);
            width=0;
            height=0;
            rungops=host.rungOps;
            assert(length(rungops)>1);
            for i=1:length(rungops)
                rungops{i}.accept(obj,input);
                width=max(width,rungops{i}.tag.Width);
                height=height+rungops{i}.tag.Height+ModelLayoutVisitor.StartYOffset;
                input.Y0=input.Y0+rungops{i}.tag.Height+ModelLayoutVisitor.StartYOffset;
            end
            tag=host.tag;
            tag.Width=width+ModelLayoutVisitor.StartXOffset+ModelLayoutVisitor.JunctionWidth;
            tag.Height=height;
            host.setTag(tag);
        end

        function ret=visitRungOpSeq(obj,host,input)

            ret=obj.visitLadderRung(host,input);
        end
    end

    methods(Access=private)
        function layout_tag=processTimerCounterOpLayout(obj,rung_op,layout_tag)%#ok<INUSL>
            import plccore.visitor.*;
            instr_blk=rung_op.instr.blockPath;
            [width,height]=ModelEmitter.blockSize(instr_blk);
            layout_tag.Width=width;
            layout_tag.Height=height;
        end
    end
end



