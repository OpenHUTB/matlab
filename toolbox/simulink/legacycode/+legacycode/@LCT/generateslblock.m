function generateslblock(h,sysPath)





    if nargin<2
        sysPath='';
    end

    if nargin<1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct');
    end


    h=h(:);
    nbDefs=length(h);


    [mdlName,relSSPath]=strtok(sysPath,'/');
    if exist(mdlName,'file')~=4
        if isempty(mdlName)
            mdlName=sltemplate.internal.getUntitledSystemName;
        end
        hSys=new_system(mdlName,'FromTemplate','factory_default_model');
        mdlName=get_param(hSys,'Name');
    end






    hideDiagram=all(arrayfun(@(x)(x.Options.stubSimBehavior),h));
    if~hideDiagram
        open_system(mdlName);
    end


    sysPath=mdlName;
    if~isempty(relSSPath)
        ssNames=textscan(relSSPath,'%s','Delimiter','/');
        if~isempty(ssNames)&&~isempty(ssNames{1})

            for ii=2:numel(ssNames{1})

                blk=find_system(sysPath,'SearchDepth',1,'BlockType','SubSystem',...
                'Name',ssNames{1}{ii});


                sysPath=[sysPath,'/',ssNames{1}{ii}];%#ok<AGROW>


                if isempty(blk)
                    blk=add_block('built-in/subsystem',sysPath,'MakeNameUnique','on');
                    sysPath=getfullname(blk);
                end
            end
        end
    end


    dh=30;

    for ii=1:nbDefs

        try

            infoStruct=legacycode.util.lct_pGetFullInfoStructure(h(ii),'slblock');


            y0=(ii-1)*(dh+30);
            nb=max(length(infoStruct.Specs.SFunctionName),length(infoStruct.Specs.OutputFcnSpec));
            dx=5.5*nb;
            showSpec='on';
            if dx>600
                dx=100;
                showSpec='off';
            end

            position=[15,y0+15,15+dx,y0+45];


            blk=iAddSfunctionBlock(sysPath,infoStruct,position);


            set_param(blk,...
            'ShowSpec',showSpec,...
            'MaskDisplay',sprintf('fprintf(''%%s'',''%s'');',infoStruct.Specs.OutputFcnSpec));

        catch ME
            rethrow(ME);
        end
    end



    function blk=iAddSfunctionBlock(sysPath,infoStruct,position)


        ctorCmd=legacycode.LCT.generateSpecConstructionCmd(infoStruct.Specs,'c');


        idx=strfind(ctorCmd,newline);
        ctorCmd(idx(end-2)+1:end)=[];
        ctorCmd(1:idx(1))=[];



        ctorCmd=strrep(ctorCmd,'     ','');


        maskDescription=DAStudio.message('Simulink:tools:LCTBlkMaskDescription',ctorCmd);


        maskHelp=['<p>',DAStudio.message('Simulink:tools:LCTBlkMaskHelp'),...
        '<a href="matlab:legacy_code(''help'')"> legacy_code(''help'')</a>.</p>'];


        maskVariables='SFunctionSpec=&1';
        maskValueString=infoStruct.Specs.OutputFcnSpec;
        maskPromptString='SFunctionSpec';
        maskVisibilities={'off'};
        maskTunableValue={'off'};
        maskStyleString='edit';
        maskCallBackString='';

        parameterString='';
        sep='';
        nbParam=infoStruct.Parameters.Num;

        for ii=1:nbParam
            maskVariables=[maskVariables,sprintf(';SParameter%d=@%d',ii,ii+1)];%#ok


            pDim=infoStruct.Parameters.Parameter(ii).Dimensions;
            if length(pDim)==1



                pDim=[pDim,1];%#ok
            end







            idx=find(pDim==-1);
            pDim(idx<=2)=1;
            pDim(idx>2)=2;
            pDimStr=sprintf('[%s]',sprintf('%d ',pDim));

            pDataType=infoStruct.DataTypes.DataType(infoStruct.Parameters.Parameter(ii).DataTypeId);
            [paramIsGlobal,globalParamIdx]=infoStruct.GlobalIO.ParamIsGlobal(ii);
            if paramIsGlobal
                pDefaultValueStr=infoStruct.GlobalIO.Parameters(globalParamIdx).WorkspaceName;
            elseif pDataType.IsEnum
                enumDefaultValueStr=pDataType.EnumInfo.Strings{pDataType.EnumInfo.DefaultValueIdx};
                if any(pDim==-1)||prod(pDim)==1
                    pDefaultValueStr=sprintf('%s.%s',pDataType.Name,enumDefaultValueStr);
                else
                    pDimAsStr=mat2str(pDim);
                    pDefaultValueStr=sprintf('repmat(%s.%s, %s)',pDataType.Name,enumDefaultValueStr,pDimAsStr);
                end

            elseif pDataType.IsBus


                pDefaultValueStr='0';

            else
                pDefaultValueStr=sprintf('ones(%s)',pDimStr);

            end

            maskValueString=[maskValueString,'|',pDefaultValueStr];%#ok
            maskPromptString=[maskPromptString,sprintf('|P%d:',ii)];%#ok
            maskVisibilities=[maskVisibilities;{'on'}];%#ok


            tunVal='on';
            if legacycode.lct.util.feature('newImpl')
                paramAsDim=infoStruct.ParamAsDimensionId;
            else
                paramAsDim=infoStruct.Parameters.ParamAsDimensionId;
            end
            if ismember(ii,paramAsDim)
                tunVal='off';
            end
            maskTunableValue=[maskTunableValue;{tunVal}];%#ok

            maskStyleString=[maskStyleString,',edit'];%#ok
            maskCallBackString=[maskCallBackString,'|'];%#ok
            parameterString=[parameterString,sprintf('%sSParameter%d',sep,ii)];%#ok
            sep=', ';
        end

        if strcmp(infoStruct.SampleTime,'parameterized')
            maskVariables=[maskVariables,sprintf(';SampleTime=@%d',nbParam+2)];
            maskValueString=[maskValueString,'|-1'];
            maskPromptString=[maskPromptString,'|',...
            DAStudio.message('Simulink:tools:LCTBlkMaskSampleTimeParam'),':'];
            maskVisibilities=[maskVisibilities;{'on'}];
            maskTunableValue=[maskTunableValue;{'off'}];
            maskStyleString=[maskStyleString,',edit'];
            maskCallBackString=[maskCallBackString,'|'];
            parameterString=[parameterString,sprintf('%sSampleTime',sep)];
            sep=', ';%#ok
            nbParam=nbParam+1;
        end

        maskVariables=[maskVariables,sprintf(';ShowSpec=@%d',nbParam+2)];
        maskValueString=[maskValueString,'|on'];
        maskPromptString=[maskPromptString,'|',...
        DAStudio.message('Simulink:tools:LCTBlkMaskShowFcnSpecParam')];
        maskVisibilities=[maskVisibilities;{'on'}];
        maskTunableValue=[maskTunableValue;{'on'}];
        maskStyleString=[maskStyleString,',checkbox'];
        maskCallBackString=[maskCallBackString,'|',...
        'if strcmp(get_param(gcbh, ''ShowSpec''), ''on'')',newline,...
        '  set_param(gcbh, ''MaskDisplay'', sprintf(''fprintf(''''%s'''');'', get_param(gcbh, ''SFunctionSpec'')));',newline,...
        'else',newline,...
        '  set_param(gcbh, ''MaskDisplay'', sprintf(''fprintf(''''%s'''');'', get_param(gcbh, ''FunctionName'')));',newline,...
        'end'];


        blk=find_system(sysPath,...
        'SearchDepth',1,...
        'MaskType','Legacy Function',...
        'FunctionName',infoStruct.Specs.SFunctionName...
        );

        for ii=1:length(blk)
            delete_block(blk{ii});
        end


        blk=add_block(...
        'built-in/S-Function',[sysPath,'/',infoStruct.Specs.SFunctionName],...
        'MakeNameUnique','on',...
        'Mask','on',...
        'MaskSelfmodifiable','on',...
        'MaskDisplay','',...
        'MaskType','Legacy Function',...
        'MaskDescription',maskDescription,...
        'MaskHelp',maskHelp,...
        'MaskInitialization','',...
        'MaskPromptString',maskPromptString,...
        'MaskVariables',maskVariables,...
        'MaskValueString',maskValueString,...
        'MaskStyleString',maskStyleString,...
        'MaskVisibilities',maskVisibilities,...
        'MaskCallBackString',maskCallBackString,...
        'MaskTunableValues',maskTunableValue,...
        'MaskIconRotate','port',...
        'MaskIconUnits','Normalized',...
        'FunctionName',infoStruct.Specs.SFunctionName,...
        'Parameters',parameterString,...
        'Position',position...
        );


