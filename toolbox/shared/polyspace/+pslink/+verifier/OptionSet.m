classdef OptionSet<handle




    properties(Hidden=true,SetAccess=protected,GetAccess=public)
tplFlags
tplReqFlags
tplElemFlags
fileName
sourceMode
    end

    properties(GetAccess=public,SetAccess=public)
coderObj
mdlRefInfo
drsInfo
arInfo
fileInfo
fcnInfo
typeInfo
dataLinkInfo
drsFileName
lnkFileName
optionsFileName
packageName
resultDir
    end

    methods(Access=public)



        function self=OptionSet(fileName)
            self.tplFlags=cell(0,2);
            self.sourceMode='MATLAB';

            self.coderObj=[];
            self.mdlRefInfo=cell(0,2);
            self.drsInfo=pslink.verifier.Coder.createAllRangeInfoStruct();
            self.arInfo=pslink.verifier.Coder.createAllARInfoStruct();
            self.fileInfo=pslink.verifier.Coder.createFileInfoStruct();
            self.fcnInfo=pslink.verifier.Coder.createAllFcnInfoStruct();
            self.fcnInfo.mustWriteAllData=true;
            self.dataLinkInfo=[];
            self.drsFileName='';
            self.lnkFileName='';
            self.optionsFileName='';
            self.packageName='';

            if nargin>0
                if exist(fileName,'file')~=2
                    self.createTemplateFile(fileName);
                else

                    self.read(fileName);
                end
            end
        end




        function delete(~)
        end




        function[ovwOpts,archiveFiles]=fixSrcFiles(self,ovwOpts,pslinkOptions)%#ok<INUSD,STOUT,INUSL>
        end




        function getTplFlags(self,language)%#ok<INUSD>
        end




        function fixIncludes(self,ovwOpts,archiveFiles)%#ok<INUSD>
        end




        function getTypeInfo(self,systemName,sysDirInfo)%#ok<INUSD>
        end




        function optionsLine=AddTplOptions(self)
            optionsLine={};

            for ii=1:size(self.tplFlags,1)
                if isempty(self.tplFlags{ii,2})

                    optionsLine{end+1}=sprintf('%s',self.tplFlags{ii,1});%#ok<AGROW>
                else
                    values=self.tplFlags{ii,2};
                    for jj=1:numel(values)

                        optionsLine{end+1}=sprintf('%s %s',self.tplFlags{ii,1},values{jj});%#ok<AGROW>
                    end
                end
            end
        end




        function optionsLine=getModellingOptions(~,ovwOpts)

            optionsLine={};
            if~isstruct(ovwOpts)
                return
            end


            field2Attr1={...
            'main_generator','-main-generator';...
            'stub_ec_lut','-stub-embedded-coder-lookup-table-functions'...
            };


            field2Attr2={...
            'include','-I';...
            'extra_headers','-include';...
            'define','-D';...
            'undefine','-U';...
            'do_not_generate_results_for','-do-not-generate-results-for'...
            };



            field2Attr3={...
            'var_in_loop','-variables-written-in-loop',true;...
            'var_before_loop','-variables-written-before-loop',true;...
            'fcn_before_loop','-functions-called-before-loop',false;...
            'fcn_after_loop','-functions-called-after-loop',false;...
            'fcn_in_loop','-functions-called-in-loop',true;...
            'fcn_to_stub','-functions-to-stub',false...
            };

            if strcmpi(ovwOpts.language,'C++ (Encapsulated)')

                cxxeAttr3={...
                'class_analyser','-class-analyzer',true...
                };
                field2Attr3=[field2Attr3;cxxeAttr3];
            elseif strcmpi(ovwOpts.language,'C')

                cAttr3={...
                'booleanTypes','-boolean-types',false...
                };
                field2Attr3=[field2Attr3;cAttr3];
            end

            if isfield(ovwOpts,'cpp_version')
                extraAttr1={...
                'cpp_version','-cpp-version'...
                };
                field2Attr1=[field2Attr1;extraAttr1];







            end

            for ii=1:size(field2Attr1,1)
                fieldName=field2Attr1{ii,1};
                attrName=field2Attr1{ii,2};
                if isfield(ovwOpts,fieldName)
                    if strcmpi(ovwOpts.(fieldName),'true')
                        optionsLine{end+1}=sprintf('%s',attrName);%#ok<AGROW>
                    elseif strcmpi(ovwOpts.(fieldName),'false')

                    else
                        optionsLine{end+1}=sprintf('%s %s',attrName,ovwOpts.(fieldName));%#ok<AGROW>
                    end
                end
            end

            for ii=1:size(field2Attr2,1)
                fieldName=field2Attr2{ii,1};
                attrName=field2Attr2{ii,2};
                if isfield(ovwOpts,fieldName)
                    for jj=1:numel(ovwOpts.(fieldName))
                        if~isempty(ovwOpts.(fieldName){jj})
                            optionsLine{end+1}=sprintf('%s %s',attrName,ovwOpts.(fieldName){jj});%#ok<AGROW>
                        end
                    end
                end
            end

            for ii=1:size(field2Attr3,1)
                fieldName=field2Attr3{ii,1};
                attrName=field2Attr3{ii,2};
                isCustom=field2Attr3{ii,3};
                if isfield(ovwOpts,fieldName)


                    if strcmpi(ovwOpts.(fieldName){1},'none')||strcmpi(ovwOpts.(fieldName){1},'all')
                        value=sprintf('%s',ovwOpts.(fieldName){1});
                        optionsLine{end+1}=[attrName,' ',value];%#ok<AGROW>
                    else
                        if isCustom
                            optionsLine{end+1}=sprintf('%s %s',attrName,'custom=');%#ok<AGROW>
                        else
                            optionsLine{end+1}=sprintf('%s ',attrName);%#ok<AGROW>
                        end
                        valuesList='';
                        for jj=1:numel(ovwOpts.(fieldName))
                            if~isempty(ovwOpts.(fieldName){jj})
                                if isempty(valuesList)
                                    valuesList=sprintf('%s',ovwOpts.(fieldName){jj});
                                else
                                    valuesList=sprintf('%s,%s',valuesList,ovwOpts.(fieldName){jj});
                                end
                            end
                        end
                        optionsLine{end}=sprintf('%s%s',optionsLine{end},valuesList);
                    end
                end
            end

            if isfield(ovwOpts,'extra_options')
                for jj=1:numel(ovwOpts.extra_options)
                    optName=ovwOpts.extra_options(jj).name;
                    if~isempty(ovwOpts.extra_options(jj).val)
                        optVal=ovwOpts.extra_options(jj).val;
                        optionsLine{end+1}=sprintf('%s %s',optName,optVal);%#ok<AGROW>
                    else
                        optionsLine{end+1}=sprintf('%s',optName);%#ok<AGROW>
                    end
                end
            end
        end




        function targetOptLine=getTargetOptions(~,typeInfo,language)

            setDefaultTarget=false;
            targetOptLine={};


            if strcmpi(language,'c')
                rightShiftOpt='-logical-signed-right-shift';
                if~typeInfo.ShiftRightIntArith
                    targetOptLine{end+1}=sprintf('%s',rightShiftOpt);
                end
            end




            if(typeInfo.CharNumBits==32||typeInfo.ShortNumBits==32)
                warning('pslink:cannotFillHWSettingsWithSuggestion',...
                message('polyspace:gui:pslink:cannotFillHWSettingsWithSuggestion','tms320c3x').getString())
                targetOptLine{end+1}=sprintf('%s %s','-target','tms320c3x');
                return
            end

            if typeInfo.PointerNumBits==8
                warning('pslink:cannotFillHWSettings',message('polyspace:gui:pslink:cannotFillHWSettings').getString())
                setDefaultTarget=true;
            end

            if setDefaultTarget

                targetOptLine{end+1}=sprintf('%s %s','-target','i386');
                return
            end

            if strcmp(typeInfo.HWDeviceType,'Generic->MATLAB Host Computer')

                if typeInfo.PointerNumBits>=64
                    targetOptLine{end+1}=sprintf('%s %s','-target','x86_64');
                    nFixX8664Target(typeInfo);
                else
                    targetOptLine{end+1}=sprintf('%s %s','-target','i386');
                end

            elseif typeInfo.IntNumBits>=64||typeInfo.LongNumBits>=64||typeInfo.WordNumBits>=64

                targetOptLine{end+1}=sprintf('%s %s','-target','x86_64');
                nFixX8664Target(typeInfo);

            else
                optName='-target';
                targetOptLine{end+1}=sprintf('%s %s',optName,'mcpu');


                optName='-align';
                if typeInfo.WordNumBits>32

                    optValue='32';
                else
                    optValue=sprintf('%d',typeInfo.WordNumBits);
                end
                targetOptLine{end+1}=sprintf('%s %s',optName,optValue);


                optName='-default-sign-of-char';
                if typeInfo.IsCharSigned
                    optValue='signed';
                else
                    optValue='unsigned';
                end
                targetOptLine{end+1}=sprintf('%s %s',optName,optValue);


                if strcmp(typeInfo.Endianess,'BigEndian')
                    optName='-big-endian';
                else

                    optName='-little-endian';
                end
                targetOptLine{end+1}=sprintf('%s',optName);

                if typeInfo.CharNumBits==16
                    targetOptLine{end+1}=sprintf('%s','-char-is-16bits');
                else

                end

                if typeInfo.ShortNumBits==8
                    targetOptLine{end+1}=sprintf('%s','-short-is-8bits');
                else

                end

                if typeInfo.IntNumBits==32
                    targetOptLine{end+1}=sprintf('%s','-int-is-32bits');
                else

                end

                if typeInfo.LongLongNumBits==64
                    targetOptLine{end+1}=sprintf('%s','-long-long-is-64bits');
                else

                end


                targetOptLine{end+1}=sprintf('%s','-double-is-64bits');

                if typeInfo.PointerNumBits==32
                    targetOptLine{end+1}=sprintf('%s','-pointer-is-32bits');
                else

                end
            end

            function nFixX8664Target(typeInfo)

                if typeInfo.LongNumBits==32
                    targetOptLine{end+1}='-long-is-32bits';
                else

                end


                targetOptLine{end+1}=sprintf('%s %d','-align',typeInfo.WordNumBits);
            end
        end




        function printConfiguration(~,systemName,pslinkOptions)
            fprintf(1,'%s\n',message('polyspace:gui:pslink:displayParameters').getString());
            fprintf(1,'%s\n',message('polyspace:gui:pslink:displayParamSystem',regexprep(systemName,'\n',' ')).getString());
            fprintf(1,'%s\n',message('polyspace:gui:pslink:displayParamAddFiles',num2str(pslinkOptions.EnableAdditionalFileList)).getString());
            fprintf(1,'%s\n',message('polyspace:gui:pslink:displayParamDRSInput',pslinkOptions.InputRangeMode).getString());
            fprintf(1,'%s\n',message('polyspace:gui:pslink:displayParamDRSParam',pslinkOptions.ParamRangeMode).getString());
            fprintf(1,'%s\n',message('polyspace:gui:pslink:displayParamDRSOut',pslinkOptions.OutputRangeMode).getString());
        end




        function prepareOptions(self,pslinkOptions)
            self.generateFileName();

            self.writeOptionsFile(pslinkOptions);
            self.writeConstraintsFile();
            self.writeLinksDataFile();
        end




        function packageName=appendToArchive(self,pslinkOptions,isMdlRef)%#ok<STOUT,INUSD>
        end

    end

    methods(Access=protected)



        function generateFileName(self)
            sysDirInfo=self.coderObj.sysDirInfo;
            radix=sysDirInfo.SystemCodeGenName;
            self.drsFileName=fullfile(self.resultDir,[radix,pslink.verifier.OptionSet.endDrsFileName()]);
            self.optionsFileName=fullfile(self.resultDir,'optionsFile.txt');
            self.lnkFileName=fullfile(self.resultDir,'linksData.xml');
        end




        function writeOptionsFile(self,pslinkOptions)

            [fid,status]=fopen(self.optionsFileName,'wt','native','UTF-8');
            if~isempty(status)
                error('pslink:cannotOpenFile',...
                message('polyspace:gui:pslink:cannotOpenFile',...
                strrep(self.optionsFileName,'\','\\'),...
                status).getString())
            end
            cObj=onCleanup(@()fclose(fid));


            ovwOpts=self.getOverwrittenOptions();
            ovwOpts=self.fixOptsFromSettings(ovwOpts,pslinkOptions);


            [ovwOpts,archiveFiles]=self.fixSrcFiles(ovwOpts,pslinkOptions);
            fprintf(fid,'# Generated by Model Link\n');
            fprintf(fid,'-sources ');
            for ii=1:numel(self.fileInfo.source)
                fprintf(fid,'%s',self.fileInfo.source{ii});
                if ii<numel(self.fileInfo.source)
                    fprintf(fid,',');
                else
                    fprintf(fid,'\n');
                end
            end


            ovwOpts=self.fixIncludes(ovwOpts,archiveFiles);

            self.getTplFlags(self.coderObj.cgLanguage);
            optionsLine=self.AddTplOptions();
            for ii=1:numel(optionsLine)
                fprintf(fid,'%s\n',optionsLine{ii});
            end

            optionsLine=self.getModellingOptions(ovwOpts);
            for ii=1:numel(optionsLine)
                fprintf(fid,'%s\n',optionsLine{ii});
            end

            optionsLine=self.getTargetOptions(self.typeInfo,self.coderObj.cgLanguage);
            for ii=1:numel(optionsLine)
                fprintf(fid,'%s\n',optionsLine{ii});
            end

            [~,drsFile,drsExt]=fileparts(self.drsFileName);
            fprintf(fid,'%s %s\n','-data-range-specifications',[drsFile,drsExt]);
        end




        function writeConstraintsFile(self)
            import matlab.io.xml.dom.*
            errMsg='';

            generateCxxDrsOnPtr=strncmpi(self.fcnInfo.codeLanguage,'C++',3);

            pslink.util.DrsHelper.createDrsFile(self.drsFileName);
            xmlDoc=pslink.util.DrsHelper.readDrsFile(self.drsFileName);
            docRootNode=xmlDoc.getDocumentElement();

            cat={'input','output','param','dsm','data'};
            for ii=1:numel(cat)
                nWriteAllData(cat{ii});
            end

            for ii=1:numel(self.drsInfo.fcn)
                nWriteFcn(self.drsInfo.fcn(ii));
            end

            for ii=1:numel(self.arInfo.fcn)
                if~self.arInfo.fcn(ii).stubbed
                    nWriteARFcn(self.arInfo.fcn(ii));
                end
            end

            polyspace.util.XmlHelper.prettyWrite(xmlDoc,self.drsFileName);
            pslink.util.DrsHelper.writeDrsFile(self.drsFileName);

            if~isempty(errMsg)
                fprintf(1,'### %s\n',message('polyspace:gui:pslink:aborted',errMsg).getString());
                return
            end


            function fileNode=ngetOrCreateFileNode(docRootNode,fileName)
                fileNode=polyspace.util.XmlHelper.getOrAddNode(docRootNode,'file',[],'name',fileName,false);
                fileNode.setAttribute('comment','');
            end


            function structNode=ngetOrCreateStructNode(parentNode,structName)
                if~isempty(structName)
                    structNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'struct',[],'name',structName,false);
                else
                    structNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'struct',[],'','',false);
                end
                structNode.setAttribute('comment','');
                structNode.setAttribute('line','');
            end


            function pointerNode=ngetOrCreatePointerNode(parentNode,pointerName,pointerMode,pointerWidth,isDisabled)
                pointerNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'pointer',[],'name',pointerName,false);
                pointerNode.setAttribute('comment','');
                pointerNode.setAttribute('line','');
                pointerNode.setAttribute('complete_type','');
                if isDisabled


                    pointerNode.setAttribute('init_modes_allowed','1');
                    pointerNode.setAttribute('init_mode','disabled');
                    pointerNode.setAttribute('initialize_pointer','disabled');
                    pointerNode.setAttribute('number_allocated','disabled');
                    pointerNode.setAttribute('init_pointed','MULTI_CERTAIN_WRITE');
                else
                    pointerNode.setAttribute('init_modes_allowed',nSetInitModeAllowed(pointerMode));
                    pointerNode.setAttribute('init_mode',upper(pointerMode));
                    pointerNode.setAttribute('initialize_pointer','Not NULL');
                    pointerNode.setAttribute('number_allocated',num2str(pointerWidth));
                    pointerNode.setAttribute('init_pointed','MULTI');
                end
            end


            function arrayNode=ngetOrCreateArrayNode(parentNode,arrayName)
                if~isempty(arrayName)
                    arrayNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'array',[],'name',arrayName,false);
                else
                    arrayNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'array',[],'','',false);
                end
                arrayNode.setAttribute('comment','');
                arrayNode.setAttribute('line','');
                arrayNode.setAttribute('complete_type','');
            end


            function scalarNode=ngetOrCreateScalarNode(parentNode,scalName,scalMode,scalRange,isArgument)
                if~isempty(scalName)
                    scalarNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'scalar',[],'name',scalName,false);
                else
                    scalarNode=polyspace.util.XmlHelper.getOrAddNode(parentNode,'scalar',[],'','',false);
                end
                scalarNode.setAttribute('comment','');
                scalarNode.setAttribute('line','');
                scalarNode.setAttribute('base_type','');
                scalarNode.setAttribute('complete_type','');
                scalarNode.setAttribute('init_modes_allowed',nSetInitModeAllowed(scalMode));

                if strcmpi(scalMode,'init')||strcmpi(scalMode,'permanent')
                    scalarNode.setAttribute('init_mode',upper(scalMode));
                    scalarNode.setAttribute('init_range',scalRange);
                    if isArgument
                        scalarNode.setAttribute('global_assert','unsupported');
                        scalarNode.setAttribute('assert_range','unsupported');
                    else
                        scalarNode.setAttribute('global_assert','NO');
                        scalarNode.setAttribute('assert_range','');
                    end
                elseif strcmpi(scalMode,'globalassert')
                    scalarNode.setAttribute('init_mode','MAIN_GENERATOR');
                    scalarNode.setAttribute('init_range','');
                    scalarNode.setAttribute('global_assert','YES');
                    scalarNode.setAttribute('assert_range',scalRange);
                end
            end


            function fcnNode=ngetOrCreateFunctionNode(fileNode,fcnName)
                fcnNode=polyspace.util.XmlHelper.getOrAddNode(fileNode,'function',[],'name',fcnName,false);
                fcnNode.setAttribute('comment','');
                fcnNode.setAttribute('line','');
                fcnNode.setAttribute('main_generator_called','MAIN_GENERATOR');
            end


            function initModeAllowed=nSetInitModeAllowed(drsMode)
                switch lower(drsMode)
                case 'init'
                    initModeAllowed='2';
                case 'permanent'
                    initModeAllowed='4';
                case 'globalassert'
                    initModeAllowed='8';
                otherwise
                    initModeAllowed='15';
                end
            end

            function nWriteAllData(category)
                for jj=1:numel(self.drsInfo.(category))
                    varData=self.drsInfo.(category)(jj);

                    hasARDataStore=strcmpi(category,'dsm')&&~isempty(self.arInfo)&&~isempty(self.arInfo.dsm);

                    if hasARDataStore&&ismember(varData.expr,self.arInfo.dsm)
                        continue
                    end

                    if~varData.emit
                        continue
                    end


                    srcFileName=varData.sourceFile;
                    fileNode=ngetOrCreateFileNode(docRootNode,srcFileName);
                    parentNode=fileNode;

                    tokens=regexp(varData.expr,'\.','split');
                    tokElems=numel(tokens);
                    varName=tokens{tokElems};
                    varMode=varData.mode;


                    for kk=1:tokElems-1
                        structName=tokens{kk};
                        parentNode=ngetOrCreateStructNode(parentNode,structName);
                    end


                    if varData.isPtr
                        if generateCxxDrsOnPtr
                            continue
                        end
                        parentNode=ngetOrCreatePointerNode(parentNode,varName,varMode,varData.width,false);

                        varName='';
                    end

                    if~varData.isExtraData
                        if varData.isStruct&&~isempty(varData.field)

                            parentNode=ngetOrCreateStructNode(parentNode,varName);
                            for kk=1:size(varData.field,1)
                                [structParentNode,varName]=nCreateStructure(parentNode,varData.field{kk,1});

                                [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(varData.field{kk,2}{1},varData.field{kk,2}{2});
                                varRange=[minStr,'..',maxStr];
                                ngetOrCreateScalarNode(structParentNode,varName,varMode,varRange,true);
                            end
                        else

                            if varData.isArray
                                parentNode=ngetOrCreateArrayNode(parentNode,varName);
                                varName='';
                            end

                            if~varData.isFullDataTypeRange
                                [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(varData.min,varData.max);
                                varRange=[minStr,'..',maxStr];
                            else
                                varRange='min..max';
                            end
                            ngetOrCreateScalarNode(parentNode,varName,varMode,varRange,false);
                        end
                    end
                end
            end

            function nWriteFcn(datafct)

                srcFileName=datafct.sourceFile;
                fileNode=ngetOrCreateFileNode(docRootNode,srcFileName);


                fcnName=datafct.name;
                fcnNode=ngetOrCreateFunctionNode(fileNode,fcnName);

                for jj=1:numel(datafct.arg)
                    parentNode=fcnNode;
                    argData=datafct.arg(jj);


                    argName=['arg',num2str(argData.pos)];
                    argMode=argData.mode;


                    if argData.isPtr
                        if generateCxxDrsOnPtr
                            continue
                        end
                        parentNode=ngetOrCreatePointerNode(parentNode,argName,'init',argData.width,false);

                        argName='';
                    end

                    if~argData.emit
                        continue
                    end
                    if~argData.isExtraData
                        if argData.isStruct&&~isempty(argData.field)

                            parentNode=ngetOrCreateStructNode(parentNode,argName);
                            for kk=1:size(argData.field,1)
                                [structParentNode,argName]=nCreateStructure(parentNode,argData.field{kk,1});

                                [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(argData.field{kk,2}{1},argData.field{kk,2}{2});
                                argRange=[minStr,'..',maxStr];
                                ngetOrCreateScalarNode(structParentNode,argName,argMode,argRange,true);
                            end
                        else

                            if argData.isArray
                                parentNode=ngetOrCreateArrayNode(parentNode,argName);
                                argName='';
                            end

                            if~argData.isFullDataTypeRange
                                [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(argData.min,argData.max);
                                argRange=[minStr,'..',maxStr];
                            else
                                argRange='min..max';
                            end
                            ngetOrCreateScalarNode(parentNode,argName,argMode,argRange,true);
                        end
                    end
                end
            end

            function nWriteARFcn(fcn)

                srcFileName=fcn.sourceFile;
                fileNode=ngetOrCreateFileNode(docRootNode,srcFileName);


                fcnName=fcn.drsName;
                fcnNode=ngetOrCreateFunctionNode(fileNode,fcnName);
                returnName='return';

                if~isempty(fcn.return)


                    parentNode=fcnNode;
                    if fcn.return.isPtr
                        parentNode=ngetOrCreatePointerNode(parentNode,returnName,'permanent',fcn.return.width,false);

                        returnName='';
                    end
                    if~fcn.return.emit
                        return
                    end
                    if~fcn.return.isStruct
                        [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(fcn.return.min,fcn.return.max);
                        argRange=[minStr,'..',maxStr];
                        ngetOrCreateScalarNode(parentNode,returnName,'permanent',argRange,true);
                    else
                        if~isempty(fcn.return.field)
                            parentNode=ngetOrCreateStructNode(parentNode,returnName);
                            for kk=1:size(fcn.return.field,1)
                                [structParentNode,leafName]=nCreateStructure(parentNode,fcn.return.field{kk,1});

                                if fcn.return.isFullDataTypeRange
                                    argRange='min..max';
                                else
                                    [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(...
                                    fcn.return.field{kk,2}{1},fcn.return.field{kk,2}{2});
                                    argRange=[minStr,'..',maxStr];
                                end
                                ngetOrCreateScalarNode(structParentNode,leafName,'permanent',argRange,true);
                            end
                        end
                    end
                end

                if~isempty(fcn.arg)
                    for jj=1:numel(fcn.arg)
                        argName=['arg',num2str(fcn.arg(jj).pos)];
                        parentNode=fcnNode;
                        if strcmpi(fcn.arg(jj).direction,'in')
                            strInit='permanent';

                            isDisabled=true;
                        elseif strcmpi(fcn.arg(jj).direction,'out')
                            strInit='permanent';

                            isDisabled=true;
                        else
                            strInit='init';
                            isDisabled=false;
                        end
                        if fcn.arg(jj).isPtr
                            parentNode=ngetOrCreatePointerNode(parentNode,argName,'init',fcn.arg(jj).width,isDisabled);

                            argName='';
                        end
                        if~fcn.arg(jj).emit
                            continue
                        end

                        if~fcn.arg(jj).isStruct
                            [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(...
                            fcn.arg(jj).min,fcn.arg(jj).max);
                            argRange=[minStr,'..',maxStr];
                            ngetOrCreateScalarNode(parentNode,argName,strInit,argRange,true);
                        else
                            if~isempty(fcn.arg(jj).field)
                                parentNode=ngetOrCreateStructNode(parentNode,argName);
                                for kk=1:size(fcn.arg(jj).field,1)
                                    [structParentNode,leafName]=nCreateStructure(parentNode,fcn.arg(jj).field{kk,1});

                                    if fcn.arg(jj).isFullDataTypeRange
                                        argRange='min..max';
                                    else
                                        [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(...
                                        fcn.arg(jj).field{kk,2}{1},fcn.arg(jj).field{kk,2}{2});
                                        argRange=[minStr,'..',maxStr];
                                    end
                                    ngetOrCreateScalarNode(structParentNode,leafName,strInit,argRange,true);
                                end
                            end
                        end
                    end
                end
            end

            function[node,leafName]=nCreateStructure(parentNode,field)
                node=parentNode;
                structTokens=regexp(field,'\.','split');
                structTokElems=numel(structTokens);
                leafName=structTokens{structTokElems};
                for ll=1:structTokElems-1
                    structName=structTokens{ll};
                    node=ngetOrCreateStructNode(node,structName);
                end
            end
        end




        function writeLinksDataFile(self)%#ok<MANU>
        end






        function ovwOpts=getOverwrittenOptions(self)
            ovwOpts=[];


            ovwOpts.main_generator='true';

            ovwOpts.language=self.fcnInfo.codeLanguage;
            if~isempty(self.fcnInfo.className)
                ovwOpts.class_analyser{1}=self.fcnInfo.className{1};
            end

            if~isempty(self.drsFileName)
                ovwOpts.drs_file=self.drsFileName;
            end

            if~isempty(self.fileInfo.include)
                ovwOpts.include=self.fileInfo.include;
            end
            if~isempty(self.fileInfo.define)
                ovwOpts.define=self.fileInfo.define;
            end
            if isfield(self.fileInfo,'undefine')&&~isempty(self.fileInfo.undefine)
                ovwOpts.undefine=self.fileInfo.undefine;
            end
            if isfield(self.fileInfo,'extra_headers')&&~isempty(self.fileInfo.extra_headers)
                ovwOpts.extra_headers=self.fileInfo.extra_headers;
            end

            if~isempty(self.coderObj.booleanTypes)
                ovwOpts.booleanTypes=self.coderObj.booleanTypes;
            end

            if~isempty(self.coderObj.fcnToStub)
                ovwOpts.fcn_to_stub=self.coderObj.fcnToStub;
            end

            if isprop(self.coderObj,'cgStdLang')
                if strncmpi(self.coderObj.cgLanguage,'C++',3)
                    ovwOpts.cpp_version=self.coderObj.cgStdLang;
                else
                    ovwOpts.c_version=self.coderObj.cgStdLang;
                end
            end

            if~isempty(self.fcnInfo.step)&&~self.fcnInfo.mustWriteAllData
                allStepFcn={};
                allStepVar={};
                for ii=1:numel(self.fcnInfo.step)
                    allStepFcn=[allStepFcn,self.fcnInfo.step(ii).fcn];%#ok<AGROW>
                    allStepVar=[allStepVar,self.fcnInfo.step(ii).var];%#ok<AGROW>
                end
                allStepFcn=unique(allStepFcn);
                allStepVar=unique(allStepVar);

                if~isempty(allStepFcn)
                    ovwOpts.fcn_in_loop=allStepFcn;
                end
                if~isempty(allStepVar)
                    ovwOpts.var_in_loop=allStepVar;
                else
                    ovwOpts.var_in_loop{1}='none';
                end
                if~isempty(self.fcnInfo.init)&&~isempty(self.fcnInfo.init.fcn)
                    ovwOpts.fcn_before_loop=self.fcnInfo.init.fcn;
                end
                if~isempty(self.fcnInfo.init)&&~isempty(self.fcnInfo.init.var)
                    ovwOpts.var_before_loop=self.fcnInfo.init.var;
                else
                    ovwOpts.var_before_loop{1}='none';
                end
                if~isempty(self.fcnInfo.term)&&~isempty(self.fcnInfo.term.fcn)
                    ovwOpts.fcn_after_loop=self.fcnInfo.term.fcn;
                end

            elseif~isempty(self.fcnInfo.step)&&self.fcnInfo.mustWriteAllData
                allStepFcn={};
                for ii=1:numel(self.fcnInfo.step)
                    allStepFcn=[allStepFcn,self.fcnInfo.step(ii).fcn];%#ok<AGROW>
                end
                if~isempty(allStepFcn)
                    ovwOpts.fcn_in_loop=allStepFcn;
                else
                    ovwOpts.fcn_in_loop={'none'};
                end
                if~isempty(self.fcnInfo.init)&&~isempty(self.fcnInfo.init.fcn)
                    ovwOpts.fcn_before_loop{1}=self.fcnInfo.init.fcn{1};
                end
                if~isempty(self.fcnInfo.term)&&~isempty(self.fcnInfo.term.fcn)
                    ovwOpts.fcn_after_loop{1}=self.fcnInfo.term.fcn{1};
                end
                if~isempty(self.arInfo.fcn)

                    ovwOpts.var_in_loop{1}='none';
                else
                    ovwOpts.var_in_loop{1}='all';
                end
                ovwOpts.var_before_loop{1}='all';
            else

                if strcmpi(ovwOpts.language,'C++ (Encapsulated)')
                    ovwOpts.class_analyser{1}='all';
                    ovwOpts.fcn_in_loop{1}='all';
                    ovwOpts.var_in_loop{1}='none';
                    ovwOpts.var_before_loop{1}='all';
                else
                    if~isempty(self.arInfo.fcn)

                        ovwOpts.var_in_loop{1}='none';
                    else
                        ovwOpts.var_in_loop{1}='all';
                    end
                    ovwOpts.var_before_loop{1}='all';
                    ovwOpts.fcn_in_loop={'none'};
                end
            end
        end
    end

    methods(Abstract,Access=public)




        hasError=checkConfiguration(self,systemName,pslinkOptions)
        packageName=getPackageName(self)

    end

    methods(Static=true)



        function obj=createOptionSetObject(coderID,varargin)
            if strcmpi(coderID,pslink.verifier.ec.Coder.CODER_ID)
                obj=pslink.verifier.ec.OptionSet(varargin{:});
            elseif strcmpi(coderID,pslink.verifier.tl.Coder.CODER_ID)
                obj=pslink.verifier.tl.OptionSet(varargin{:});
            else
                obj=[];
            end
        end

        function str=endDrsFileName()
            str='_drs.xml';
        end




        function ovwOpts=fixOptsFromSettings(self,ovwOpts,pslinkOptions)%#ok<INUSL,INUSD>
        end
    end

end





