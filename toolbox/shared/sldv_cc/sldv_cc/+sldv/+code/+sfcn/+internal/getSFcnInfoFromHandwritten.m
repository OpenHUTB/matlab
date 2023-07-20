function sldvInfo=getSFcnInfoFromHandwritten(workingDir,buildOpts)





    handwrittenInstrumenter=sldv.code.sfcn.internal.HandwrittenInstrumenter(workingDir,buildOpts);


    instrumentedFiles=handwrittenInstrumenter.instrument();

    language=getLanguageFromBuildOptions(buildOpts);
    sldvInfo=sldv.code.sfcn.internal.StaticSFcnInfoWriter(language);
    sldvInfo.OverridenFiles=instrumentedFiles;
    sldvInfo.KeepSFcnMain=true;

    sfcnInfo=handwrittenInstrumenter.SFcnInfo;
    idxMain=sfcnInfo.idxMain;

    sldvInfo.setSldvMainFile(buildOpts(idxMain(1)).Sources{idxMain(2)});


    sldvInfo.addVarDecl(sldvInfo.SimStructType,'S','SimStruct',1);
    sldvInfo.addVarDecl(sldvInfo.SimStructType,'tid','volatile int_T',2);


    addSimStructFunction(sldvInfo,'Output','mdlOutputs',true);
    addSimStructFunction(sldvInfo,'Terminate','mdlTerminate');

    if~isempty(sfcnInfo.mdlFcnInfo)
        if sfcnInfo.mdlFcnInfo.hasMdlDerivatives
            msg=message('sldv_sfcn:sldv_sfcn:UnsupportedMdlFunction','mdlDerivatives');
            throwAsCaller(MException('sldv:UnsupportedSFunction',...
            msg.getString()));
        end

        if sfcnInfo.mdlFcnInfo.hasMdlProjection
            msg=message('sldv_sfcn:sldv_sfcn:UnsupportedMdlFunction','mdlProjection');
            throwAsCaller(MException('sldv:UnsupportedSFunction',...
            msg.getString()));
        end

        if sfcnInfo.mdlFcnInfo.hasMdlZeroCrossings
            msg=message('sldv_sfcn:sldv_sfcn:UnsupportedMdlFunction','mdlZeroCrossings');
            throwAsCaller(MException('sldv:UnsupportedSFunction',...
            msg.getString()));
        end

        if sfcnInfo.mdlFcnInfo.hasMdlInitializeConditions
            addSimStructFunction(sldvInfo,'InitializeConditions','mdlInitializeConditions');
        end

        if sfcnInfo.hasMdlStart
            addSimStructFunction(sldvInfo,'Start','mdlStart');
        end

        if sfcnInfo.mdlFcnInfo.hasMdlUpdate
            addSimStructFunction(sldvInfo,'Update','mdlUpdate',true);
        end

        if sfcnInfo.mdlFcnInfo.hasMdlEnable
            addSimStructFunction(sldvInfo,'Enable','mdlEnable');
        end

        if sfcnInfo.mdlFcnInfo.hasMdlDisable
            addSimStructFunction(sldvInfo,'Disable','mdlDisable');
        end
    end



    function addSimStructFunction(sldvInfo,functionType,functionName,hasTid)



        if nargin<4
            hasTid=false;
        end
        sldvInfo.addFunctionSpec(functionType,functionName);
        sldvInfo.addFunctionArg(functionType,...
        sldvInfo.RhsParam,1,'S','SimStruct','pointer',false);
        if hasTid
            sldvInfo.addFunctionArg(functionType,...
            sldvInfo.RhsParam,2,'tid','int_T','direct',true);
        end


        function language=getLanguageFromBuildOptions(buildOpts)
            language='C';
            for bb=1:numel(buildOpts)
                if buildOpts(bb).ForceCxx
                    language='C++';
                    return
                end

                for ii=1:numel(buildOpts(bb).Sources)
                    if codeinstrum.internal.LCInstrumenter.isCxxFile(buildOpts(bb).Sources{ii})
                        language='C++';
                        return
                    end
                end
            end


