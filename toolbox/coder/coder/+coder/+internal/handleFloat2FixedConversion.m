














function[args,isMEP,isF2FOnly]=handleFloat2FixedConversion(client,args)
    try
        [args,isMEP,isF2FOnly]=handleFloat2FixedConversionImpl(client,args);
    catch ex
        throwAsCaller(ex);
    end
end

function[args,isMEP,isF2FOnly]=handleFloat2FixedConversionImpl(client,args)


    args=coder.internal.processDouble2SingleFlags(client,args);

    isMEP=false;
    isF2FOnly=false;
    [designNamePos,fxpCfgPos,hdlCfgPos,codegenDirPos,mexCfgPos,argsPos,...
    specializedMex,specializedHDL,globalArgPos,searchPathPos,toProject]=findIndices(args);
    if client~="codegen"||~isempty(hdlCfgPos)
        toProject=false;
    end


    args=handleFloat2FixedInIR(args,argsPos,globalArgPos,designNamePos);


    if isempty(fxpCfgPos)

        return;
    end
    [args{:}]=convertStringsToChars(args{:});

    if fxpCfgPos>length(args)


        return;
    end

    fxpCfg=args{fxpCfgPos};

    if~isempty(designNamePos)
        designNames=args(designNamePos);
    else
        designNames=[];
    end

    if~isempty(hdlCfgPos)
        hdlCfg=args{hdlCfgPos};
    else
        hdlCfg=[];
    end

    if~isempty(mexCfgPos)
        mexCfg=args{mexCfgPos};
    else
        mexCfg=[];
    end

    if~isempty(searchPathPos)
        searchPathArgs=args{searchPathPos};
    else
        searchPathArgs=[];
    end

    isDesignACharInput=false;
    if isempty(designNames)

        dnames=fxpCfg.DesignFunctionName;
        if~isempty(dnames)
            if ischar(dnames)
                dnames={dnames};
                isDesignACharInput=true;
            end
            for ii=1:length(dnames)
                args{end+1}=dnames{ii};
                designNamePos=[designNamePos,length(args)];
            end
            designNames=dnames;
        end
    end

    if length(designNames)>1
        isMEP=true;
    end

    if isMEP&&(~isempty(hdlCfg)||specializedHDL)
        error(message('Coder:FXPCONV:MEPHDLNoSupport',strjoin(designNames,', ')));
    end

    validateDesignNamesHere=strcmp(client,'convertToSingle');
    if validateDesignNamesHere
        for dd=1:numel(designNames)
            checkFileExists(designNames{dd});
        end
    end
    if isempty(hdlCfg)&&isempty(mexCfg)&&~specializedMex





        fxpCfg=args{fxpCfgPos};

        if~isempty(codegenDirPos)
            fxpCfg.CodegenDirectory=coder.internal.Helper.getCodegenFolderForCLI(pwd,args{codegenDirPos});
        end

        if(~isempty(designNames))
            fxpCfg=fxpCfg.copy;

            d=cell(1,length(designNames));
            for mm=1:length(designNames)
                dn=designNames{mm};
                [~,d{mm},~]=fileparts(dn);
            end
            if isDesignACharInput
                fxpCfg.DesignFunctionName=d{1};
            else
                fxpCfg.DesignFunctionName=d;
            end

        end


        ii=1;
        while ii<=numel(args)
            arg=args{ii};
            if ischar(arg)
                switch arg
                case{'-report','-launchreport'}
                    args(ii)=[];
                    continue;
                end
            end
            ii=ii+1;
        end


        isF2FOnly=true;
        return;
    end
    if~isempty(fxpCfg)
        if~isempty(codegenDirPos)
            fxpCfg.CodegenDirectory=coder.internal.Helper.getCodegenFolderForCLI(pwd,args{codegenDirPos});
        end
        if~isempty(designNames)

            d=cell(1,length(designNames));
            for mm=1:length(designNames)
                dn=designNames{mm};
                [~,d{mm},~]=fileparts(dn);
            end
            fxpCfg.DesignFunctionName=d;
        end
        if isempty(designNames)



            msg=message('Coder:configSet:NoFunctionNameSpecified');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        try
            availDesignArgsMap=buildDesginArgsMap(args,argsPos,designNamePos);
        catch ex


            ex.throwAsCaller();
        end
        if toProject


            args(fxpCfgPos-1:fxpCfgPos)={'-fixPtData',fxpCfg};
            return;
        end
        [isSuccess,fixptDesignFiles,fxpDir,fixptResult]=performFloat2FixedConversion(...
        client,fxpCfg,availDesignArgsMap,searchPathArgs,args(globalArgPos));
        if~isSuccess

            indices=[fxpCfgPos-1,fxpCfgPos];
            removeFromArgs(indices);
            fxpCfgPos=[];
            return;
        end




        addpath(fxpDir);


        if~isempty(hdlCfg)
            assert(1==length(designNames))
            [hdlCfg,fxpCfg]=updateHDLConfig(hdlCfg,fxpCfg,designNames{1});
            args{hdlCfgPos}=hdlCfg;
            args{fxpCfgPos}=fxpCfg;

            indices=designNamePos;
            removeFromArgs(indices);
            designNamePos=[];
        end

        if~isempty(mexCfg)||specializedMex




            removeFromArgs(designNamePos);
            designArgs=cell(0,length(designNames));
            removeFromArgs([argsPos-1,argsPos]);
            argsPos=[];

            fixPtCoderTypes=convertArgsToFixPt(fxpCfg.InputArgs,fxpCfg);
            for ii=1:length(designNames)
                args{end+1}=fixptDesignFiles{ii};
                designNamePos(ii)=length(args);
                args{end+1}='-args';
                args{end+1}=fixPtCoderTypes{ii};
                designArgs{ii}=fixPtCoderTypes{ii};
                argsPos(ii)=length(args);
            end



            fixptGlbTypes=fxpCfg.getFixedGlobalTypes();
            glbArgListtmp=coder.internal.Helper.getGlobalCodegenArgs(fixptGlbTypes);
            if~isempty(glbArgListtmp)
                if isempty(globalArgPos)
                    args{end+1}='-globals';
                    args{end+1}=glbArgListtmp;
                else
                    args{globalArgPos(end)}=[args{globalArgPos(end)},glbArgListtmp];
                end
            end
        end


        indices=[fxpCfgPos-1,fxpCfgPos];
        removeFromArgs(indices);
        fxpCfgPos=[];



        args(end+1:end+4)={'-fixPtData',fxpCfg,'--fromFixPtConversion',fixptResult};
    else

        if~isempty(hdlCfg)
            if~isempty(designNamePos)
                removeFromArgs(designNamePos);
                designNamePos=[];
            end
        end
    end

    function removeFromArgs(indices)
        indices=sort(indices,2,'descend');
        for kk=1:length(indices)
            [args,designNamePos,fxpCfgPos,hdlCfgPos,codegenDirPos,mexCfgPos,argsPos,globalArgPos]=removeIndexFromArgs(...
            indices(kk),args,designNamePos,fxpCfgPos,hdlCfgPos,codegenDirPos,mexCfgPos,argsPos,globalArgPos);
        end
    end
