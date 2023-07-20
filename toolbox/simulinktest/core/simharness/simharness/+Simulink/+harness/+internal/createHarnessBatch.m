function[harnessInfo,status,warnMessages]=createHarnessBatch(...
    harnessOwners,topModel,createForLoad,checkoutSLTLicence,varargin)




    try


        validateattributes(harnessOwners,{'double','cell','string','char',...
        'Simulink.BlockPath'},{'vector','nonempty'});



        validateattributes(topModel,{'double','string','char'},{'nonempty'});
        if ischar(topModel)
            topModel=string(topModel);
        end

        if~isscalar(topModel)
            eID='Simulink:Harness:InvalidTopModel';
            throw(MException(eID,getString(message(eID))));
        end

        topModel=get_param(topModel,'Handle');



        if~Simulink.SubsystemType.isBlockDiagram(topModel)
            eID='Simulink:Harness:InvalidTopModelType';
            throw(MException(eID,getString(message(eID))));
        end









        blockH=getHarnessOwnerHandles(harnessOwners);
        len=numel(blockH);





        rootH=validateThatComponentsBelongToHierarchy(blockH,topModel);




        verificationModes={'Normal','SIL','PIL'};
        p=inputParser;
        p.KeepUnmatched=true;
        p.addRequired('harnessOwners');
        p.addRequired('topModel');
        p.addRequired('createForLoad');
        p.addRequired('checkoutSLTLicence');



        p.addParameter('CreateWithoutCompile',false,@(x)validateattributes...
        (x,{'logical'},{'nonempty','scalar'}));
        p.addParameter('HarnessPath',[],@(x)mustBeFolder(x));
        p.addParameter('VerificationMode','Normal',@(x)validateFcn(x,verificationModes));
        p.addParameter('Name',[],@(x)validateattributes(x,{'char','string'},{'nonempty'}));
        p.addParameter('FunctionInterfaceName',[],@(x)validateattributes(x,{'char','string'},{'nonempty'}));
        p.addParameter('ExistingBuildFolder',[],@(x)validateattributes(x,{'char','string'},{'nonempty'}));
        p.parse(topModel,harnessOwners,createForLoad,checkoutSLTLicence,varargin{:});
        fcnInterface=p.Results.FunctionInterfaceName;
        createWithoutCompile=p.Results.CreateWithoutCompile;
        verificationMode=p.Results.VerificationMode;
        baseName=p.Results.Name;



        if(~isempty(baseName))&&(~isvarname(baseName))
            eID='Simulink:Harness:HarnessNameNotValid';
            throw(MException(eID,getString(message(eID,baseName))));
        end

        if~isempty(baseName)
            baseName=char(baseName);
            varargin=removeParamFromInArg('Name',varargin);
        end


        varargin=errorIfParamPassedAndRemoveFromInArgs('FunctionInterfaceName',fcnInterface,varargin);




        if~isempty(p.Results.ExistingBuildFolder)
            wID='Simulink:Harness:ExistingBuildFolderNotSupportedInBatchMode';
            warning(wID,getString(message(wID)));
        end
        varargin=removeParamFromInArg('ExistingBuildFolder',varargin);


        isSILPILMode=~strcmp(verificationMode,'Normal');
        if isSILPILMode&&(isLibraryOrSubsystemRefBD(topModel))
            Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','VerificationMode','Normal'});
            verificationMode='Normal';
            isSILPILMode=false;
            varargin=removeParamFromInArg('VerificationMode',varargin);
        end





        if isSILPILMode&&createWithoutCompile
            Simulink.harness.internal.warn('Simulink:Harness:InvalidCreateGraphicalForSILPIL');
            createWithoutCompile=false;
            varargin=removeParamFromInArg('CreateWithoutCompile',varargin);
        end



        status=ones(len,1);
        harnessInfo=cell(len,1);
        warnMessages=cell(len,1);

        ocp=cell(2,1);












        if~strcmp(get_param(topModel,'SimulationStatus'),'stopped')
            eID='Simulink:Harness:CannotCreateWhenBDIsCompiled';
            throw(MException(eID,getString(message(eID,getfullname(topModel)))));
        end

        compileSubModelsIndividually=isSILPILMode||isArchitectureModel(topModel);


        if~(isLibraryOrSubsystemRefBD(topModel)||createWithoutCompile)


            if isSILPILMode
                ocp=cell(2+len,1);
                switch verificationMode
                case 'SIL'
                    harnessVerificationModeEnum=1;
                case 'PIL'
                    harnessVerificationModeEnum=2;
                otherwise
                    harnessVerificationModeEnum=0;
                end
                for i=1:len



                    try




                        if Simulink.harness.internal.isUserDefinedFcnBlock(blockH(i))
                            continue;
                        end
                        cutsOrigCreateSILBlkParamValue=setupSILPILModeHelperBatch('setupSS',blockH(i),harnessVerificationModeEnum,-1,[],'CalculateChecksums',false);
                        ocp{i+2}=onCleanup(@()setupSILPILModeHelperBatch('restoreSS',blockH(i),harnessVerificationModeEnum,-1,cutsOrigCreateSILBlkParamValue));

                    catch me
                        status(i)=0;
                        harnessInfo{i}=me;
                    end
                end
            end


            if~compileSubModelsIndividually

                try
                    feval(getfullname(topModel),[],[],[],'compileForSizes');
                    ocp{1}=onCleanup(@()cleanUpActive(topModel));
                catch causeMex
                    eID='Simulink:Harness:HarnessCreationAborted';
                    baseMex=MException(eID,getString(message(eID,getfullname(topModel))));
                    baseMex=baseMex.addCause(causeMex);
                    throw(baseMex);
                end
            end




            origVal=slsvTestingHook('AllowHarnessCreationWhenBDIsCompiled',1);
            ocp{2}=onCleanup(@()slsvTestingHook('AllowHarnessCreationWhenBDIsCompiled',origVal));
        end















        if compileSubModelsIndividually
            origRootH=rootH;
            origBlockH=blockH;
            origStatus=status;
            origWarnMessages=warnMessages;
            origHarnessInfo=harnessInfo;




            [rootH,origIdx]=sort(rootH);
            blockH=origBlockH(origIdx);
            status=origStatus(origIdx);
            warnMessages=origWarnMessages(origIdx);
            harnessInfo=origHarnessInfo(origIdx);
            prevRootH=-1;
        end


        wState=warning;
        warning('off','Simulink:cgxe:LeakedJITEngine');
        oc2=onCleanup(@()warning(wState));



        for i=1:len





            try

                if status(i)&&compileSubModelsIndividually&&prevRootH~=rootH(i)&&~isLibraryOrSubsystemRefBD(rootH(i))&&(~createWithoutCompile)
                    if prevRootH~=-1
                        cleanUpActive(prevRootH);
                    end
                    feval(getfullname(rootH(i)),[],[],[],'compile');
                    prevRootH=rootH(i);
                end
            catch causeMex



                j=i+1;
                while(j<=len&&rootH(i)==rootH(j))
                    j=j+1;
                end
                eID='Simulink:Harness:HarnessCreationAborted';
                baseMex=MException(eID,getString(message(eID,getfullname(rootH(i)))));
                baseMex=baseMex.addCause(causeMex);
                for k=i:j-1
                    if status(k)
                        status(k)=0;
                        harnessInfo{k}=baseMex;
                    end
                end
            end

            if status(i)
                [harnessInfo{i},warnMessages{i},status(i)]=createOneHarness(blockH(i),createForLoad,checkoutSLTLicence,varargin,baseName,rootH(i));
            end
        end



        if compileSubModelsIndividually
            cleanUpActive(rootH(len));
            origHarnessInfo(origIdx)=harnessInfo;
            origStatus(origIdx)=status;
            origWarnMessages(origIdx)=warnMessages;
            harnessInfo=origHarnessInfo;
            status=origStatus;
        end










        if isSILPILMode
            for i=1:len
                if~status(i)&&harnessInfo{i}.identifier=="Simulink:modelReference:modelAlreadyCompiled"
                    [harnessInfo{i},warnMessages{i},status(i)]=createOneHarness(origBlockH(i),createForLoad,checkoutSLTLicence,varargin,baseName,origRootH(i));
                end
            end
        end

    catch me
        throwAsCaller(me);
    end
