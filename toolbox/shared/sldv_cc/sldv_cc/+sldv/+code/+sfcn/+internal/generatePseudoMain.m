function[mainFile,fcnInfo]=generatePseudoMain(wrappersInfo,language,tmpDir,options)





    if nargin<4
        options=struct();
    end

    if isfield(options,'CoderFunctions')
        coderFunctions=options.CoderFunctions;
    else
        coderFunctions=false;
    end

    openMode='wt';

    if isfield(options,'AppendToFile')
        openMode='at';
        mainFile=options.AppendToFile;
        mainFilePath=options.AppendToFile;
    else
        if strcmpi(language,'c')
            mainFile='psmain.c';
        else
            mainFile='psmain.cpp';
        end
        mainFilePath=fullfile(tmpDir,mainFile);
    end

    if isfield(options,'MainFcn')
        mainFcn=options.MainFcn;
    else
        mainFcn='main';
    end

    fcnInfo=struct();

    writer=sldv.code.internal.CWriter(mainFilePath,openMode);


    fcnNames={'PsInit','ExtraInit','Start','Enable','InitializeConditions',...
    'Terminate','Enable','Disable','PsInputs','Update','Output'};
    initFcnNames={'PsInit','ExtraInit','Start','InitializeConditions'};
    termFcnNames={'Terminate'};

    writer.defineExternC('__TMW_SLDV_EXTERN');

    for wIndex=1:numel(wrappersInfo)
        w=wrappersInfo(wIndex);
        for fIndex=1:numel(fcnNames)
            fName=fcnNames{fIndex};
            if~isempty(w.(fName))
                writer.print('__TMW_SLDV_EXTERN void %s(void);\n',w.(fName));
            end
        end
    end

    if coderFunctions
        fcnInfo=generateCoderFunctions(writer,wrappersInfo,initFcnNames,termFcnNames,options);
    else
        generateMain(writer,wrappersInfo,initFcnNames,termFcnNames,mainFcn);
    end


    function generateMain(writer,wrappersInfo,initFcnNames,termFcnNames,mainFcnName)

        writer.beginBlock('\n\nvoid %s(void) {',mainFcnName);
        writer.print('\nvolatile short loop = 1;');
        hasEnable=generateEnabledDecl(writer,wrappersInfo,'');
        generateFcnBody(writer,wrappersInfo,initFcnNames);
        writer.beginBlock('\nwhile(loop > 0) {');
        generateStepBody(writer,wrappersInfo,'',hasEnable);
        writer.endBlock('\n}\n\n');
        generateFcnBody(writer,wrappersInfo,termFcnNames);
        writer.endBlock('}\n\n');


        function fcnInfo=generateCoderFunctions(writer,wrappersInfo,initFcnNames,termFcnNames,options)
            if isfield(options,'VarRadix')
                varPrefix=options.VarRadix;
            else
                varPrefix='';
            end
            if isfield(options,'FcnRadix')
                fcnPrefix=options.FcnRadix;
            else
                fcnPrefix='';
            end

            fcnInfo.StepFcn=[fcnPrefix,'_step'];
            fcnInfo.InitFcn='';
            fcnInfo.TermFcn='';

            hasEnable=generateEnabledDecl(writer,wrappersInfo,varPrefix);

            hasInit=getHasFcn(wrappersInfo,initFcnNames);
            if hasInit
                fcnInfo.InitFcn=[fcnPrefix,'_init'];

                writer.beginBlock('\nvoid %s(void) {',fcnInfo.InitFcn);
                generateFcnBody(writer,wrappersInfo,initFcnNames);
                writer.endBlock('\n}\n\n');
            end

            writer.beginBlock('\nvoid %s(void) {',fcnInfo.StepFcn);
            generateStepBody(writer,wrappersInfo,varPrefix,hasEnable);
            writer.endBlock('\n}\n');

            hasTerm=getHasFcn(wrappersInfo,termFcnNames);
            if hasTerm
                fcnInfo.TermFcn=[fcnPrefix,'_term'];

                writer.beginBlock('\nvoid %s(void) {',fcnInfo.TermFcn);
                generateFcnBody(writer,wrappersInfo,termFcnNames);
                writer.endBlock('\n}\n\n');
            end


            function hasInit=getHasFcn(wrappersInfo,fcnNames)
                hasInit=false;
                for index=1:numel(wrappersInfo)
                    for kk=1:numel(fcnNames)
                        currentFunction=fcnNames{kk};
                        if~isempty(wrappersInfo(index).(currentFunction))
                            hasInit=true;
                            return
                        end
                    end
                end


                function generateFcnBody(writer,wrappersInfo,fcnNames)
                    for index=1:numel(wrappersInfo)
                        for kk=1:numel(fcnNames)
                            currentFunction=fcnNames{kk};
                            if~isempty(wrappersInfo(index).(currentFunction))
                                writer.print('\n%s();',wrappersInfo(index).(currentFunction));
                            end
                        end
                    end


                    function generateStepBody(writer,wrappersInfo,varPrefix,hasEnable)
                        writer.print('\nvolatile short random_cond = 1;\n');
                        for index=1:numel(wrappersInfo)
                            w=wrappersInfo(index);

                            if hasEnable
                                writer.beginBlock('\nif(random_cond && !%sis_enabled_%d) {',varPrefix,index);
                                writer.print('\n%sis_enabled_%d = 1;',varPrefix,index);

                                if~isempty(w.InitializeConditions)
                                    writer.print('\n%s();',w.InitializeConditions);
                                end
                                if~isempty(w.Enable)
                                    writer.print('\n%s();',w.Enable);

                                end
                                writer.endBlock('\n}');

                                writer.beginBlock('\nif(random_cond && %sis_enabled_%d) {',varPrefix,index);
                            else
                                if~isempty(w.InitializeConditions)
                                    writer.beginBlock('\nif(random_cond) {');
                                    writer.print('\n%s();',w.InitializeConditions);
                                    writer.endBlock('\n}\n');
                                end
                                writer.beginBlock('\nif(random_cond) {');
                            end

                            if~isempty(w.PsInputs)
                                writer.print('\n%s();',w.PsInputs);
                            end

                            if~isempty(w.Update)

                                writer.print('\n%s();\n',w.Update);
                            end

                            writer.print('\n%s();\n',w.Output);
                            writer.endBlock('\n}\n');

                            if hasEnable
                                writer.beginBlock('\nif(random_cond && %sis_enabled_%d) {',varPrefix,index);
                                writer.print('\n%sis_enabled_%d = 0;',varPrefix,index);
                                if~isempty(w.Disable)
                                    writer.print('\n%s();',w.Disable);
                                end
                                writer.endBlock('\n}\n');
                            end
                        end


                        function hasEnable=generateEnabledDecl(writer,wrappersInfo,varPrefix)
                            if nargin<3
                                varPrefix='';
                            end
                            hasEnable=false;
                            for index=1:numel(wrappersInfo)
                                if~isempty(wrappersInfo(index).Enable)||~isempty(wrappersInfo(index).Disable)
                                    hasEnable=true;
                                    writer.print('\nshort %sis_enabled_%d = 1;',varPrefix,index);
                                end
                            end
                            writer.print('\n');