end



function[args,designNamePos,fxpCfgPos,hdlCfgPos,codegenDirPos,mexCfgPos,argsPos,globalArgPos,toProject]=removeIndexFromArgs(...
    index,args,designNamePos,fxpCfgPos,hdlCfgPos,codegenDirPos,mexCfgPos,argsPos,globalArgPos)
    args(index)=[];

    toProject=false;

    if index<fxpCfgPos
        fxpCfgPos=fxpCfgPos-1;
    end

    if index<hdlCfgPos
        hdlCfgPos=hdlCfgPos-1;
    end

    if index<codegenDirPos
        codegenDirPos=codegenDirPos-1;
    end

    if index<mexCfgPos
        mexCfgPos=mexCfgPos-1;
    end

    val=index<designNamePos;
    if any(val)
        designNamePos(val)=designNamePos(val)-1;
    end

    val=index<argsPos;
    if any(val)
        argsPos(val)=argsPos(val)-1;
    end

    val=index<globalArgPos;
    if any(val)
        globalArgPos(val)=globalArgPos(val)-1;
    end
end

function[designNamePos,fxpCfgPos,hdlCfgPos,codegenDirPos,mexCfgPos,argsPos,...
    specializedMex,specializedHDL,globalArgPos,searchPathPos,toProject]=findIndices(inargs)
    [inargs{:}]=convertStringsToChars(inargs{:});

    designNamePos=[];
    fxpCfgPos=[];
    hdlCfgPos=[];
    codegenDirPos=[];
    mexCfgPos=[];
    argsPos=[];
    specializedMex=false;
    specializedHDL=false;
    toProject=false;
    globalArgPos=[];
    searchPathPos=[];

    ii=1;
    N=numel(inargs);
    while ii<=N
        arg=inargs{ii};
        ii=ii+1;
        if coder.internal.isCharOrScalarString(arg)&&strlength(arg)>0
            arg=strtrim(arg);
            if coder.internal.isOptionPrefix(arg)



                switch extractAfter(arg,1)
                case{'outputdir','eg','F','fimath'...
                    ,'include','N','numerictype','o','outputfile','O','optim'...
                    ,'s','T','-codeGenWrapper','-preserve','feature'...
                    ,'reportinfo','test'}
                    ii=ii+1;
                case{'globals','global'}
                    globalArgPos(end+1)=ii;
                    ii=ii+1;
                case 'I'
                    searchPathPos=ii;
                    ii=ii+1;
                case 'args'
                    argsPos(end+1)=ii;
                    ii=ii+1;
                case 'd'
                    codegenDirPos=ii;
                    ii=ii+1;
                case 'float2fixed'
                    if length(inargs)>=ii
                        if isa(inargs{ii},'coder.FixPtConfig')
                            fxpCfgPos=ii;
                        end
                    end
                    ii=ii+1;
                case{'config:mex','config:lib','config:dll','config:exe','c'}
                    specializedMex=true;
                case{'config:hdl'}

                    specializedMex=true;
                    specializedHDL=true;
                case 'config'
                    if length(inargs)>=ii
                        if isa(inargs{ii},'coder.HdlConfig')
                            hdlCfgPos=ii;
                        elseif isa(inargs{ii},'coder.FixPtConfig')
                            fxpCfgPos=ii;
                        elseif(isa(inargs{ii},'coder.CodeConfig')||isa(inargs{ii},'coder.MexCodeConfig')||isa(inargs{ii},'coder.EmbeddedCodeConfig'))
                            mexCfgPos=ii;
                        end
                    end
                    ii=ii+1;
                case 'toproject'
                    toProject=true;
                    ii=ii+1;
                end
            else
                [~,~,ext]=fileparts(arg);




                if isempty(ext)||strcmp(ext,'.m')
                    if~isempty(designNamePos)


                        designNamePos(end+1)=ii-1;
                    else
                        designNamePos=ii-1;
                    end
                end
            end
        end
    end
