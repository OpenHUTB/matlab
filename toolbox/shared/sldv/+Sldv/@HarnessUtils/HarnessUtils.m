




classdef(Sealed=true)HarnessUtils

    methods(Access='private')
        function obj=HarnessUtils
        end
    end

    methods(Static,Access='private')
        [errStr,model,sldvData]=check_make_harness_args(model,sldvData)
        [errStr,sldvData,sldvDataFilePath,isLoggedSldvData,isDerivedSldvData]=...
        check_harness_data(modelH,sldvData,harnessopts)
        [time,data]=harness_data(testCase,inportUsage,sldvData,harnessOpts)
        [harnessH,sigbH,testSubsysH]=create_model_harness(objH,harnessFilePath,time,data,...
        groups,sldvData,opts,fundts,...
        reconsParams,posShift,outputPosShift,...
        fromMdlFlag,mode,harnessOpts,...
        existHarnMdlH,existSigbH)
        build_bus_hierarchy(subsysH,nameTree,isRootInportNonVirtual,isBusSelector,harnessOpts)
        harnessFilePath=genHarnessModelFilePath(modelH,opts,mode)
        systemTestFilePath=genSystemTestHarnessFilePath(modelH,opts,mode)
        status=has_unlicensed_stateflow(modelH)
        status=has_root_level_input_ports(modelH)
        [reconsParams,posShift,outputPosShift,warnmsg]=getReconstructionParams(model,sldvData,maxConstHandle)
        [sldvData,inportUsage,anyUnused]=updateInportUsage(sldvData,harnessOpts)
        sldvData=setBusDimensions(sldvData,modelH)
        isArrayOfBus=isArrayOfBus(sldvData);
    end

    methods(Static)
        testUnitBlock=extractInlineModel(modelH)
        status=isMdlRefHarnessEnabled(testcomp)
        [harnessFilePath,warnmsg]=make_model_harness(model,sldvData,harnessOpts,utilityName,maxConstHandle)
        [testFileName,warnmsg]=make_systemtest_harness(model,sldvDataFilePath,systemTestFilePath)
        [sigbH,errStr]=sigbuild_handle(modelH)
        status=isSldvGenHarness(modelH)
        pairs=getModelParamValuePairs(modelH)
        modelName=getGeneratedModel(modelH)
        harnessSource=getHarnessSource(testcomp)
        status=merge(destModelH,modelHs,initCmds,isNew,caller)
        [mdlH,index]=getModelWithLargestSignalSource(modelHs)
        match=findObsBlks(currBlk)
        setupMultiSimDesignStudy(harnessFilePath,harnessSourceObj);
    end

    methods(Static,Access='public')
        function harnessOpts=getHarnessOpts
            harnessOpts.harnessFilePath='';
            harnessOpts.modelRefHarness=true;
            harnessOpts.usedSignalsOnly=false;
            harnessOpts.harnessSource='Signal Editor';
        end

        function msg=isValidMdl(mdl)
            isMdl=false;
            msg=[];

            if ischar(mdl)&&any(mdl=='.')


                [~,mdl,~]=fileparts(mdl);
            end

            try
                isMdl=strcmp(get_param(mdl,'Type'),'block_diagram');
            catch
            end

            if~isMdl
                msg=message('Sldv:MAKEHARNESS:InvalidMdl');
            end
        end

        function msg=iscorrectHarnessOpts(harnessOpts)
            msg='';
            defaultHarnessOpts=Sldv.HarnessUtils.getHarnessOpts;
            defaultFields=fieldnames(defaultHarnessOpts);
            currentFields=fieldnames(harnessOpts);




            if~isempty(setdiff(defaultFields,currentFields))
                strtmp='';
                for idx=1:length(defaultFields)-1
                    strtmp=[strtmp,'%s, '];%#ok<AGROW>
                end
                strtmp=[strtmp,'and %s.'];
                paramNames=sprintf(strtmp,defaultFields{:});
                msg=message('Sldv:MAKEHARNESS:InvalidInputStruct',paramNames);
            end

            if(isempty(msg))

                extraHarnessOpts=Sldv.HarnessUtils.getExtraHarnessOpts;
                extraFields=fieldnames(extraHarnessOpts);
                allFields=[defaultFields',extraFields{:}];

                badFields=setdiff(currentFields,allFields);
                if~isempty(badFields)
                    strtmp='';
                    for idx=1:length(badFields)-1
                        strtmp=[strtmp,'%s, '];%#ok<AGROW>
                    end
                    strtmp=[strtmp,'and %s.'];
                    paramNames=sprintf(strtmp,badFields{:});
                    msg=message('Sldv:MAKEHARNESS:InvalidInputFields',paramNames);
                end
            end

            if(isempty(msg))
                if(~isempty(harnessOpts.harnessFilePath)&&...
                    ~ischar(harnessOpts.harnessFilePath))
                    msg=message('Sldv:MAKEHARNESS:InvalidInputFile');
                end
                if~((harnessOpts.modelRefHarness==true)||...
                    (harnessOpts.modelRefHarness==false))
                    msg=message('Sldv:MAKEHARNESS:InvalidInputLogical',msg,'MODELREFHARNESS');
                end
                if~((harnessOpts.usedSignalsOnly==true)||...
                    (harnessOpts.usedSignalsOnly==false))
                    msg=message('Sldv:MAKEHARNESS:InvalidInputLogical',msg,'USEDSIGNALSONLY');
                end
            end
        end

        function openMultiSimulationDesignStudy
            [isExist,baseDir,designStudyFileName]=Sldv.HarnessUtils.isMultiSimDesignStudyExist(gcs);

            if isExist
                uiopen(fullfile(baseDir,designStudyFileName),1);
            else
                warnId='Sldv:MAKEHARNESS:MissingMultiSimFile';
                warnMsg=getString(message('Sldv:MAKEHARNESS:MissingMultiSimFile',gcs,designStudyFileName));
                warning(warnId,warnMsg);
            end
        end
    end

    methods(Static,Hidden)
        function harnessOpts=getExtraHarnessOpts

            harnessOpts.logInputsAndOutputs=false;
            harnessOpts.createReshapeOutputsSubsystem=false;
            harnessOpts.useUnderscores=false;
            harnessOpts.noDocBlock=false;
            harnessOpts.visible=true;
            harnessOpts.ignoreEmptyData=false;
            harnessOpts.xilModelWrapperOnly=false;
        end

        function[isExist,baseDir,designStudyFileName]=isMultiSimDesignStudyExist(model)
            if~ischar(model)
                model=get_param(model,'Name');
            end

            [baseDir,harnessName,~]=fileparts(which(model));
            designStudyFileName=[harnessName,'_ds.mldatx'];
            designStudyFilePath=fullfile(baseDir,designStudyFileName);
            isExist=exist(designStudyFilePath,'file');
        end
    end
end
