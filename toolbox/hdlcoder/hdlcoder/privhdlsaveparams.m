function paramSet=privhdlsaveparams(varargin)




    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    if nargin<1||nargin>6
        error(message('hdlcoder:engine:invalidarglist','hdlsaveparams'));
    end

    if(nargin>2)
        force_overwrite=varargin{3};
    else
        force_overwrite=false;
    end

    if(nargin>3)
        warn=varargin{4};
    else
        warn=true;
    end

    if(nargin>4)
        comments=varargin{5};
    else
        comments=true;
    end

    if(nargin>5)
        group=varargin{6};
    else
        group=false;
    end

    dut=varargin{1};

    if(nargin>=2&&~isempty(varargin{2}))
        filename=varargin{2};

        [pathstr,name,ext]=fileparts(filename);
        if(isempty(ext)||~strcmp(ext,'.m'))
            warning(message('hdlcoder:engine:ForceFilenameExtension',filename));
            ext='.m';
        end
        filename=fullfile(pathstr,[name,ext]);
    end

    sys=getModelName(dut);

    paramSet=struct('object',{},'parameter',{},'value',{});
    fil=1;
    if(nargin>=2&&~isempty(varargin{2}))

        if(exist(filename,'file')==2)
            if(~force_overwrite)
                error(message('hdlcoder:engine:ErrorOverwriteFile',filename));
            elseif(warn)
                warning(message('hdlcoder:engine:WarnOverwriteFile',filename));
            end
        end
        try
            fil=fopen(filename,'w+');
        catch me
            error(message('hdlcoder:engine:CouldNotOpenFile',filename));
        end
    end

    if fil<0
        error(message('hdlcoder:engine:CouldNotOpenFile',filename));
    end

    if(comments)
        fprintf(fil,'%%%% Set Model ''%s'' HDL parameters\n',sys);
    end

    paramSet=setModelParams(sys,fil,paramSet,group);
    fprintf(fil,'\n');

    paramSet=setAllBlockParams(dut,fil,paramSet,comments,group);


    paramSet=setAllModelRefBlockParams(dut,fil,paramSet,comments,group);

    if(nargin>=2&&~isempty(varargin{2}))
        fclose(fil);
    end

end

function paramSet=setModelParams(sys,fil,paramSet,group)

    cli=hdlcoderprops.CLI;
    mdlProps=get_param(sys,'HDLParams');

    if~isempty(mdlProps)
        currProps=mdlProps.getCurrentMdlProps;


        for k=1:2:length(currProps)
            try
                cli.set(currProps{k},currProps{k+1});
            catch me %#ok<NASGU>

            end
        end
    end


    paramNames=cli.getNonDefaultHDLCoderProps;




    if group

        groupList={...
        'SynthesisToolChipFamily',...
        'SynthesisToolDeviceName',...
        'SynthesisToolPackageName',...
        'SynthesisToolSpeedValue',...
        };

        if any(ismember(groupList,paramNames))
            paramNames=union(groupList,paramNames);
        end

        paramNames=sort(paramNames);
    end


    for i=1:length(paramNames)
        paramName=paramNames{i};
        val=cli.(paramName);

        paramSet=setParam(sys,paramName,val,fil,paramSet,false);
    end

end