end



function[harnessInfo,warnMessages,status]=createOneHarness(blockH,createForLoad,checkoutSLTLicence,restArgs,baseName,rootH)
    harnessInfo=[];
    warnMessages=[];
    status=1;
    try
        args=[{blockH,createForLoad,checkoutSLTLicence},restArgs];
        if~isempty(baseName)
            hname=Simulink.harness.internal.getUniqueName(rootH,baseName);
            args=[args,{'Name',hname}];
        end
        warnDetector=stm.internal.genericrealtime.RTWarningDetector();
        harnessInfo=Simulink.harness.internal.create(args{:});
        warnMessages=warnDetector.DetectedWarnings;
        clear warnDetector;
    catch me
        harnessInfo=me;
        status=0;
        if exist('warnDetector','var')
            warnMessages=warnDetector.DetectedWarnings;
            clear warnDetector;
        end
    end
end


function cleanUpActive(activeRootH)
    if any(strcmp(get_param(activeRootH,'SimulationStatus'),{'paused','compiled'}))
        feval(getfullname(activeRootH),[],[],[],'term');
    end
end


function validateFcn(input,inputList)
    if~any(strcmpi(input,inputList))
        eID='Simulink:Harness:InvalidInputArgumentForHarnessCreation';
        throw(MException(eID,getString(message(eID,strjoin(inputList,''', '''),input))));
    end
