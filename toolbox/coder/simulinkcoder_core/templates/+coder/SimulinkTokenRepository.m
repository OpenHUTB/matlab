

classdef SimulinkTokenRepository<coder.TokenRepository

    properties(SetAccess=immutable)

cgModelObject

    end

    properties(SetAccess=private)

fileName
functionName
systemIdx

    end

    methods

        function obj=SimulinkTokenRepository(modelObject)
            obj=obj@coder.TokenRepository();
            obj.cgModelObject=modelObject;
        end

        function obj=setCurrentFileName(obj,fileName)
            obj.fileName=fileName;
        end

        function obj=setCurrentFunctionName(obj,functionName)

            obj.functionName=functionName;
            obj.systemIdx=[];

        end

        function val=getTokenValue(obj,tokenName)







            if~ismember(tokenName,enumeration("coder.Token"))
                val='';
                return;
            end

            token=coder.Token.(tokenName);
            switch token
            case coder.Token.SourceGeneratedOn
                val=datestr(now,'ddd mmm dd HH:MM:SS yyyy');
            case coder.Token.FileName
                val=obj.fileName;
            case coder.Token.FileType
                [~,~,fileExt]=fileparts(obj.FileName);
                if fileExt(2)=='c'
                    val='source';
                else
                    val='header';
                end
            case coder.Token.FileTag
                val='FileTag Ignored';
            case coder.Token.ModelName
                if(isempty(obj.cgModelObject))
                    val='';
                else
                    val=obj.cgModelObject.getName();
                end
            case coder.Token.ModelVersion
                if(isempty(obj.cgModelObject))
                    val='';
                else
                    val=obj.cgModelObject.getVersion();
                end
            case coder.Token.RTWFileVersion
                if(isempty(obj.cgModelObject))
                    val='';
                else
                    val=obj.cgModelObject.getSimulinkCoderVersion();
                end
            case coder.Token.Description
                if(isempty(obj.cgModelObject))
                    val='';
                else
                    val=obj.getModelDescription();
                end
            case coder.Token.RTWFileGeneratedOn
                val=datestr(now,'ddd mmm dd HH:MM:SS yyyy');
            case coder.Token.TLCVersion
                if(isempty(obj.cgModelObject))
                    val='';
                else
                    val=obj.cgModelObject.getSimulinkVersion();
                end
            case coder.Token.CodeGenSettings
                val=obj.getCodeGenSettings();
            case coder.Token.FunctionName
                val=obj.functionName;
            case coder.Token.Arguments
                val=obj.getCurrentFunctionArguments();
            case coder.Token.ReturnType
                val=obj.getCurrentFunctionReturnType();
            case coder.Token.FunctionDescription
                val=obj.getCurrentFunctionDescription();
            case coder.Token.GeneratedFor
                val=obj.getCurrentFunctionGeneratedFor();
            case coder.Token.BlockDescription
                val=obj.getCurrentFunctionBlockDescription();
            otherwise
                val='Unknown Token';
            end
        end
    end

    methods(Hidden=true)

        function val=getCodeGenSettings(obj)

            if(~isempty(obj.cgModelObject))
                codeGenSettings=sprintf('\nTarget selection: %s\n',...
                get_param(obj.cgModelObject.getName(),...
                'SystemTargetFile'));
                codeGenSettings=sprintf(...
                '%sEmbedded hardware selection: %s\n',...
                codeGenSettings,...
                get_param(obj.cgModelObject.getName(),...
                'ProdHWDeviceType'));
                emulationComment=obj.getEmulationHWComment();
            else
                codeGenSettings=sprintf(...
                '%sEmbedded hardware selection: %s\n','');
                emulationComment=obj.getEmulationHWComment();
            end

            if~isempty(emulationComment)
                codeGenSettings=sprintf(['...'...
                ,'%sEmulation hardware selection:\n   %s\n'],...
                codeGenSettings,emulationComment);
            end

            if(~isempty(obj.cgModelObject))
                codeGenSettings=sprintf('%s%s',codeGenSettings,...
                coder.internal.genConfigCheckReportComments(...
                obj.cgModelObject.getName()));
            end

            val=codeGenSettings;
        end

        function val=getEmulationHWComment(obj)


            val=[];
            if(~isempty(obj.cgModelObject))
                if strcmp(get_param(obj.cgModelObject.getName(),...
                    'ProdEqTarget'),'off')
                    val='Differs from embedded hardware';
                    if~strcmp(get_param(obj.cgModelObject.getName(),...
                        'ProdHWDeviceType'),...
                        get_param(obj.cgModelObject.getName(),...
                        'TargetHWDeviceType'))
                        val=sprintf('%s',[val,' (',...
                        get_param(obj.cgModelObject.getName(),...
                        'TargetHWDeviceType'),')']);
                    end
                end
            end
        end

        function val=getCurrentFunctionArguments(~)



            val='Function Arguments Ignored';
        end

        function val=getCurrentFunctionReturnType(~)



            val='Return Type Ignored';
        end

        function val=getCurrentFunctionDescription(obj)




            obj.findAndSetSystemIdxForFunction();
            if~isempty(obj.systemIdx)
                val=obj.getSubsystemFcnDescription(obj.systemIdx,...
                obj.functionName,'--');
            else
                val='FunctionDescription Ignored';
            end

        end

        function val=getCurrentFunctionGeneratedFor(~)




            val='FunctionGeneratedFor Ignored';

        end

        function val=getCurrentFunctionBlockDescription(obj)



            obj.findAndSetSystemIdxForFunction();
            val=obj.getSubsystemBlockDescription();

        end

        function desc=getModelDescription(obj)

            sys=obj.cgModelObject.Systems;
            desc='';





            for iSys=1:numel(sys)
                if(sys(iSys).isRootSystem())
                    desc=Simulink.MDLInfo.getDescription(sys(iSys));
                    return;
                end
            end
        end

        function desc=getSubsystemFcnDescription(obj,sysIdx,...
            fcnName,prefix)

            sys=obj.cgModelObject.Systems(sysIdx);

            if(sys.isAtomic()&&sys.isCalledByBlock())
                desc='';
                return;
            end

            if(sys.isRootSystem())
                desc=sprintf('%s for %s system: ''%s''',fcnName,...
                sys.getSystemType,sys.getName);
                return;
            elseif(sys.IsModelReferenceBaseSystem)
                desc=sprintf('%s for referenced model ''%s''',...
                fcnName,cgModel.ModelName);
                return;
            end

            oneBlockRef=(length(sys.GraphicalCallsites)==1||...
            sys.isInlined()||sys.isReusableLibrarySubsystem());

            if(oneBlockRef)
                if(sys.isReusableLibrarySubsystem())
                else
                    try
                        desc=sprintf('%s for %s system: ''%s''',...
                        obj.getFunctionType(sys,fcnName),...
                        sys.getSystemType(),...
                        sys.GraphicalCallsites(1).Name);
                    catch e
                        disp(e.msg);
                    end
                end
            else
                maxNum=10;
                callSites=sys.GraphicalCallsites;
                desc=sprintf('%s for %s system:\n',fcnName,...
                sys.getSystemType());
                for csIdx=1:length(callSites)
                    desc=sprintf('%s%s   ''%s''\n',desc,prefix,...
                    callSites(csIdx).Name);
                    if(csIdx==maxNum)
                        break;
                    end
                end

                if(length(callSites)>maxNum)
                    desc=sprintf('%s%s   ...\n',desc,prefix);
                end
            end
        end

        function fcnType=getFunctionType(~,sys,fcnName)



            if strcmp(sys.StartFcn,fcnName)
                fcnType='Start';
            elseif strcmp(sys.OutputFcn,fcnName)
                fcnType='Outputs';
            elseif strcmp(sys.UpdateFcn,fcnName)
                fcnType='Update';
            elseif strcmp(sys.OutputUpdateFcn,fcnName)
                fcnType='Output and update';
            else
                fcnType=fcnName;
            end

        end

        function desc=getSubsystemBlockDescription(obj)













            desc='';
            sys=obj.cgModelObject.Systems(obj.systemIdx);
            needBlockDescription=...
            ~(sys.isAtomic()&&sys.isCalledByBlock())&&...
            (~sys.isRootSystem())&&...
            ~sys.IsModelReferenceBaseSystem();
            if needBlockDescription


                if sys.isAtomic()&&sys.isCalledByBlock()
                    return;
                elseif sys.isRootSystem()
                    return;
                elseif sys.IsModelReferenceBaseSystem()
                    return;
                else
                    callSites=sys.GraphicalCallsites;
                    numCallSites=length(callSites);
                    singleBlk=(numCallSites==1)||...
                    (sys.isInlined())||...
                    sys.isReusableLibrarySubsystem();

                    currentBlk=callSites(1);
                    if singleBlk
                        blkName=currentBlk.Name;

                        if sys.isInlined()
                            desc=['Block description for: ''',...
                            blkName,''''];
                        end
                    else
                        desc='Common block description:';
                    end
                end

            end
        end

        function findAndSetSystemIdxForFunction(obj)

            if~isempty(obj.systemIdx)
                return;
            end

            allSys=obj.cgModelObject.Systems;
            for i=1:length(allSys)
                if strcmp(obj.functionName,...
                    allSys(i).Identifier)

                    obj.systemIdx=i;
                elseif(strcmp(obj.functionName,'InitializeConditions')||...
                    strcmp(obj.functionName,'ModelInitialize')||...
                    strcmp(obj.functionName,'ModelExternalInputInit')||...
                    strcmp(obj.functionName,'ModelExternalOutputInit')||...
                    strcmp(obj.functionName,'Outputs'))






                    if allSys(i).isRootSystem
                        obj.systemIdx=i;
                    end
                end
            end
        end

        function getFcnCommentToken(~)
        end

    end

end


