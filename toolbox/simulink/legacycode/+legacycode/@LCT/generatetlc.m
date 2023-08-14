function generatetlc(defs)









    if nargin<1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct');
    end


    defs=defs(:);

    for ii=1:length(defs)


        if legacycode.lct.util.feature('newImpl')
            try
                legacycode.lct.gen.TlcEmitter.emitFile(defs(ii));
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


            infoStruct=legacycode.util.lct_pGetFullInfoStructure(defs(ii),'tlc');

        catch ME
            rethrow(ME);
        end


        if infoStruct.Specs.Options.singleCPPMexFile
            if infoStruct.canUseSFcnCGIRAPI==true
                MSLDiagnostic('Simulink:tools:LCTSFcnCppCodeAPIWarningSkipTLC',...
                infoStruct.Specs.SFunctionName).reportAsWarning;

                continue
            else

                infoStruct.Specs.Options.singleCPPMexFile=false;
            end
        end


        [fid,msg]=fopen([infoStruct.Specs.SFunctionName,'.tlc'],'w');
        if fid==-1
            DAStudio.error('Simulink:tools:LCTErrorCannotOpenFile',...
            infoStruct.Specs.SFunctionName,'tlc',['(',msg,')']);
        end


        closeFileObj=onCleanup(@()fclose(fid));


        infoStruct.INDENT_SPACE='';


        defs(ii).writeTlcHeader(fid,infoStruct);


        defs(ii).writeTlcFcnGenerateUniqueFileName(fid,infoStruct);


        defs(ii).writeTlcBlockTypeSetup(fid,infoStruct);


        defs(ii).writeTlcBlockInstanceSetup(fid,infoStruct);


        defs(ii).writeTlcStart(fid,infoStruct);


        defs(ii).writeTlcInitializeConditions(fid,infoStruct);


        defs(ii).writeTlcOutputs(fid,infoStruct);


        defs(ii).writeTlcBlockOutputSignal(fid,infoStruct);


        defs(ii).writeTlcTerminate(fid,infoStruct);


        defs(ii).writeTlcTrailer(fid,infoStruct);


        delete(closeFileObj);

    end


