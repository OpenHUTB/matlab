




classdef PIRConstrainer<internal.ml2pir.constrainer.BaseConstrainer

    properties(Access=protected)

fcnList

        defaultMsgID='hdlcommon:matlab2dataflow:ML2PIRUnsupportedConstruct'
        typeMsgID='hdlcommon:matlab2dataflow:ML2PIRUnsupportedType'



        inNFPMode(1,1)logical


        FrameToSampleConversion(1,1)logical


        SamplesPerCycle(1,1)double


        SystemObjectCheckedClassNames string
    end

    methods(Access=public)

        function this=PIRConstrainer(fcnTypeInfo,exprMap,fcnInfoRegistry,constrainerArgs)
            this=this@internal.ml2pir.constrainer.BaseConstrainer(fcnTypeInfo,exprMap,fcnInfoRegistry);

            this.fcnList=this.getSupportedFunctionList();

            this.inNFPMode=constrainerArgs.IsNFP;
            this.FrameToSampleConversion=constrainerArgs.FrameToSampleConversion;
            this.SamplesPerCycle=constrainerArgs.SamplesPerCycle;
        end

    end

    methods(Access=protected)

        function isSupported=fcnSupported(this,fcnName)
            isSupported=ismember(fcnName,this.fcnList);
        end




        function preProcessPLUS(this,node)

            preProcessPLUS@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessMINUS(this,node)

            preProcessMINUS@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessMUL(this,node)

            preProcessMUL@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessDOTMUL(this,node)

            preProcessDOTMUL@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessDIV(this,node)

            preProcessDIV@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);

            this.checkDiv(node);
        end

        function preProcessDOTDIV(this,node)

            preProcessDOTDIV@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);

            this.checkDiv(node);
        end

        function preProcessEXP(this,node)

            preProcessEXP@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkMathTrigOps(node.tree2str,node);
        end

        function preProcessDOTEXP(this,node)

            preProcessDOTEXP@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkMathTrigOps(node.tree2str,node);
        end

        function preProcessLE(this,node)

            preProcessLE@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessLT(this,node)

            preProcessLT@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessGE(this,node)

            preProcessGE@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessGT(this,node)

            preProcessGT@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessEQ(this,node)

            preProcessEQ@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessNE(this,node)

            preProcessNE@internal.ml2pir.constrainer.BaseConstrainer(this,node);

            this.checkBinaryInputTypes(node);
        end

        function preProcessDOT(this,node)
            leftNodeType=this.getType(node.Left);

            if isSystemObject(leftNodeType)&&strcmp(node.Right.string,'step')
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:UnsupportedDotNotation');
            elseif~leftNodeType.isSystemObject&&...
                ~lowersysobj.isPIRSupportedObject(node.tree2str)


                preProcessDOT@internal.ml2pir.constrainer.BaseConstrainer(this,node);
            end
        end

        function checkSystemObject(this,node,instance)
            sysobjType=this.getType(node);
            if sysobjType.IsPIRBased
                this.checkSystemObjectUse(node,instance);
            elseif strcmpi(hdlfeature('SystemObjectML2PIR'),'off')&&~sysobjType.IsPIRBased


                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:UnsupportedAuthoredSystemObject',...
                sysobjType.ClassName);
            elseif~sysobjType.IsPIRBased

                className=sysobjType.ClassName;
                if~any(this.SystemObjectCheckedClassNames==className)
                    this.checkSystemObjectMetaClass(node,className);
                    this.SystemObjectCheckedClassNames(end+1)=className;
                end
                this.checkSystemObjectUse(node,instance);
            end
        end

    end

    methods(Access=protected)



        checkFunctionCall(this,node,calleeFcnInfo);
    end

    methods(Access=private)

        checkBinaryInputTypes(this,node);


        checkDiv(this,node);


        checkAbs(this,callee,node);


        checkComplexFunc(this,callee,node);


        checkCordicSinCos(this,callee,node);


        checkBitShift(this,callee,node);


        checkBitGet(this,callee,node);


        checkBitSet(this,node);


        checkBitRotate(this,callee,node);


        checkBitShiftRightLogical(this,node);



        checkMathTrigOps(this,callee,node);


        checkMinMax(this,callee,node)


        checkSumAndProd(this,node);


        checkTreeSumAndProd(this,node);


        checkSystemObjectMetaClass(this,node,className)


        checkSystemObjectUse(this,node,instance)


        checkHalfDoubleConversions(this,callee,node)


        checkIsEqual(this,callee,node)


        checkImfilter(this,node);
    end

    methods(Access=private)

        function whitelist=getSupportedFunctionList(~)


            persistent pSupportedList;

            if isempty(pSupportedList)

                txt=fileread(fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+internal','+ml2pir','+constrainer','function_screener_ml2pir.txt'));
                tList=strsplit(txt,newline);


                tList=regexprep(tList,'%.*$','');
                tList=strtrim(tList(cellfun(@(x)~isempty(x),tList)));

                if~isempty(tList)
                    pSupportedList=tList;
                else
                    pSupportedList={};
                end
            end

            whitelist=pSupportedList;
        end
    end
end



