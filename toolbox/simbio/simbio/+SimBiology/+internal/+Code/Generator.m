








classdef Generator<handle


    properties(Constant)

        FluxBaseName='sbioodeflux'
        RepeatedAssignmentsBaseName='sbiorepeated'
        InitialAssignmentsBaseName='sbioinitial'
        EventTriggersBaseName='sbioeventtrigger'
        EventFunctionsBaseName='sbioeventfunction'
    end

    properties(Access=private)
        version='1.1'
        uuid=''
        originalBaseName=''
        mFileText=''


        mexFileNamesByArch=containers.Map('KeyType','char','ValueType','any')%#ok<MCHDP>



deleteFiles

        neverAccelerate=false
    end


    properties(Access=private)
        dirName=''
    end

    properties(Access=private,Transient)
loadobjListener
    end



    properties(Access=private)
mexFileContentsByArch
    end

    properties(GetAccess=public,SetAccess=private)
        baseName='';
        paddedSampleInputs={}
        actualInputLengths=[];
        sampleOutputsSpecified=false
        sampleOutputs={}
    end

    properties(GetAccess=public,SetAccess=private,Dependent)
mexFileName
mFunctionName
mFileName
DependentFiles
    end


    methods
        function obj=saveobj(obj)

            arches=obj.mexFileNamesByArch.keys;
            obj.mexFileContentsByArch=containers.Map('KeyType','char','ValueType','any');
            for i=1:numel(arches)
                thisArch=arches{i};
                thisMexFileName=obj.mexFileNamesByArch(thisArch);
                if~exist(thisMexFileName,'file')


                    obj.mexFileNamesByArch.remove(thisArch);
                    continue
                end
                fid=fopen(thisMexFileName,'r');
                assert(fid~=-1,message('SimBiology:CodeGeneration:TempFile'));
                cleanup=onCleanup(@()fclose(fid));
                obj.mexFileContentsByArch(thisArch)=fread(fid,inf,'*uint8');
                delete(cleanup);
            end
        end
    end

    methods(Access=private)
        function createListener(obj)
            obj.loadobjListener=SimBiology.internal.Code.Registry.Instance.add(obj.uuid,@(source,eventData)obj.loadobjEvent(source,eventData));
        end

        function loadobjEvent(obj,source,eventData)%#ok<INUSL>
            if strcmp(obj.uuid,eventData.uuid)
                eventData.existingObject=obj;
            end
        end
    end

    methods(Static)
        function obj=loadobj(obj)


            registry=SimBiology.internal.Code.Registry.Instance;
            existingObject=registry.get(obj.uuid);

            loadedMexFileNamesByArch=obj.mexFileNamesByArch;
            loadedMFileText=obj.mFileText;
            loadedMexFileContentsByArch=obj.mexFileContentsByArch;

            obj.mexFileContentsByArch=[];

            if~isempty(existingObject)









                obj.deleteFiles=false;
                obj=existingObject;
            else

                obj.createListener();
            end






            if isdeployed
                obj.deleteFiles=false;





                thisMFileName=[obj.baseName,'.m'];
                whichMFile=which(thisMFileName);
                if isempty(whichMFile)
                    error(message('SimBiology:CodeGeneration:MissingFileDeployed',thisMFileName));
                end

                obj.dirName=fileparts(whichMFile);


                loadedArches=loadedMexFileNamesByArch.keys;
                for i=1:numel(loadedArches)
                    thisArch=loadedArches{i};
                    oldMexFileName=loadedMexFileNamesByArch(thisArch);




                    [~,~,mexExtWithDot]=fileparts(oldMexFileName);
                    thisMexFileName=[obj.baseName,mexExtWithDot];
                    whichMexFile=which(thisMexFileName);
                    if isempty(whichMexFile)
                        warning(message('SimBiology:CodeGeneration:MissingOptionalFileDeployed',thisMexFileName));
                        if obj.mexFileNamesByArch.isKey(thisArch)
                            obj.mexFileNamesByArch.remove(thisArch)
                        end
                    else
                        obj.mexFileNamesByArch(thisArch)=whichMexFile;
                    end
                end
            else
                obj.deleteFiles=true;



                obj.dirName=sbiogate('sbiotempdir');
                obj.mFileText=loadedMFileText;
                obj.writeMFile();


                loadedArches=loadedMexFileNamesByArch.keys;
                for i=1:numel(loadedArches)
                    thisArch=loadedArches{i};

                    oldMexFileName=loadedMexFileNamesByArch(thisArch);




                    [~,~,mexExtWithDot]=fileparts(oldMexFileName);
                    newMexFileName=fullfile(obj.dirName,[obj.baseName,mexExtWithDot]);
                    obj.mexFileNamesByArch(thisArch)=newMexFileName;
                    if~exist(newMexFileName,'file')

                        fid=fopen(newMexFileName,'w');
                        assert(fid~=-1,message('SimBiology:CodeGeneration:TempFile'));
                        cleanup=onCleanup(@()fclose(fid));
                        fwrite(fid,loadedMexFileContentsByArch(thisArch));
                        delete(cleanup);
                    end
                end
            end


            whichFunction=which(obj.baseName);
            if exist(whichFunction,'file')==3
                try
                    feval(obj.baseName);
                catch exception
                    if strcmp(exception.identifier,'MATLAB:invalidMEXFile')
                        warning(message('SimBiology:CodeGeneration:InvalidMex'));
                        if~isdeployed


                            try
                                robustDelete(whichFunction);
                                if obj.mexFileNamesByArch.isKey(computer('arch'))
                                    obj.mexFileNamesByArch.remove(computer('arch'));
                                end
                            catch %#ok<CTCH>
                            end
                        end
                    end
                end
            end

        end
    end


    methods
        function value=get.mexFileName(obj)
            arch=computer('arch');
            if obj.mexFileNamesByArch.isKey(arch)
                value=obj.mexFileNamesByArch(arch);
            else
                value='';
            end
        end

        function value=get.mFunctionName(obj)
            value=obj.baseName;
        end

        function value=get.mFileName(obj)
            value=fullfile(obj.dirName,[obj.baseName,'.m']);
        end

        function files=get.DependentFiles(obj)
            files=horzcat({obj.mFileName},obj.mexFileNamesByArch.values);
        end
    end

    methods(Access=public)
        function obj=Generator(baseName,fileText,codeGenFlag,paddedSampleInputs,actualInputLengths,sampleOutputs)
















            obj.mexFileNamesByArch=containers.Map('KeyType','char','ValueType','char');

            if nargin==0
                return
            end

            validateattributes(baseName,{'char'},{'row'});
            validateattributes(fileText,{'char'},{'vector'});
            validateattributes(codeGenFlag,{'numeric','logical'},{'scalar'});
            mustBeMember(codeGenFlag,[-1,0,1]);
            validateattributes(paddedSampleInputs,{'cell'},{'vector'});
            validateattributes(actualInputLengths,{'double'},{'vector'});
            if exist('sampleOutputs','var')
                validateattributes(sampleOutputs,{'cell'},{'vector'});
            end



            assert(~isdeployed);

            obj.uuid=generateUUID();



            obj.createListener();

            obj.dirName=sbiogate('sbiotempdir');
            obj.paddedSampleInputs=paddedSampleInputs;
            obj.actualInputLengths=actualInputLengths;
            if exist('sampleOutputs','var')
                obj.sampleOutputsSpecified=true;
                obj.sampleOutputs=sampleOutputs;
            else
                obj.sampleOutputsSpecified=false;
            end

            obj.originalBaseName=baseName;
            obj.baseName=[baseName,'_',obj.uuid];
            if numel(obj.baseName)>namelengthmax

                localStackedWarning(message('SimBiology:CodeGeneration:UniqueBaseNameTooLong'));
                obj.baseName=obj.baseName(1:namelengthmax);
            end


            obj.mFileText=updateFunctionForNewBaseFileName(fileText,baseName,obj.baseName);
            obj.writeMFile();
            mOutputs=obj.testMFile();
            switch codeGenFlag
            case-1
                obj.neverAccelerate=true;
            case 0

            case 1

                genAndTestMexFile(obj,mOutputs);
            otherwise
                error(message('SimBiology:Internal:InternalError'));
            end
        end

        function tf=isAccelerated(obj,arch)


            if~exist('arch','var')
                arch=computer('arch');
            end
            tf=false(size(obj));
            for i=1:numel(tf)
                if obj(i).neverAccelerate


                    tf(i)=true;
                elseif obj(i).mexFileNamesByArch.isKey(arch)

                    thisMexFileName=obj(i).mexFileNamesByArch(arch);
                    tf(i)=logical(exist(thisMexFileName,'file'));
                end
            end
        end

        function obj=accelerate(obj)
            assert(~isdeployed);
            for i=1:numel(obj)
                thisMexFileName=obj(i).mexFileName;

                if~obj(i).neverAccelerate&&(isempty(thisMexFileName)||~exist(thisMexFileName,'file'))

                    mOutputs=obj(i).testMFile();
                    genAndTestMexFile(obj(i),mOutputs);
                end
            end
        end

        function verify(objArray)

            missingFiles={};
            for i=1:numel(objArray)
                whichMFile=which(objArray(i).mFileName);
                if isempty(whichMFile)
                    missingFiles{end+1}=objArray(i).mFileName;%#ok<AGROW>
                end
            end
            if~isempty(missingFiles)
                missingFileList=SimBiology.internal.getCommaSeparatedStringFromCellstr(missingFiles);
                if isdeployed
                    error(message('SimBiology:CodeGeneration:MissingFileDeployed',missingFileList));
                else
                    error(message('SimBiology:CodeGeneration:MissingFile',missingFileList));
                end
            end
        end

        function delete(obj)
            if~obj.deleteFiles
                return
            end


            clear(obj.baseName);


            allMexFiles=obj.mexFileNamesByArch.values();
            for i=1:numel(allMexFiles)
                thisMexFile=allMexFiles{i};
                if exist(thisMexFile,'file')
                    robustDelete(thisMexFile);
                end
            end


            if exist(obj.mFileName,'file')
                robustDelete(obj.mFileName);
            end
        end
    end

    methods(Access=private)
        function genAndTestMexFile(obj,mOutputs)
            success=genMexFile(obj);
            if success
                testMexFile(obj,mOutputs);
            end
        end

        function success=genMexFile(obj)
            if feature('SimBioCodeGeneration')==0
                success=false;
                return
            end
            assert(exist(obj.mFileName,'file')~=0,...
            message('SimBiology:CodeGeneration:WhichFile'));




            fcopts=coder.internal.FeatureControl;
            fcopts.ReentrantCode=false;

            copts=coder.mexconfig;
            copts.ExtrinsicCalls=true;



            copts.IntegrityChecks=false;
            copts.ResponsivenessChecks=false;

            thisMexFileName=getMexFileName(obj);



            command='coder.internal.simbiohelper(obj.mFileName, ''-d'', obj.dirName, ''-args'', obj.paddedSampleInputs, ''-config'', ''copts'', ''-feature'', ''fcopts'', ''-o'', thisMexFileName);';




            [~,report]=evalc(command);

            if~isempty(report)&&isfield(report,'summary')&&...
                isfield(report.summary,'passed')&&report.summary.passed
                obj.mexFileNamesByArch(computer('arch'))=thisMexFileName;
                success=true;
            else
                reportCodegenErrors(obj,report);
                success=false;
            end
        end

        function[friendlyTypeName,componentsToCheck]=getDiagnosticText(obj)
            switch obj.originalBaseName
            case SimBiology.internal.Code.Generator.FluxBaseName
                friendlyTypeName='reaction rates';
                componentsToCheck='reaction rate/rule expressions and any user-defined functions';
            case SimBiology.internal.Code.Generator.RepeatedAssignmentsBaseName
                friendlyTypeName='repeatedAssignment rules';
                componentsToCheck='repeatedAssignment rule expressions and any user-defined functions';
            case SimBiology.internal.Code.Generator.InitialAssignmentsBaseName
                friendlyTypeName='initialAssignment rules';
                componentsToCheck='initialAssignment rule expressions and any user-defined functions';
            case SimBiology.internal.Code.Generator.EventTriggersBaseName
                friendlyTypeName='event triggers';
                componentsToCheck='event trigger expressions and any user-defined functions';
            case SimBiology.internal.Code.Generator.EventFunctionsBaseName
                friendlyTypeName='event functions';
                componentsToCheck='event function expressions and any user-defined functions';
            otherwise

                friendlyTypeName='function';
                componentsToCheck='functions';
            end
        end

        function reportCodegenErrors(obj,report)




            saveFileDirName=SimBiology.internal.DiagnosticDir.get();
            saveFileBaseName=matlab.lang.internal.uuid;
            saveFileName=fullfile(saveFileDirName,saveFileBaseName+".mat");
            save(saveFileName,'report');









            if isfield(report,'internal')&&~isempty(report.internal)



                messageObj=message('SimBiology:CodeGeneration:CoderInternalError',...
                report.internal.identifier,report.internal.getReport(),saveFileName);
            elseif isfield(report,'summary')



                [friendlyTypeName,componentsToCheck]=getDiagnosticText(obj);
                messageObj=message('SimBiology:CodeGeneration:AccelerationFailed',friendlyTypeName,componentsToCheck,saveFileName);
            else


                messageObj=message('SimBiology:CodeGeneration:InternalError',saveFileName);
            end
            localStackedWarning(messageObj);
        end

        function value=getMexFileName(obj)

            value=fullfile(obj.dirName,[obj.baseName,'.',mexext]);
        end

        function writeMFile(obj)

            fid=fopen(obj.mFileName,'w');
            assert(fid~=-1,message('SimBiology:CodeGeneration:TempFile'));
            cleanup=onCleanup(@()fclose(fid));
            fprintf(fid,'%s',obj.mFileText);
            delete(cleanup);

            exist(obj.mFileName,'file');
        end

        function[matlabError,actualOutputs]=testFunctionEvaluation(obj)

            matlabError=[];
            if~obj.sampleOutputsSpecified
                actualOutputs={};
                return
            end
            actualOutputs=cell(1,numel(obj.sampleOutputs));
            clear(obj.mFunctionName);

            try
                [actualOutputs{:}]=feval(obj.mFunctionName,obj.paddedSampleInputs{:});
            catch ME
                matlabError=appendCause([],ME);
                return
            end

            for i=1:numel(obj.sampleOutputs)

                if~all(size(actualOutputs{i})==size(obj.sampleOutputs{i}))
                    newCause=MException(message('SimBiology:CodeGeneration:OutputSizeIncorrect',i));
                    matlabError=appendCause(matlabError,newCause);
                end
            end
        end

        function actualOutputs=testMFile(obj)
            [matlabError,actualOutputs]=testFunctionEvaluation(obj);

            if~isempty(matlabError)
                assert(isa(matlabError,'MException'));
                disp(matlabError.getReport);
                throw(matlabError);
            end
        end

        function testMexFile(obj,mOutputs)
            thisMexFileName=obj.mexFileName;
            assert(~isempty(thisMexFileName)&&exist(thisMexFileName,'file'));
            [matlabError,mexOutputs]=testFunctionEvaluation(obj);
            if isempty(matlabError)&&~isequaln(mexOutputs,mOutputs)&&~isEqualWithinTolerance(mexOutputs,mOutputs)





                [friendlyTypeName,componentsToCheck]=getDiagnosticText(obj);
                matlabError=MException(message('SimBiology:CodeGeneration:AcceleratedResultsDiffer',...
                friendlyTypeName,componentsToCheck));
            end
            if~isempty(matlabError)
                robustDelete(thisMexFileName);
                obj.mexFileNamesByArch.remove(computer('arch'));
                localStackedWarning(message('SimBiology:CodeGeneration:MexFileEvaluationFailed',...
                matlabError.getReport));
            end
        end
    end