end



function argout=errorIfParamPassedAndRemoveFromInArgs(paramName,paramValue,argin)
    argout=removeParamFromInArg(paramName,argin);
    if~isempty(paramValue)
        eID='Simulink:Harness:InvalidNVPairOption';
        throw(MException(eID,getString(message(eID,paramName))));
    end
end


function argout=removeParamFromInArg(param,argin)
    ind=findIndOfParameter(param,argin);
    if~isempty(ind)
        argin(ind)=[];
        argin(ind)=[];
    end
    argout=argin;
end

function ind=findIndOfParameter(param,argin)

    assert(iscell(argin));




    argin=argin(1:2:end);
    ind=find(strcmp(param,string(argin)));
    ind=2*ind-1;
end


function blockH=getHarnessOwnerHandles(harnessOwners)
    if isa(harnessOwners,'Simulink.BlockPath')
        n=numel(harnessOwners);
        tempHandles=zeros(1,n);
        for i=1:n
            validate(harnessOwners(i));
            l=getLength(harnessOwners(i));
            tempHandles(i)=get_param(getBlock(harnessOwners(i),l),'Handle');
        end
        blockH=tempHandles;
    elseif ischar(harnessOwners)
        harnessOwners=convertCharsToStrings(harnessOwners);
        blockH=get_param(harnessOwners,'handle');
    elseif iscell(harnessOwners)
        types=string(cellfun(@(x)class(x),harnessOwners,'UniformOutput',false));
        if any(arrayfun(@(x)isUnsupportedTypeInCell(x),types,UniformOutput=true))
            error(message("Simulink:Harness:InvalidDataTypeInHarnessOwnerCell"));
        end
        blockH=cellfun(@(s)get_param(s,'handle'),harnessOwners);
    elseif isstring(harnessOwners)
        if length(harnessOwners)>1
            blockH=cell2mat(get_param(harnessOwners,'handle'));
        else
            blockH=get_param(harnessOwners,'handle');
        end
    else
        blockH=harnessOwners;
    end
end


function rootH=validateThatComponentsBelongToHierarchy(blockH,topModel)



    rootH=bdroot(blockH);



    referencedModels=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);

    MRHeirarchy=cell2mat(get_param(referencedModels,'Handle'));


    isCUTinHeirarchy=ismember(rootH,MRHeirarchy);

    if~all(isCUTinHeirarchy)
        cutsNotInHeirarchy=convertCharsToStrings(getfullname(blockH(~isCUTinHeirarchy)));
        submodelsNotInHeirarchy=convertCharsToStrings(getfullname(rootH(~isCUTinHeirarchy)));
        referencedModels=strjoin(referencedModels,', ');
        eID='Simulink:Harness:InvalidModelHeirarchy';
        baseMex=MException(eID,getString(message(eID,referencedModels)));
        l=numel(cutsNotInHeirarchy);
        for i=1:l
            eID='Simulink:Harness:InvalidModelHeirarchyCause';
            causeMex=MException(eID,getString(message(eID,...
            cutsNotInHeirarchy(i),submodelsNotInHeirarchy(i))));
            baseMex=baseMex.addCause(causeMex);
        end
        throw(baseMex);
    end
end

function res=isLibraryOrSubsystemRefBD(topModel)
    res=bdIsLibrary(topModel)||bdIsSubsystem(topModel);
end

function[sutsOrigCreateSILBlkParamValue,checkSum1,checkSum2,checkSum3,checkSum4]=setupSILPILModeHelperBatch(command,sut,harnessVerificationModeEnum,silBlock,sutsOrigCreateSILBlkParamValue,varargin)








    preserve_dirty=Simulink.PreserveDirtyFlag(bdroot(sut),'blockDiagram');
    [sutsOrigCreateSILBlkParamValue,checkSum1,checkSum2,checkSum3,checkSum4]=...
    Simulink.harness.internal.setupSILPILModeHelper(...
    command,sut,harnessVerificationModeEnum,silBlock,sutsOrigCreateSILBlkParamValue,varargin{:});
end

function res=isArchitectureModel(topModel)
    subDomain=get_param(topModel,"SimulinkSubDomain");
    res=subDomain=="Architecture"||subDomain=="SoftwareArchitecture"||subDomain=="AUTOSARArchitecture";
end

function res=isUnsupportedTypeInCell(type)
    res=type~="char"&&type~="double"&&type~="string";
end
