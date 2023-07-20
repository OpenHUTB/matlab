

classdef SubsystemFunctionMapping


    methods(Static,Access=public)
        function validate(model,fcnName)
            import coder.dictionary.internal.*;

            cTargetMapping=SubsystemFunctionMapping.getTargetMapping(model,fcnName);
            funcMappingObj=SubsystemFunctionMapping.getFunctionObj(cTargetMapping,fcnName);




            if isempty(funcMappingObj)
                return;
            end
            if isempty(funcMappingObj.MappedTo)
                DAStudio.error('coderdictionary:api:NoMappedTo',fcnName);
            end

            SubsystemFunctionMapping.validateFunctionPrototype(model,fcnName,...
            funcMappingObj.MappedTo.Prototype,false);
        end

        function validateAll(model)
            import coder.dictionary.internal.*;
            mmgr=get_param(model,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            cTargetMapping=mmgr.getActiveMappingFor('CoderDictionary');
            if isempty(cTargetMapping)
                return;
            end

            if isempty(cTargetMapping.SimulinkFunctionCallerMappings)
                return;
            end
            for i=1:length(cTargetMapping.SimulinkFunctionCallerMappings)
                currentMapping=cTargetMapping.SimulinkFunctionCallerMappings(i);
                if isempty(currentMapping)||isempty(currentMapping.SimulinkFunctionName)
                    continue;
                end
                SubsystemFunctionMapping.validate(model,currentMapping.SimulinkFunctionName);
            end

            SubsystemFunctionMapping.compileTimeChecks(...
            model,...
            @()Simulink.CoderDictionary.checkMappingsToStateflowFcns(get_param(model,'handle')),...
            @()Simulink.CoderDictionary.checkModelRefFPC(get_param(model,'handle')));
        end

        function compileTimeChecks(model,varargin)
            import coder.dictionary.internal.*;
            termCompilation=compileModelForRTW(model);
            for i=1:length(varargin)
                varargin{i}();
            end
            termCompilation.delete();
        end



        function out=getField(model,fcnName,field)
            import coder.dictionary.internal.*;
            noMapping=false;
            cTargetMapping=SubsystemFunctionMapping.getTargetMapping(model,fcnName);
            funcObj=SubsystemFunctionMapping.getFunctionObj(cTargetMapping,fcnName);
            if isempty(funcObj)
                noMapping=true;
            end




            lowerCaseField=lower(field);
            switch(lowerCaseField)
            case 'codeprototype'
                if noMapping
                    outStruct=SubsystemFunctionMapping.getDefaultStruct(model,fcnName);
                    out=outStruct.CodePrototype;
                else
                    out=funcObj.MappedTo.Prototype;
                end
            otherwise
                DAStudio.error('coderdictionary:api:UnrecognizedName',field);
            end
        end



        function out=get(model,fcnName)
            import coder.dictionary.internal.*;

            cTargetMapping=SubsystemFunctionMapping.getTargetMapping(model,fcnName);
            funcObj=SubsystemFunctionMapping.getFunctionObj(cTargetMapping,fcnName);

            if~isempty(funcObj)
                out.CodePrototype=funcObj.MappedTo.Prototype;
            else


                out=SubsystemFunctionMapping.getDefaultStruct(model,fcnName);
            end
        end



        function set(model,fcnName,varargin)
            import coder.dictionary.internal.*;

            newCodePrototype='';
            for i=1:2:length(varargin)
                name=varargin{i};
                value=varargin{i+1};
                if(~ischar(name))
                    DAStudio.error('coderdictionary:api:NameValuePairNeedsStringForName',name);
                end


                lowerCaseName=lower(name);
                switch lowerCaseName
                case 'codeprototype'
                    if~ischar(value)
                        DAStudio.error('coderdictionary:api:NameValuePairNeedsStringForValue',name);
                    end
                    newCodePrototype=value;
                otherwise
                    DAStudio.error('coderdictionary:api:UnrecognizedName',name);
                end
            end


            coderDictMapping=SubsystemFunctionMapping.getOrCreateCoderDictMapping(model);
            cache=SubsystemFunctionMapping.get(model,fcnName);


            if isempty(newCodePrototype)
                newCodePrototype=cache.CodePrototype;
            end



            func=SubsystemFunctionMapping.getParsedFunction(newCodePrototype);
            SubsystemFunctionMapping.validateUseOfRenaming(model,func,fcnName);

            funcObj=[];
            funcObj=SubsystemFunctionMapping.setPrototype(model,fcnName,coderDictMapping,newCodePrototype,funcObj);
            if~isempty(funcObj)

                coderDictMapping.addSimulinkFunctionMapping(fcnName,funcObj);
            end
        end

        function flattenedStr=validateAndReturnFcnName(modelName,fcnName,codeFcnName)

            if isempty(codeFcnName)
                DAStudio.error('coderdictionary:api:EmptyFunctionName',fcnName);
            end


            cs=getActiveConfigSet(modelName);
            try
                Simulink.ConfigSet.validateSymbol(cs,'CustomSymbolStrModelFcn',codeFcnName);
            catch me
                switch me.identifier
                case 'Simulink:Engine:SfsTooLong'
                    DAStudio.error('coderdictionary:api:IdentifierTooLong',codeFcnName);
                otherwise
                    rethrow(me);
                end
            end


            flattenedStr=slInternal('getIdentifierUsingNamingService',...
            modelName,codeFcnName,fcnName);
            loc_checkFlattenedStr(flattenedStr,codeFcnName);
        end


        function flattenedStr=validateAndReturnArgName(modelName,...
            designArgName,codeArgName,inOut)
            cs=getActiveConfigSet(modelName);
            try
                Simulink.ConfigSet.validateSymbol(cs,'CustomSymbolStrModelFcnArg',codeArgName);
            catch me
                switch me.identifier
                case 'Simulink:Engine:SfsTooLong'
                    DAStudio.error('coderdictionary:api:IdentifierTooLong',codeArgName);
                otherwise
                    rethrow(me);
                end
            end
            flattenedStr=slInternal('getIdentifierUsingNamingService',...
            modelName,codeArgName,designArgName,inOut);
            loc_checkFlattenedStr(flattenedStr,codeArgName);
        end


        function out=hasCoderDictMapping(mdl)
            model=get_param(mdl,'Name');
            mmgr=get_param(model,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            coderDictMapping=mmgr.getActiveMappingFor('CoderDictionary');
            out=~isempty(coderDictMapping);
        end


        function coderDictMapping=getOrCreateCoderDictMapping(mdl)


            model=get_param(mdl,'Name');
            mmgr=get_param(model,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            coderDictMapping=mmgr.getActiveMappingFor('CoderDictionary');
            if isempty(coderDictMapping)
                mappingName=['CoderDictionary_',model];
                mappingName=matlab.lang.makeValidName(mappingName);
                mmgr.createMapping(mappingName,'CoderDictionary');
                mmgr.activateMapping(mappingName);
                coderDictMapping=mmgr.getActiveMappingFor('CoderDictionary');

                coderDictMapping.sync();
            end
        end





        function out=createDefaultFunctionPrototypeFromBlock(blkHandle,varargin)
            constructSmartDefaultIfPossible=false;
            if nargin==2
                constructSmartDefaultIfPossible=varargin{1};
            end

            blk=getfullname(blkHandle);
            modelName=strtok(getfullname(blk),'/');
            hasMapping=...
            coder.dictionary.internal.SubsystemFunctionMapping.hasCoderDictMapping(modelName);
            if constructSmartDefaultIfPossible



                [~,~]=...
                coder.dictionary.internal.SubsystemFunctionMapping.getArgInAndArgOutProperties(blk);




                constructSmartDefaultIfPossible=...
                constructSmartDefaultIfPossible&&...
                hasMapping;
            end

            [inArgs,outArgs,fcnName]=...
            coder.dictionary.internal.SubsystemFunctionMapping.getSLFcnInOutArgs(blk);

            inOutArgs=intersect(inArgs,outArgs,'stable');




            scalarOutputDefault=false;

            if coder.dictionary.internal.SubsystemFunctionMapping.isPublicFcn(blk,fcnName)
                codeFcnName=fcnName;
                renamedArg='';
                pointerForOut='';
            else
                codeFcnName='$N';
                renamedArg=[' ',get_param(modelName,'CustomSymbolStrFcnArg')];
                pointerForOut='*';
            end

            if constructSmartDefaultIfPossible
                [~,outArgsProp]=...
                coder.dictionary.internal.SubsystemFunctionMapping.getArgInAndArgOutProperties(blk);

                if length(outArgs)==1&&...
                    isempty(intersect(inOutArgs,outArgs))



                    if isempty(outArgsProp)
                        blkPath=[blk,'/',outArgs{1}];
                        dataType=get_param(blkPath,'OutDataTypeStr');
                        isBus=~isempty(regexp(dataType,'^Bus:','once'));
                        dimensions=slResolve(...
                        get_param(blkPath,'PortDimensions'),blkPath);
                        isScalar=prod(dimensions)==1;
                        isComplex=strcmp(get_param(blkPath,...
                        'SignalType'),'complex');
                    else
                        isBus=outArgsProp.IsBus;
                        isImage=outArgsProp.IsImage;
                        isScalar=outArgsProp.IsScalar;
                        isComplex=outArgsProp.IsComplex;
                    end

                    if isScalar&&~isComplex&&~isBus&&~isImage
                        out=[outArgs{1},'=',codeFcnName,'('];
                        scalarOutputDefault=true;
                    else
                        out=[codeFcnName,'('];
                    end
                else
                    out=[codeFcnName,'('];
                end
            else
                out=[codeFcnName,'('];
            end


            inArgs=setdiff(inArgs,inOutArgs,'stable');
            comma='';
            for i=1:length(inArgs)
                out=[out,comma,inArgs{i},renamedArg];%#ok<AGROW>
                comma=',';
            end



            if~scalarOutputDefault
                for i=1:length(outArgs)
                    out=[out,comma,pointerForOut,outArgs{i},renamedArg];%#ok<AGROW>
                    comma=',';
                end
            end
            out=[out,')'];
        end




        function varargout=validateFunctionPrototype(model,...
            fcnName,fcnPrototype,returnCImpl,varargin)

            cImpl='';




            fcnBlock=coder.dictionary.internal.SubsystemFunctionMapping.getSimulinkFunctionOrCallerBlock(...
            model,fcnName);
            if isempty(fcnBlock)
                if~returnCImpl



                    DAStudio.error(...
                    'RTW:codeGen:NoSLFcnOrCallerForFunctionName',fcnName);
                else








                    varargout{1}=cImpl;
                    return;
                end
            end



            [inArgs,outArgs,~]=...
            coder.dictionary.internal.SubsystemFunctionMapping.getSLFcnInOutArgs(fcnBlock);




            [inArgsProp,outArgsProp]=...
            coder.dictionary.internal.SubsystemFunctionMapping.getArgInAndArgOutProperties(fcnBlock);

            func=coder.dictionary.internal.SubsystemFunctionMapping.getParsedFunction(fcnPrototype);



            coder.dictionary.internal.SubsystemFunctionMapping.validateUseOfRenaming(model,func,fcnName);





            if~strcmp(func.name,fcnName)
                coder.dictionary.internal.SubsystemFunctionMapping.validateAndReturnFcnName(model,fcnName,func.name);
            end


            inOutArgs=intersect(inArgs,outArgs,'stable');
            hasInOutArgs=~isempty(inOutArgs);

            flatCodeArguments={};
            codeArguments={};
            for argIdx=1:length(func.arguments)
                arg=func.arguments{argIdx};

                codeArgName=arg.name;
                if~isempty(arg.mappedFrom)
                    designArgName=arg.mappedFrom{1};
                else
                    designArgName=codeArgName;
                end

                if(hasInOutArgs&&...
                    ~isempty(find(strcmp(designArgName,inOutArgs),1)))
                    inOut='inout';
                elseif~isempty(find(strcmp(designArgName,outArgs),1))
                    inOut='out';
                else
                    inOut='in';
                end

                flattenedArg=coder.dictionary.internal.SubsystemFunctionMapping.validateAndReturnArgName(...
                model,designArgName,codeArgName,inOut);

                flatCodeArguments=[flatCodeArguments,{flattenedArg}];%#ok<AGROW>   
                codeArguments=[codeArguments,{codeArgName}];%#ok<AGROW>
            end





            if~isempty(codeArguments)
                hasMangleSymbol=cellfun(@(x)contains(x,'$M'),...
                codeArguments);
                flatCodeArguments(hasMangleSymbol)=[];
            end

            if length(flatCodeArguments)>length(unique(flatCodeArguments))
                DAStudio.error('coderdictionary:api:UniqueCodeArguments');
            end


            cImpl=RTW.CImplementation;
            flattenedStr=slInternal('getIdentifierUsingNamingService',...
            model,func.name,fcnName);
            cImpl.Name=flattenedStr;
            cImpl.Return=[];


            if~isempty(func.returnArguments)
                if length(func.returnArguments)~=1
                    DAStudio.error('RTW:codeGen:MultipleReturnArgs',fcnPrototype);
                end

                retArgName=func.returnArguments{1}.name;
                if~isempty(func.returnArguments{1}.mappedFrom)


                    DAStudio.error('coderdictionary:api:CannotRenameReturnArgument',retArgName);
                end

                portIdx=find(strcmp(retArgName,outArgs),1);
                if isempty(portIdx)
                    DAStudio.error('RTW:codeGen:ReturnArgumentNotFound',...
                    retArgName,fcnPrototype);
                end

                if~isempty(find(strcmp(retArgName,inArgs),1))

                    DAStudio.error('RTW:codeGen:InputArgsAsReturn',...
                    retArgName,fcnPrototype);
                end

                if~isequal(func.returnArguments{1}.qualifier,...
                    coder.parser.Qualifier.None)



                    DAStudio.error('RTW:codeGen:ReturnArgumentQualifier',...
                    retArgName);
                end



                retArgProp=outArgsProp(arrayfun(@(x)isequal(x.Name,...
                retArgName),outArgsProp));


                if retArgProp.IsComplex
                    DAStudio.error('RTW:codeGen:ReturnArgumentComplex',...
                    retArgName);
                end


                if~coder.dictionary.internal.SubsystemFunctionMapping.canArgBePassedByValue(retArgProp)
                    DAStudio.error('RTW:codeGen:ReturnArgumentNonScalar',...
                    retArgName);
                end




                tmpRet=RTW.Argument;
                tmpRet.IOType='RTW_IO_OUTPUT';
                tmpRet.Name=[num2str(portIdx),':',retArgName];
                cImpl.Return=tmpRet;
            end

            slFcnArgs=[inArgs,outArgs];
            fcnProtoArgs=cell(1,length(func.arguments)+...
            length(func.returnArguments));
            for inArgIdx=1:length(func.arguments)
                fcnProtoArgs{inArgIdx}=func.arguments{inArgIdx}.name;
                if~isempty(func.arguments{inArgIdx}.mappedFrom)
                    fcnProtoArgs{inArgIdx}=func.arguments{inArgIdx}.mappedFrom{1};
                end
            end
            if~isempty(func.returnArguments)
                fcnProtoArgs{end}=func.returnArguments{1}.name;
                if~isempty(func.returnArguments{1}.mappedFrom)
                    fcnProtoArgs{end}=func.returnArguments{1}.mappedFrom{1};
                end
            end

            argsNotInProto=setdiff(slFcnArgs,fcnProtoArgs);
            if~isempty(argsNotInProto)
                DAStudio.error('RTW:codeGen:UnderspecifiedArguments',...
                fcnPrototype,fcnBlock);
            end



            allArgs=RTW.Argument.empty(length(func.arguments),0);
            for ii=1:length(func.arguments)
                supportVoidPointerArg=false;
                argName=func.arguments{ii}.name;
                if~isempty(func.arguments{ii}.mappedFrom)
                    argName=func.arguments{ii}.mappedFrom{1};
                end
                argProp=inArgsProp(arrayfun(@(x)isequal(x.Name,...
                argName),inArgsProp));

                tmpArg=RTW.Argument;
                tmpArg.Name=argName;

                if(~isempty(find(ismember(inArgs,argName),1))&&...
                    isempty(find(ismember(outArgs,argName),1)))
                    tmpArg.IOType='RTW_IO_INPUT';
                    supportVoidPointerArg=isaSupportedVoidPtrArg(func.arguments{ii},'RTW_IO_INPUT');

                    if isequal(func.arguments{ii}.passBy,...
                        coder.parser.PassByEnum.Value)



                        if~isequal(func.arguments{ii}.qualifier,...
                            coder.parser.Qualifier.None)

                            DAStudio.error('RTW:codeGen:InputArgumentScalarQualifier',...
                            argName);
                        end

                    else


                        if~isequal(func.arguments{ii}.qualifier,...
                            coder.parser.Qualifier.Const)





                            DAStudio.error('RTW:codeGen:InputArgumentNonScalarConstQualifier',...
                            argName);
                        end

                        if~supportVoidPointerArg&&coder.dictionary.internal.SubsystemFunctionMapping.canArgBePassedByValue(argProp)





                            pointerType=embedded.pointertype;
                            pointerType.BaseType=embedded.numerictype;
                            pointerType.BaseType.ReadOnly=1;

                            tmpArg.Type=pointerType;
                        end
                    end

                elseif~isempty(find(ismember(inArgs,argName),1))
                    tmpArg.IOType='RTW_IO_INPUT_OUTPUT';
                    if~isequal(func.arguments{ii}.qualifier,...
                        coder.parser.Qualifier.None)
                        DAStudio.error('RTW:codeGen:OutOrInOutArgumentQualifier',...
                        argName);
                    end
                elseif~isempty(find(ismember(outArgs,argName),1))
                    tmpArg.IOType='RTW_IO_OUTPUT';
                    supportVoidPointerArg=isaSupportedVoidPtrArg(func.arguments{ii},'RTW_IO_OUTPUT');
                    if~isequal(func.arguments{ii}.qualifier,...
                        coder.parser.Qualifier.None)
                        DAStudio.error('RTW:codeGen:OutOrInOutArgumentQualifier',...
                        argName);
                    end
                else

                    DAStudio.error('RTW:codeGen:ArgumentNotFound',...
                    argName,fcnPrototype);
                end


                if(supportVoidPointerArg)
                    tmpArg.Type=embedded.pointertype;
                    tmpArg.Type.BaseType=embedded.voidtype;
                    if(isequal(func.arguments{ii}.qualifier,coder.parser.Qualifier.Const))
                        tmpArg.Type.BaseType.ReadOnly=true;
                    end
                end

                allArgs(ii)=tmpArg;
            end
            cImpl.Arguments=allArgs;
            if returnCImpl
                varargout{1}=cImpl;
            end
        end
        function out=isPublicFcn(blk,fcnName)
            defFcnInfo='';
            if~isnumeric(blk)
                blk=get_param(blk,'handle');
            end
            fcns=Simulink.FunctionGraphCatalog(blk);
            for i=1:length(fcns)
                fcn=fcns(i);
                if strcmp(fcn.name,fcnName)
                    defFcnInfo=fcn;
                    break;
                end
            end
            if~isempty(defFcnInfo)
                if~strcmp(get_param(defFcnInfo.handle,'BlockType'),'ModelReference')
                    mdlName=get_param(bdroot(defFcnInfo.handle),'name');
                    if strcmp(get_param(defFcnInfo.handle,'parent'),mdlName)

                        trigPort=find_system(defFcnInfo.handle,'BlockType','TriggerPort');
                        if strcmp(get_param(trigPort,'FunctionVisibility'),'global')

                            out=false;
                        elseif strcmp(get_param(trigPort,'FunctionVisibility'),'scoped')

                            out=true;
                        else
                            out=false;
                        end
                    else

                        out=false;
                    end
                else

                    out=false;
                end
            else

                out=false;
            end
        end
        function[out,configsetSymbol]=getFcnName(~,~,codeName)

            configsetSymbol='$N';
            out=codeName;
        end
        function out=getCodeFunctionName(fcnPrototype)
            func=coder.dictionary.internal.SubsystemFunctionMapping.getParsedFunction(fcnPrototype);
            out=func.name;
        end






        function[codeInArgs,codeOutArgs]=getCodeInputOutputArguments(blk,fcnPrototype)

            [inArgs,outArgs,~]=...
            coder.dictionary.internal.SubsystemFunctionMapping.getSLFcnInOutArgs(blk);


            inOutArgs=intersect(inArgs,outArgs,'stable');
            hasInOutArgs=~isempty(inOutArgs);


            func=coder.dictionary.internal.SubsystemFunctionMapping.getParsedFunction(fcnPrototype);


            argMap=containers.Map;
            for i=1:length(func.arguments)
                arg=func.arguments{i};
                codeName=arg.name;
                if~isempty(arg.mappedFrom)
                    designName=arg.mappedFrom{1};
                else
                    designName=codeName;
                end
                inoutArgStr='';
                if(hasInOutArgs&&...
                    ~isempty(find(strcmp(designName,inOutArgs),1)))
                    inoutArgStr=':1';
                end
                argMap(designName)=[codeName,inoutArgStr];
            end

            if~isempty(func.returnArguments)
                codeName=func.returnArguments{1}.name;
                if~isempty(func.returnArguments{1}.mappedFrom)
                    designName=func.returnArguments{1}.mappedFrom{1};
                else
                    designName=codeName;
                end
                inoutArgStr='';
                if(hasInOutArgs&&...
                    ~isempty(find(strcmp(designName,inOutArgs),1)))
                    inoutArgStr=':1';
                end
                argMap(designName)=[codeName,inoutArgStr];
            end



            codeInArgs=cellfun(@(x)strcat(x,':',argMap(x)),inArgs,...
            'UniformOutput',false);
            codeOutArgs=cellfun(@(x)strcat(x,':',argMap(x)),outArgs,...
            'UniformOutput',false);
        end



        function cImpl=validateAndConstructCImplementation(model,...
            fcnName,fcnPrototype)

            cImpl=coder.dictionary.internal.SubsystemFunctionMapping.validateFunctionPrototype(...
            model,fcnName,fcnPrototype,true);
        end


        function isModel=isSimulinkModel(modelName)
            isModel=false;
            try
                mdlObj=get_param(modelName,'Object');
                if isa(mdlObj,'Simulink.Object')
                    isModel=true;
                end
            catch e %#ok<NASGU>

            end
        end




        function fcnBlock=getSimulinkFunctionOrCallerBlock(model,fcnName)
            fcnBlock=coder.dictionary.internal.SubsystemFunctionMapping.getSimulinkFunctionBlock(...
            model,fcnName);

            if isempty(fcnBlock)
                fcnBlock=coder.dictionary.internal.SubsystemFunctionMapping.getFunctionCallerBlock(...
                model,fcnName);
            end
        end


        function[inArgs,outArgs,fcnName]=getFcnInOutArgs(blk)


            fcnName='';
            if strcmp(get_param(blk,'BlockType'),'SubSystem')
                fcnName=get_param(blk,'Name');
                inports=find_system(getfullname(blk),'BlockType','Inport');
                outports=find_system(getfullname(blk),'BlockType','Outport');
                inArgs=cell(length(inports),1);
                outArgs=cell(length(outports),1);
                for i=1:length(inports)
                    inArgs(i)=get_param(inports(i),'Name');
                end



                for i=1:length(outports)
                    outArgs(i)=get_param(outports(i),'Name');
                end

















            end
        end
        function doEditTimeModelChecks(model)
            import coder.dictionary.internal.*;

            if~SubsystemFunctionMapping.isSimulinkModel(model)
                DAStudio.error('RTW:codeGen:InvalidModelFcnPrototype',model);
            end
            if(modelIsLibrary(model))
                DAStudio.error('coderdictionary:api:LibrariesNotSupported');
            end


            isERTDerived=strcmp(get_param(model,'IsERTTarget'),'on');
            if isERTDerived
                isAUTOSAR=strcmp(get_param(model,'SystemTargetFile'),'autosar.tlc');
                if isAUTOSAR
                    DAStudio.error('coderdictionary:api:AUTOSARNotSupported');
                end
            else
                DAStudio.error('coderdictionary:api:ERTTargetOnlySupported');
            end
        end

        function checkLanguage(~,~)
            return;
        end

        function validatePublicFunction(model,fcnName,varargin)
            fcnBlock=coder.dictionary.internal.SubsystemFunctionMapping.getSimulinkFunctionOrCallerBlock(...
            model,fcnName);
            if isempty(fcnBlock)

                return;
            end

            [isPublic,~,~,~]=...
            coder.mapping.internal.isPublicSimulinkFunction(fcnBlock);
            if~isPublic
                return;
            end
            if isequal(get_param(fcnBlock,'BlockType'),'FunctionCaller')
                DAStudio.error(...
                'RTW:codeGen:PublicFunctionCallerSpecification',fcnName);
            end
        end
    end

    methods(Static,Access=public,Hidden=true)
        function removeMapping(modelName,fcnName)
            mmgr=get_param(modelName,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            coderDictMapping=mmgr.getActiveMappingFor('CoderDictionary');
            if~isempty(coderDictMapping)
                coderDictMapping.removeSimulinkFunctionMapping(fcnName);
            end
        end





        function[inArgsProp,outArgsProp]=getArgInAndArgOutProperties(blk)
            if(strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
                strcmp(get_param(blk,'IsSimulinkFunction'),'on'))

                inArgs=find_system(blk,'SearchDepth',1,'BlockType','ArgIn');
                outArgs=find_system(blk,'SearchDepth',1,'BlockType','ArgOut');

                inArgsProp=struct([]);
                outArgsProp=struct([]);

                for inIdx=1:length(inArgs)
                    inArgsProp(inIdx).Name=get_param(inArgs{inIdx},...
                    'ArgumentName');
                    dataType=get_param(inArgs{inIdx},'OutDataTypeStr');
                    inArgsProp(inIdx).IsBus=...
                    ~isempty(regexp(dataType,'^Bus:','once'));
                    dimensions=slResolve(...
                    get_param(inArgs{inIdx},'PortDimensions'),inArgs{inIdx});
                    inArgsProp(inIdx).IsScalar=prod(dimensions)==1;
                    inArgsProp(inIdx).IsComplex=strcmp(get_param(inArgs{inIdx},...
                    'SignalType'),'complex');
                end

                for outIdx=1:length(outArgs)
                    outArgsProp(outIdx).Name=get_param(outArgs{outIdx},...
                    'ArgumentName');
                    dataType=get_param(outArgs{outIdx},'OutDataTypeStr');
                    outArgsProp(outIdx).IsBus=...
                    ~isempty(regexp(dataType,'^Bus:','once'));
                    dimensions=slResolve(...
                    get_param(outArgs{outIdx},'PortDimensions'),outArgs{outIdx});
                    outArgsProp(outIdx).IsScalar=prod(dimensions)==1;
                    outArgsProp(outIdx).IsComplex=strcmp(get_param(outArgs{outIdx},...
                    'SignalType'),'complex');
                end

            elseif strcmp(get_param(blk,'BlockType'),'FunctionCaller')

                [inArgs,outArgs,~]=...
                coder.dictionary.internal.SubsystemFunctionMapping.getSLFcnInOutArgs(blk);

                inArgSpecs=get_param(blk,'InputArgumentSpecifications');
                outArgSpecs=get_param(blk,'OutputArgumentSpecifications');
                inArgsProp=struct([]);
                outArgsProp=struct([]);





                if~isempty(inArgs)
                    if strcmp(inArgSpecs,'<Enter example>')||...
                        strcmp(inArgSpecs,'')
                        DAStudio.error('RTW:codeGen:UnsetArgumentSpecifications',...
                        blk);
                    end
                    inArgsPropInfo=Simulink.CoderDictionary.parseArgumentSpecifications(...
                    get_param(blk,'Handle'),...
                    'InputArgumentSpecifications',inArgSpecs,length(inArgs));
                    for inIdx=1:length(inArgs)
                        inArgsProp(inIdx).Name=inArgs{inIdx};
                        inArgsProp(inIdx).IsBus=inArgsPropInfo(inIdx).IsBus;
                        inArgsProp(inIdx).IsScalar=inArgsPropInfo(inIdx).IsScalar;
                        inArgsProp(inIdx).IsImage=inArgsPropInfo(inIdx).IsImage;
                        inArgsProp(inIdx).IsComplex=inArgsPropInfo(inIdx).IsComplex;
                    end
                end
                if~isempty(outArgs)
                    if strcmp(outArgSpecs,'<Enter example>')||...
                        strcmp(outArgSpecs,'')
                        DAStudio.error('RTW:codeGen:UnsetArgumentSpecifications',...
                        blk);
                    end
                    outArgsPropInfo=Simulink.CoderDictionary.parseArgumentSpecifications(...
                    get_param(blk,'Handle'),...
                    'OutputArgumentSpecifications',outArgSpecs,length(outArgs));
                    for outIdx=1:length(outArgs)
                        outArgsProp(outIdx).Name=outArgs{outIdx};
                        outArgsProp(outIdx).IsBus=outArgsPropInfo(outIdx).IsBus;
                        outArgsProp(outIdx).IsScalar=outArgsPropInfo(outIdx).IsScalar;
                        outArgsProp(outIdx).IsImage=outArgsPropInfo(outIdx).IsImage;
                        outArgsProp(outIdx).IsComplex=outArgsPropInfo(outIdx).IsComplex;
                    end
                end
            else
                error('Block must be a Simulink Function or a Caller block');
            end
        end



        function byValue=canArgBePassedByValue(arg)
            byValue=true;
            isBus=arg.IsBus;
            isImage=arg.IsImage;
            isArray=~arg.IsScalar;
            if isArray||isBus||isImage

                byValue=false;
            end

            return;
        end
    end

    methods(Static,Access=private)


        function funcObj=setPrototype(model,fcnName,coderDictMapping,fcnPrototype,funcObj)
            import coder.dictionary.internal.*;

            if isempty(fcnPrototype)

                set_param(model,'Dirty','on');
                coderDictMapping.removeFunctionMapping(fcnName);
                return;
            end


            SubsystemFunctionMapping.validateFunctionPrototype(model,fcnName,...
            fcnPrototype,false);
            oldFuncPrototype=SubsystemFunctionMapping.getField(model,fcnName,'CodePrototype');


            if isempty(oldFuncPrototype)||~strcmp(fcnPrototype,oldFuncPrototype)

                set_param(model,'Dirty','on');
                if isempty(funcObj)
                    funcObj=SubsystemFunctionMapping.getOrCreateFunctionPrototypeObj(fcnName,coderDictMapping);
                end
                funcObj.Prototype=fcnPrototype;
            end
        end


        function funcObj=getOrCreateFunctionPrototypeObj(fcnName,coderDictMapping)
            import coder.dictionary.internal.*;
            funcMappingObj=SubsystemFunctionMapping.getFunctionObj(coderDictMapping,fcnName);

            if isempty(funcMappingObj)
                funcObj=Simulink.CoderDictionary.FunctionPrototype;
            else
                funcObj=funcMappingObj.MappedTo;
                if isempty(funcObj)
                    funcObj=Simulink.CoderDictionary.FunctionPrototype;
                end
            end
        end
        function validateUseOfRenaming(model,func,fcnName)
            import coder.dictionary.internal.SubsystemFunctionMapping.*;
            fcnBlock=getSimulinkFunctionOrCallerBlock(...
            model,fcnName);
            if isempty(fcnBlock)

                return;
            end
            if~isPublicFcn(fcnBlock,fcnName)
                return;
            end
            if~strcmp(func.name,fcnName)
                DAStudio.error('coderdictionary:api:RenamingWithPublicFunction',fcnName);
            end
            args=func.arguments;
            for i=1:length(args)
                currentArg=args{i};
                if~isempty(currentArg.mappedFrom)&&...
                    ~isequal(currentArg.mappedFrom{1},currentArg.name)
                    DAStudio.error('coderdictionary:api:RenamingWithPublicFunction',fcnName);
                end
            end
        end

        function func=getParsedFunction(fcnPrototype)
            import coder.dictionary.internal.*;

            try
                func=coder.parser.Parser.doit(fcnPrototype);
            catch ME
                DAStudio.error('RTW:codeGen:InvalidPrototypeFormat',fcnPrototype);
            end
        end


        function out=getDefaultStruct(model,fcnName)
            import coder.dictionary.internal.*;
            fcnBlock=SubsystemFunctionMapping.getSimulinkFunctionOrCallerBlock(...
            model,fcnName);
            out.CodePrototype=...
            SubsystemFunctionMapping.createDefaultFunctionPrototypeFromBlock(...
            fcnBlock,true);
        end

        function out=getFunctionObj(cTargetMapping,fcnName)
            if isempty(cTargetMapping)

                out=[];
            else
                out=findobj(cTargetMapping.SimulinkFunctionCallerMappings,...
                'SimulinkFunctionName',fcnName);
            end
        end

        function out=getTargetMapping(model,~)
            if~coder.dictionary.internal.SubsystemFunctionMapping.isSimulinkModel(model)
                DAStudio.error('RTW:codeGen:InvalidModelFcnPrototype',model);
            end












            mmgr=get_param(model,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            out=mmgr.getActiveMappingFor('CoderDictionary');

        end

        function fcnName=getSlFunctionName(blk)
            [~,~,fcnName]=coder.dictionary.internal.SubsystemFunctionMapping.getSLFcnInOutArgs(blk);
        end


        function isSLFcn=isSimulinkFunction(blk)
            isSLFcn=false;
            if(strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
                strcmp(get_param(blk,'IsSimulinkFunction'),'on'))
                isSLFcn=true;
            end
        end



        function slFcnBlock=getSimulinkFunctionBlock(model,fcnName)
            slFcnBlock='';
            slFcnBlocks=find_system(model,...
            'blocktype','SubSystem','IsSimulinkFunction','on');
            for slIdx=1:length(slFcnBlocks)
                if Simulink.CoderDictionary.suppressConfigureFunctionInterface(...
                    get_param(slFcnBlocks{slIdx},'Handle'))

                    continue;
                end
                if strcmp(coder.dictionary.internal.SubsystemFunctionMapping.getSlFunctionName(...
                    slFcnBlocks{slIdx}),fcnName)
                    slFcnBlock=slFcnBlocks{slIdx};
                    return;
                end
            end
        end



        function callerBlock=getFunctionCallerBlock(model,fcnName)
            callerBlock='';
            fcnCallerBlocks=find_system(model,'MatchFilter',@Simulink.match.allVariants,...
            'FollowLinks','on','LookUnderMasks','all','blocktype','FunctionCaller');
            for callIdx=1:length(fcnCallerBlocks)

                [isPublic,~,~,~]=...
                coder.mapping.internal.isPublicSimulinkFunction(fcnCallerBlocks{callIdx});

                if~isPublic&&Simulink.CoderDictionary.suppressConfigureFunctionInterface(...
                    get_param(fcnCallerBlocks{callIdx},'Handle'))

                    continue;
                end

                if strcmp(coder.dictionary.internal.SubsystemFunctionMapping.getSlFunctionName(...
                    fcnCallerBlocks{callIdx}),fcnName)
                    callerBlock=fcnCallerBlocks{callIdx};
                    return;
                end
            end
        end
    end
end




function tf=isaSupportedVoidPtrArg(arg,conceptualIOType)



    tf=false;

    if isa(arg,'coder.parser.Argument')
        tf=(isequal(arg.qualifier,coder.parser.Qualifier.Const)&&strcmpi(conceptualIOType,'RTW_IO_INPUT'))||...
        (isequal(arg.qualifier,coder.parser.Qualifier.None)&&strcmpi(conceptualIOType,'RTW_IO_OUTPUT'));
        tf=tf&&...
        isequal(arg.passBy,coder.parser.PassByEnum.Pointer)&&...
        strcmpi(arg.dataTypeString,'void');
    end

end

function loc_checkFlattenedStr(flattenedStr,symbol)


    if isempty(flattenedStr)
        if~contains(symbol,'$M')
            DAStudio.error('SimulinkCoderApp:slfpc:ResolvedIdentifierIsEmpty');
        end
    else


        if~coder.dictionary.internal.SimulinkFunctionMapping.isValidIdentifier(flattenedStr)&&...
            length(symbol)>1&&strcmp(symbol(1:2),'$U')
            DAStudio.error('SimulinkCoderApp:slfpc:ResolvedIdentifierIsInvalid');
        end
    end

end




