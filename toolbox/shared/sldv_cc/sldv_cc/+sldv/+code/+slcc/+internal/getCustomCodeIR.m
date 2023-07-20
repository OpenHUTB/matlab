



function[ok,irInfo,translationLog,emitterDb,messages]=getCustomCodeIR(wrapperInfo)
    ok=false;
    irInfo=[];
    translationLog=[];
    emitterDb=[];
    messages=sldv.code.internal.CodeMessage.empty(0,1);
    try
        testComp=sldvprivate('sldvGetTestComponent');
        modelH=testComp.analysisInfo.designModelH;
        analyzedH=testComp.analysisInfo.analyzedModelH;

        if analyzedH~=modelH
            analyzedInfo=sldv.code.slcc.internal.getModelInfo(analyzedH);
        else
            analyzedInfo=[];
        end
        modelInfo=sldv.code.slcc.internal.getModelInfo(modelH);





        irChecksum=CGXE.Utils.md5({modelInfo.FullChecksum},...
        [modelInfo.SupportSldv]);

        hasCustomCodeWithoutSldvSupport=false;
        for ii=1:numel(wrapperInfo)
            irChecksum=CGXE.Utils.md5(irChecksum,...
            wrapperInfo(ii).WrapperText,...
            wrapperInfo(ii).CustomCodeVars);


            currentInfo=modelInfo(strcmp({modelInfo.SettingsChecksum},wrapperInfo(ii).Checksum));
            if numel(currentInfo)==1&&~currentInfo.SupportSldv
                hasCustomCodeWithoutSldvSupport=true;
            end
        end

        if hasCustomCodeWithoutSldvSupport
            msg=sldv.code.internal.CodeMessage('sldv_sfcn:sldv_slcc:customCodeWithoutSldvSupport');
            msg.Args={get_param(modelH,'Name')};
            messages(end+1)=msg;
        end

        irChecksum=cgxe('MD5AsString',irChecksum);
        hasCScript=any(strcmp({wrapperInfo.Checksum},'CScript'));
        hasCExpr=any(strcmp({wrapperInfo.Checksum},'CExpr'));

        if any([modelInfo.SupportSldv])||hasCScript||hasCExpr
            emitterDb=sldv.code.slcc.internal.EmitterDb();

            sldvOptions=testComp.activeSettings;
            loader=sldv.code.slcc.internal.CodeInfoLoader();
            dd=loader.openDb(modelH,sldvOptions);
            codeDb=dd.getDb();

            analyzer=sldv.code.slcc.CodeAnalyzer(irChecksum);

            options=sldv.code.internal.getAnalysisOptionsFromSldv(sldvOptions);
            analyzer.setAnalysisOptions(options);

            existingAnalyzer=codeDb.getAnalysisInfo(irChecksum,analyzer,'');

            if~builtin('isempty',existingAnalyzer)
                ok=true;

                emitterDb.populateModuleInfo(modelInfo);

                irInfo=existingAnalyzer.FullIR;
                translationLog=existingAnalyzer.getFullIrLog();
            else
                ok=analyzer.runSldvAnalysis(options,modelH,modelInfo,...
                emitterDb,wrapperInfo,analyzedInfo);
                if ok
                    codeDb.clearSameArchitecture(analyzer);
                    dd.addAnalysis(analyzer);

                    irInfo=analyzer.FullIR;
                    translationLog=analyzer.getFullIrLog();
                end
            end
        end
    catch Me
        ok=false;
        irInfo=[];
        translationLog=[];
        emitterDb=[];

        msg=sldv.code.internal.CodeMessage('sldv_sfcn:sldv_slcc:errorAnalyzingCustomCode');
        msg.Args={Me.message};
        messages(end+1)=msg;
    end



end

