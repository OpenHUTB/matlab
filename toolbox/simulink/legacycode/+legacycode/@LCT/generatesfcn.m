function h=generatesfcn(h)







    if nargin<1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct');
    end


    h=h(:);

    for ii=1:length(h)


        if legacycode.lct.util.feature('newImpl')
            try
                legacycode.lct.gen.SFunEmitter.emitFile(h(ii));
                continue
            catch Me

                lctErrIdRadix=legacycode.lct.spec.Common.LctErrIdRadix;

                if strncmp(lctErrIdRadix,Me.identifier,numel(lctErrIdRadix))


                    throwAsCaller(Me);
                else

                    rethrow(Me);
                end
            end
        end

        try


            lastwarn('');
            [infoStruct,h(ii)]=legacycode.util.lct_pGetFullInfoStructure(h(ii),'c');







            [warnMsg,warnId]=lastwarn;
            if strcmp(warnId,'Simulink:tools:LCTWarnFileConflict')
                throw(MException('Simulink:tools:LCTWarnFileConflict',warnMsg));
            end



            if infoStruct.Specs.Options.singleCPPMexFile&&...
                infoStruct.canUseSFcnCGIRAPI==false

                if~isempty(infoStruct.warningID)
                    MSLDiagnostic(['Simulink:tools:',infoStruct.warningID]).reportAsWarning;
                end


                infoStruct.Specs.Options.singleCPPMexFile=false;
            end





            infoStruct=iGetDynamicSizeInformation(infoStruct);

        catch ME
            rethrow(ME);
        end


        if infoStruct.isCPP==false&&...
            infoStruct.canUseSFcnCGIRAPI==false
            fext='.c';
        else
            fext='.cpp';
        end


        [fid,msg]=fopen([infoStruct.Specs.SFunctionName,fext],'w');
        if fid==-1
            DAStudio.error('Simulink:tools:LCTErrorCannotOpenFile',...
            infoStruct.Specs.SFunctionName,fext,['(',msg,')']);
        end


        closeFileObj=onCleanup(@()fclose(fid));


        h.writeSfcnMdlHeader(fid,infoStruct);


        h.writeSfcnMdlDefines(fid,infoStruct);


        h.writeSfcnMdlCheckParameters(fid,infoStruct);


        h.writeSfcnMdlInitializeSizes(fid,infoStruct);


        h.writeSfcnMdlInitializeSampleTimes(fid,infoStruct);


        h.writeSfcnMdlSetInputPortDimensionInfo(fid,infoStruct);


        h.writeSfcnMdlSetOutputPortDimensionInfo(fid,infoStruct);


        h.writeSfcnMdlSetDefaultPortDimensionInfo(fid,infoStruct);


        h.writeSfcnMdlWorkWidths(fid,infoStruct);


        h.writeSfcnMdlStart(fid,infoStruct);


        h.writeSfcnMdlInitializeConditions(fid,infoStruct);


        h.writeSfcnMdlOutputs(fid,infoStruct);


        h.writeSfcnMdlTerminate(fid,infoStruct);


        h.writeSfcnCGIRClass(fid,infoStruct);


        h.writeSfcnMdlTrailer(fid,infoStruct);


        delete(closeFileObj);


        if isempty(which('c_beautifier'))==0
            c_beautifier([infoStruct.Specs.SFunctionName,fext]);
        end

    end


    function infoStruct=iGetDynamicSizeInformation(infoStruct)








        inputDynSize=cell(1,infoStruct.Inputs.Num);
        inputHasDynSize=false;
        for ii=1:infoStruct.Inputs.Num

            thisData=infoStruct.Inputs.Input(ii);

            isDynSized=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisData);

            inputDynSize{ii}=isDynSized;

            inputHasDynSize=any(isDynSized==true)||inputHasDynSize;
        end


        outputDynSize=cell(1,infoStruct.Outputs.Num);
        outputHasDynSize=false;
        for ii=1:infoStruct.Outputs.Num
            thisData=infoStruct.Outputs.Output(ii);
            isDynSized=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisData);
            outputDynSize{ii}=isDynSized;
            outputHasDynSize=any(isDynSized==true)||outputHasDynSize;
        end


        dworkDynSize=cell(1,infoStruct.DWorks.Num);
        dworkHasDynSize=false;
        for ii=1:infoStruct.DWorks.Num
            thisData=infoStruct.DWorks.DWork(ii);
            isDynSized=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisData);
            dworkDynSize{ii}=isDynSized;
            dworkHasDynSize=any(isDynSized==true)||dworkHasDynSize;
        end

        infoStruct.DynamicSizeInfo.InputHasDynSize=inputHasDynSize;
        infoStruct.DynamicSizeInfo.InputDynSize=inputDynSize;
        infoStruct.DynamicSizeInfo.OutputHasDynSize=outputHasDynSize;
        infoStruct.DynamicSizeInfo.OutputDynSize=outputDynSize;
        infoStruct.DynamicSizeInfo.DWorkHasDynSize=dworkHasDynSize;
        infoStruct.DynamicSizeInfo.DWorkDynSize=dworkDynSize;