end


function[hdlCfg,fxpCfg]=updateHDLConfig(hdlCfg,fxpCfg,designName)
    hdlCfgCopied=false;
    if~isempty(designName)


        fxpCfg=fxpCfg.copy;
        fxpCfg.DesignFunctionName=designName;



        hdlCfg=hdlCfg.copy;
        hdlCfgCopied=true;
        hdlCfg.DesignFunctionName=designName;
    end
    if~hdlCfgCopied
        hdlCfg=hdlCfg.copy;
    end

    hdlCfg.DesignFunctionName=[fxpCfg.DesignFunctionName,fxpCfg.FixPtFileNameSuffix];

    if iscell(fxpCfg.TestBenchName)
        if length(fxpCfg.TestBenchName)>1
            error('hdl does not support multi test bench yet');
        else
            fxpCfg.TestBenchName=fxpCfg.TestBenchName{1};
        end
    end
    tb=fxpCfg.TestBenchName;
    if isempty(tb)&&~ischar(tb)
        tb='';
    end
    hdlCfg.TestBenchScriptName=tb;

    hdlCfg.IsFixPtConversionDone=true;
end




function[success,fixptDesignFiles,fxpDir,result]=performFloat2FixedConversion(client,fxpCfg,availDesignArgsMap,searchPathArgs,globalArgs)

    fixptDesignFiles={};
    fxpDir=[];

    designNames=fxpCfg.DesignFunctionName;



    if ischar(designNames)
        designNames={designNames};
    end



    codegenArgs={'-config',fxpCfg};
    if~isempty(availDesignArgsMap)

        designsArgsList={};
        for ll=1:length(designNames)
            dn=designNames{ll};
            designsArgsList{end+1}=dn;%#ok<*AGROW>

            if availDesignArgsMap.isKey(dn)
                designsArgsList{end+1}='-args';
                designsArgsList{end+1}=availDesignArgsMap(dn);
            end
        end
        codegenArgs={codegenArgs{:},designsArgsList{:}};%#ok<CCAT>
    else
        codegenArgs={codegenArgs{:},designNames{:}};%#ok<CCAT>
    end
    if~isempty(searchPathArgs)
        codegenArgs=[codegenArgs,'-I',searchPathArgs];
    end
    if~isempty(globalArgs)
        for ll=1:length(globalArgs)
            codegenArgs=[codegenArgs,'-globals',globalArgs(ll)];
        end
    end
    result=emlcprivate('emlckernel',client,codegenArgs{:});

    if isfield(result,'internal')&&isa(result.internal,'MException')

        success=false;
    else
        pEP=fxpCfg.DesignFunctionName{1};

        if~isempty(fxpCfg.CodegenDirectory)
            fxpDir=fullfile(fxpCfg.CodegenDirectory,pEP,fxpCfg.getRelativeBuildDirectory());
        else
            fxpDir=fullfile(pwd,client,pEP,fxpCfg.getRelativeBuildDirectory());
        end
        fixptDesignFiles=cellfun(@(d)fullfile(fxpDir,[d,fxpCfg.FixPtFileNameSuffix,'.m']),designNames,'UniformOutput',false);
        fixptFilesExist=cellfun(@(fixptFile)isfile(fixptFile),fixptDesignFiles,'UniformOutput',true);
        if~all(fixptFilesExist)
            success=false;
        else
            success=true;
        end
    end
