classdef(Abstract)Source<handle






    properties
blockH
    end

    methods(Static)
        function[source,errStr]=getSource(modelH)
            source=[];
            errStr='';
            harnessName=get_param(modelH,'Name');
            sigeH=find_system(modelH,...
            'SearchDepth',1,...
            'LoadFullyIfNeeded','off',...
            'FollowLinks','off',...
            'LookUnderMasks','all',...
            'BlockType','SubSystem',...
            'MaskType','SignalEditor');

            sigbH=find_system(modelH,...
            'SearchDepth',1,...
            'LoadFullyIfNeeded','off',...
            'FollowLinks','off',...
            'LookUnderMasks','all',...
            'BlockType','SubSystem',...
            'PreSaveFcn','sigbuilder_block(''preSave'');');

            fo=Simulink.FindOptions('LookUnderMasks','none','SearchDepth',1,'MatchFilter',@Sldv.harnesssource.Source.validTestSequenceBlocks);
            testSeqH=Simulink.findBlocks(modelH,'sfblocktype','Test Sequence',fo);





            numSigEditorBlocks=length(sigeH);
            numSigBuilderBlocks=length(sigbH);
            numTestSeqBlocks=length(testSeqH);
            numTotalBlocksInHarness=numSigEditorBlocks+numSigBuilderBlocks+numTestSeqBlocks;

            if numTotalBlocksInHarness~=1
                errStr=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:MoreThanOneHarnessSourcePresent',harnessName));
                return;
            end

            if numTotalBlocksInHarness==0
                errStr=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:NoSupportedSource',harnessName));
                return;
            end

            if numSigEditorBlocks==1
                source=Sldv.harnesssource.SignalEditor(sigeH);
            elseif numSigBuilderBlocks==1
                source=Sldv.harnesssource.SignalBuilder(sigbH);
            else
                source=Sldv.harnesssource.TestSequence(testSeqH);
            end

        end

        function match=validTestSequenceBlocks(blk)


            match=false;
            if strcmpi(get_param(blk,'Name'),'Harness Inputs')||...
                strcmpi(get_param(blk,'Name'),'Inputs')
                match=true;
            end
        end
    end

    methods(Abstract)
        getNumberOfTestcases(obj);
        getNumberOfSignals(obj);
        merge(srcHarnessObj,destHarnessObj);
        getTimeAsCellArray(obj);
        getDataAsCellArray(obj);
        setActiveTestcase(obj);
        getActiveTestcase(obj);
        addTestcases(obj,sldvData,appendMode,usedSignals);
        getNamesOfTestcases(obj);
        getNamesOfSignals(obj);
        getSourceType(obj);
    end

    methods
        function obj=Source(blockH)
            if iscell(blockH)
                obj.blockH=blockH{1};
            else
                obj.blockH=blockH;
            end
        end
    end

    methods(Static)
        function TestCasePrefix=getTestCasePrefix(sldvMode)


            switch sldvMode
            case 'PropertyProving'
                TestCasePrefix='Counterexample';
            otherwise
                TestCasePrefix='TestCase';
            end
        end
    end
end