function paramSet=setAllModelRefBlockParams(dut,fil,paramSet,comments,group)




    models=find_system(dut,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','BlockType','ModelReference');
    models=unique(models);

    for i=1:length(models)
        isProtected=isprop(get_param(models{i},'Object'),'ProtectedModel')&&...
        strcmp(get_param(models{i},'ProtectedModel'),'on');
        if isProtected
            modelFile=get_param(models{i},'ModelFile');
            [~,model,~]=fileparts(modelFile);
            paramSet=extractProtectedModelParams(model,fil,paramSet);
            continue;
        end



        name=get_param(models{i},'ModelName');
        load_system(name);


        cleanupFcn=coder.internal.infoMATInitializeFromSTF...
        (get_param(name,'SystemTargetFile'),name);

        [refs,~,protectedRefs]=slprivate...
        ('get_ordered_model_references',...
        name,true,...
        'ModelReferenceTargetType','RTW');


        delete(cleanupFcn);


        for j=length(refs):-1:1
            model=refs(j).modelName;
            load_system(model);

            if(comments)
                fprintf(fil,'%%%% Set Referenced Model ''%s'' HDL parameters\n',model);
            end


            fprintf(fil,'load_system(''%s'');\n\n',model);
            paramSet=setAllBlockParams(model,fil,paramSet,comments,group);
        end


        for k=length(protectedRefs):-1:1
            model=protectedRefs(k).modelName;
            paramSet=extractProtectedModelParams(model,fil,paramSet);
        end
    end

end

function paramSet=extractProtectedModelParams(model,fil,paramSet)
    unpackDir=[pwd,filesep,model];
    if exist(unpackDir,'dir')==7
        rmdir(unpackDir,'s');
    end




    protectedMdlFullName=which([model,'.slxp']);
    if isempty(protectedMdlFullName)
        protectedMdlFullName=model;
    end

    Simulink.ModelReference.ProtectedModel.unpackHDL(protectedMdlFullName,unpackDir);
    matFile=[unpackDir,filesep,'hdlcodegenstatus.mat'];
    clear('HDLParams');
    load(matFile,'HDLParams');

    paramSet=setProtectedModelParams(model,HDLParams,fil,paramSet);

    if exist(unpackDir,'dir')==7
        rmdir(unpackDir,'s');
    end
end

function paramSet=setProtectedModelParams(dut,HDLParams,fil,paramSet)
    fprintf(fil,'%%%% Protected model: %s\n',dut);
    for ii=1:numel(HDLParams)
        param=HDLParams(ii).parameter;
        val=HDLParams(ii).value;
        paramSet=setParam(dut,param,val,fil,paramSet,true);
    end
end

function paramSet=setAllBlockParams(dut,fil,paramSet,comments,group)



    allblks=find_system(dut,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all');
    for i=1:length(allblks)
        paramSet=setBlockParams(allblks{i},fil,paramSet,comments,group);
    end

end

function paramSet=setBlockParams(blkNameWithPath,fil,paramSet,comments,group)

    h=get_param(blkNameWithPath,'handle');
    [~,fail]=hdlgetblocklibpath(h);
    if fail
        return;
    end

    hd=slprops.hdlblkdlg(blkNameWithPath);
    if isempty(hd.getCurrentArchImplParams)

        return;
    end

    cd=get_param(blkNameWithPath,'HDLData');
    if~isempty(cd)
        cp=cd.getCurrentArchImplParams;
        ca=cd.getCurrentArch;

        if isempty(cp)&&isempty(ca)
            return;
        end

        if~isempty(ca)
            if(~isequal(hd.defArchSelection,ca))
                paramSet=setParam(blkNameWithPath,'Architecture',ca,fil,paramSet,false);
            end
        end

        if~isempty(cp)

            if~iscell(cp)||mod(length(cp),2)~=0
                if(nargin==2)
                    fclose(fil);
                end
                error(message('hdlcoder:engine:invalidHDLData',blkNameWithPath));
            end


            selectedArchInfo=hd.archInfo(hd.archSelection);

            validImplParams=isKey(selectedArchInfo,lower(cp(1:2:end-1)));

            if any(validImplParams)
                if(comments)
                    fprintf(fil,'%% Set %s HDL parameters\n',get_param(blkNameWithPath,'BlockType'));
                end

                pNamesIdx=1:2:length(cp);
                pNamesIdx=pNamesIdx(validImplParams);
                pNames=cp(pNamesIdx);

                pValsIdx=2:2:length(cp);
                pValsIdx=pValsIdx(validImplParams);
                pVals=cp(pValsIdx);

                for ii=1:length(pNames)
                    pName=pNames{ii};
                    pVal=pVals{ii};

                    paramSet=setParam(blkNameWithPath,pName,pVal,fil,paramSet,false);






                    if group
                        if isequal(pName,'IOInterface')&&~any(strcmpi(cp,'IOInterfaceMapping'))
                            paramSet=setParam(blkNameWithPath,'IOInterfaceMapping','',fil,paramSet,false);
                        end
                    end


                end
            end
        end
        fprintf(fil,'\n');
    end
end


function paramSet=setParam(obj,param,val,fil,paramSet,isComment)
    obj=strrep(obj,char(10),' ');





    if isComment
        fprintf(fil,'%%    ');
    end
    if isnumeric(val)
        if isscalar(val)
            fprintf(fil,'hdlset_param(''%s'', ''%s'', %d);',obj,param,val);
        else
            valStr=sprintf('%d ',val);
            fprintf(fil,'hdlset_param(''%s'', ''%s'', [%s]);',obj,param,valStr);
        end
    elseif isa(val,'hdlcodingstd.BaseCustomizations')
        fprintf(fil,'hdlset_param(''%s'',''%s'',%s);',obj,param,val.serialize());
    elseif isa(val,'hdlcoder.FloatingPointTargetConfig')
        scripts=val.serializeOutMScripts();
        fprintf(fil,'hdlset_param(''%s'', ''%s'', %s);',obj,param,scripts);
    elseif iscell(val)
        fprintf(fil,'hdlset_param(''%s'', ''%s'', %s);',obj,param,hdlCellArray2Str(val));
    else





        val_escaped=strrep(val,'''','''''');

        if(isempty(strfind(val_escaped,char(10))))

            fprintf(fil,'hdlset_param(''%s'', ''%s'', ''%s'');',obj,param,val_escaped);
        else
            val_folded=coder.internal.tools.TML.tostr(val_escaped,true);
            fprintf(fil,'hdlset_param(''%s'', ''%s'', %s);',obj,param,val_folded);
        end
    end
    paramSet(end+1)=struct('object',{obj},'parameter',{param},'value',{val});
    fprintf(fil,'\n');
end

function mdlname=getModelName(dut)
    try
        mdlname=bdroot(dut);
    catch me
        error(message('hdlcoder:engine:invalidchipname',dut));
    end

    if isempty(mdlname)
        error(message('hdlcoder:engine:invalidchipname',dut));
    end
end