end

function fixPtCoderTypes=convertArgsToFixPt(designArgs,fxpCfg)
    if isempty(designArgs)
        fixPtCoderTypes=designArgs;
        return;
    end
    fixPtCoderTypes=fxpCfg.ConvertedInputFiTypes;






























































end

function codegen_args=handleFloat2FixedInIR(codegen_args,argsPos,globalArgPos,designNamePos)




    cfg=[];

    for ii=1:numel(codegen_args)
        arg=codegen_args{ii};
        if numel(arg)==1&&isa(arg,'coder.Config')&&isprop(arg,'F2FConfig')&&~isempty(arg.F2FConfig)
            fc=arg;
            cfg=fc.F2FConfig;
            break;
        end
    end

    if~isempty(cfg)

        if cfg.DoubleToSingle

            for ii=1:length(argsPos)
                pos=argsPos(ii);
                types=codegen_args{pos};


                newTypes=coder.internal.makeDoubleTypesSingle(types);

                codegen_args{pos}=newTypes;
            end
            if~isempty(globalArgPos)&&globalArgPos>=1
                globalArg=codegen_args{globalArgPos};
                for ii=2:2:length(globalArg)
                    types=globalArg{ii};
                    newTypes=coder.internal.makeDoubleTypesSingle(types);
                    globalArg{ii}=newTypes;
                end
                codegen_args{globalArgPos}=globalArg;
            end
        elseif cfg.ApplyTypeAnnotations
            dataTypesFunctionName=cfg.DataTypesFunctionName;
            [~,T]=evalc(dataTypesFunctionName);
            fcns=fieldnames(T);
            fcnsToTransform=strjoin(fcns',' , ');

            cfg.FunctionsToTransform=fcnsToTransform;


            for ii=1:length(argsPos)
                pos=argsPos(ii);
                types=codegen_args{pos};

                designName=codegen_args{designNamePos};

                newTypes=coder.internal.applyTypeAnnotationsToInputTypes(types,T,designName);

                codegen_args{pos}=newTypes;
            end
        end
    end
end












function availDesignArgsMap=buildDesginArgsMap(args,argsPos,designNamePos)

    availDesignArgsMap=containers.Map();


    assert(~isempty(designNamePos));

    dPosIter=1;
    argsPosIter=1;
    while(argsPosIter<=length(argsPos))
        currArgPos=argsPos(argsPosIter);
        while(dPosIter<=length(designNamePos))
            currDPos=designNamePos(dPosIter);




            if currDPos>currArgPos
                break;
            end
            dPosIter=dPosIter+1;
        end

        assignDesignArgs(argsPosIter,dPosIter-1);
        argsPosIter=argsPosIter+1;
    end

    assert(length(availDesignArgsMap.keys)==length(argsPos));






    function assignDesignArgs(argPsIt,designPsIt)
        if designPsIt<=0

            designPsIt=1;
        end

        dn=args{designNamePos(designPsIt)};
        [~,dn,~]=fileparts(dn);
        dArg=args{argsPos(argPsIt)};
        if availDesignArgsMap.isKey(dn)

            error(message('Coder:common:MultipleCoderTypes'));
        else
            availDesignArgsMap(dn)=dArg;
        end
    end
end

function checkFileExists(file)
    filePath=coder.internal.Helper.which(file);
    [~,tmpName,~]=fileparts(filePath);
    [~,actName,~]=fileparts(file);



    if~strcmp(tmpName,actName)
        error(message('Coder:FXPCONV:InvalidDesignFile',actName));
    end
end