end

function matlabError=appendCause(matlabError,newCause)
    if isempty(matlabError)
        matlabError=MException(message('SimBiology:CodeGeneration:FunctionEvaluationFailed'));
    end
    matlabError=addCause(matlabError,newCause);
end

function uuid=generateUUID()
    uuid=strrep(char(matlab.lang.internal.uuid),'-','_');
end

function fileText=updateFunctionForNewBaseFileName(fileText,oldName,newName)

    iStart=strfind(fileText,oldName);
    assert(~isempty(iStart),message('SimBiology:CodeGeneration:IncorrectFunctionName'));



    iStart=iStart(1);
    iEnd=iStart+numel(oldName)-1;
    fileText=[fileText(1:(iStart-1))...
    ,newName,fileText((iEnd+1):end)...
    ];
end

function tfEqual=isEqualWithinTolerance(mexOutputsCell,mOutputsCell)
    mexOutputs=vertcat(mexOutputsCell{:});
    mOutputs=vertcat(mOutputsCell{:});

    tfBothFinite=isfinite(mexOutputs)&isfinite(mOutputs);
    if~all(isequaln(mexOutputs(~tfBothFinite),mOutputs(~tfBothFinite)),'all')
        tfEqual=false;
    else
        tfEqual=all(abs(mexOutputs(tfBothFinite)-mOutputs(tfBothFinite))<100*max(eps,eps(mOutputs(tfBothFinite))),'all');
    end
end


function localStackedWarning(messageObj)
    sbiogate('privatemessagecalls',...
    'addwarning',...
    {messageObj.getString,...
    messageObj.Identifier,...
    'ODE Compilation',...
    []...
    });
end

function robustDelete(filename)

    oldStatus=warning('off','MATLAB:DELETE:Permission');
    cleanup=onCleanup(@()warning(oldStatus));
    delete(filename);
    if exist(filename,'file')

        if ispc

            command=['del /f "',regexprep(filename,'"','""'),'"'];
        else

            command=['rm -f "',regexprep(filename,'"','\\"'),'"'];
        end
        [status,cmdout]=system(command);
        if status~=0
            warning(message('SimBiology:CodeGeneration:DeleteFailed',filename,cmdout));
        end
    end
end