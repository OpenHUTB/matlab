function varargout=validateInputStruct(varargin)






    narginchk(2,nargin);

    validateType=varargin{1};


    isScalarString=@(x)isstring(x)&&isscalar(x);
    isCharCompatible=@(x)ischar(x)||isScalarString(x);
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);

    switch(validateType)
    case 'FieldNames'


        initStruct=legacycode.LCT.DefaultSpecStruct;
        nameFields=fieldnames(initStruct);

        defs=varargin{2};





        sizesFields=fieldnames(defs);
        nonExistIdx=find(~ismember(nameFields,sizesFields));


        for ii=1:length(sizesFields)
            idx=find(strcmp(sizesFields{ii},nameFields),1);
            if isempty(idx)
                error(message('Simulink:tools:LCTErrorValidateInvalideFieldName',...
                sizesFields{ii}));
            end
        end

        for i=1:length(defs)

            for ii=1:length(nonExistIdx)
                defs(i).(nameFields{nonExistIdx(ii)})=initStruct.(nameFields{nonExistIdx(ii)});
            end


            for ii=1:length(nameFields)
                refClass=class(initStruct.(nameFields{ii}));
                tstClass=class(defs(i).(nameFields{ii}));
                if~strcmp(tstClass,refClass)&&(~(strcmp(nameFields{ii},'SampleTime')||...
                    loc_AllowStartFcnSpecAsCell(defs(i),nameFields{ii})))
                    initVal=initStruct.(nameFields{ii});
                    currVal=defs(i).(nameFields{ii});
                    if(ischar(initVal)||iscellstr(initVal))&&isstring(currVal)
                        continue
                    end
                    if refClass=="char"
                        error(message('Simulink:tools:LCTErrorValidateInvalideStringFieldDataType',...
                        nameFields{ii}));
                    else
                        error(message('Simulink:tools:LCTErrorValidateInvalideFieldDataType',...
                        nameFields{ii},tstClass,refClass));
                    end
                end
            end
        end

        varargout{1}=defs;

    case 'Options'
        optionsStruct=varargin{2};



        initStruct=legacycode.LCT.DefaultOptionsStruct;



        renamedOpts=containers.Map('KeyType','char','ValueType','char');
        if isfield(optionsStruct,'convert2DMatrixToRowMajor')
            val=optionsStruct.convert2DMatrixToRowMajor;
            optionsStruct=rmfield(optionsStruct,'convert2DMatrixToRowMajor');
            optionsStruct.convertNDArrayToRowMajor=val;
            renamedOpts('convertNDArrayToRowMajor')='convert2DMatrixToRowMajor';
        end


        nameOptionFields=fieldnames(initStruct);
        sizesOptionFields=fieldnames(optionsStruct);
        for ii=1:length(sizesOptionFields)
            idx=find(strcmp(sizesOptionFields{ii},nameOptionFields),1);
            if isempty(idx)
                error(message('Simulink:tools:LCTErrorValidateInvalideFieldName',...
                ['Options.',sizesOptionFields{ii}]));
            end
        end


        idx=find(~ismember(nameOptionFields,sizesOptionFields));
        for ii=1:length(idx)
            optionsStruct.(nameOptionFields{idx(ii)})=initStruct.(nameOptionFields{idx(ii)});
        end


        for ii=1:length(nameOptionFields)
            refClass=class(initStruct.(nameOptionFields{ii}));
            tstClass=class(optionsStruct.(nameOptionFields{ii}));
            if~strcmp(tstClass,refClass)
                initOptVal=initStruct.(nameOptionFields{ii});
                currOptVal=optionsStruct.(nameOptionFields{ii});
                if(ischar(initOptVal)||iscellstr(initOptVal))&&isstring(currOptVal)
                    continue
                end


                optName=nameOptionFields{ii};
                if renamedOpts.isKey(optName)
                    optName=renamedOpts(optName);
                end
                if refClass=="char"
                    error(message('Simulink:tools:LCTErrorValidateInvalideStringFieldDataType',...
                    ['Options.',optName]));
                else
                    error(message('Simulink:tools:LCTErrorValidateInvalideFieldDataType',...
                    ['Options.',optName],tstClass,refClass));
                end
            end
        end


        lang=upper(optionsStruct.language);
        if~strcmp(lang,'C')&&~strcmp(lang,'C++')
            error(message('Simulink:tools:LCTErrorValidateBadLanguage'));
        end
        optionsStruct.language=char(lang);

        varargout{1}=optionsStruct;

    case 'SampleTime'



        hasError=false;
        st=varargin{2};
        if isempty(st)
            st='inherited';
        end

        if isCharCompatible(st)
            st=char(lower(st));
            if~strcmp(st,'inherited')&&~strcmp(st,'parameterized')
                hasError=true;
            end
        else
            if isnumeric(st)&&isfloat(st)&&isreal(st)&&...
                isvector(st)&&length(st)<=2&&all(isfinite(st))&&...
                ~issparse(st)&&~isempty(st)

                if(st(1)<0)&&(st(1)~=-1)
                    error(message('Simulink:tools:LCTErrorValidateSampleTimeValue'));
                end

                if numel(st)==2
                    if(st(1)>0)&&(st(2)>=st(1))
                        error(message('Simulink:tools:LCTErrorValidateSampleTimeOffsetValue'));
                    end

                    if(st(1)==-1)&&(st(2)~=0)
                        error(message('Simulink:tools:LCTErrorValidateSampleTimeOffsetValue1'));
                    end

                    if(st(1)==0)&&(st(2)~=1)
                        error(message('Simulink:tools:LCTErrorValidateSampleTimeOffsetValue2'));
                    end
                end

            else
                hasError=true;
            end
        end

        if hasError==true
            error(message('Simulink:tools:LCTErrorValidateSampleTimeField'));
        else
            varargout{1}=st;
        end

    case 'SFunctionName'

        sfcnName=varargin{2};
        if isempty(sfcnName)||~isCharCompatible(sfcnName)
            error(message('Simulink:tools:LCTErrorValidateEmptyStringField','SFunctionName'));
        end


        [~,SFunctionName]=fileparts(char(sfcnName));
        SFunctionName=regexprep(SFunctionName,'^\s+|\s+$','');


        if~isempty(regexp(SFunctionName,'\W','once'))
            error(message('Simulink:tools:LCTErrorValidateSFunctionName',SFunctionName));
        end
        varargout{1}=SFunctionName;

    case 'OutputFcnSpec'

        outputFcnSpec=varargin{2};
        if~isempty(outputFcnSpec)
            if~isCharCompatible(outputFcnSpec)
                error(message('Simulink:tools:LCTErrorValidateEmptyStringField','OutputFcnSpec'));
            end
            outputFcnSpec=char(outputFcnSpec);
        end
        varargout{1}=outputFcnSpec;

    case 'InitializeConditionsFcnSpec'

        initCondFcnSpecs=varargin{2};
        if~isempty(initCondFcnSpecs)
            if~isCharCompatible(initCondFcnSpecs)
                error(message('Simulink:tools:LCTErrorValidateEmptyStringField','InitializeConditionsFcnSpec'));
            end
            initCondFcnSpecs=char(initCondFcnSpecs);
        end
        varargout{1}=initCondFcnSpecs;

    case 'StartFcnSpec'

        startFcnSpec=varargin{2};
        if~isempty(startFcnSpec)
            if~iscell(startFcnSpec)
                startFcnSpec={startFcnSpec};
            end
            for idx=1:numel(startFcnSpec)
                if~isCharCompatible(startFcnSpec{idx})
                    error(message('Simulink:tools:LCTErrorValidateEmptyStringField','StartFcnSpec'));
                end
                startFcnSpec{idx}=char(startFcnSpec{idx});
            end
        end
        if numel(startFcnSpec)==1
            varargout{1}=startFcnSpec{1};
        else
            varargout{1}=startFcnSpec;
        end

    case 'TerminateFcnSpec'

        terminateFcnSpec=varargin{2};
        if~isempty(terminateFcnSpec)
            if~isCharCompatible(terminateFcnSpec)
                error(message('Simulink:tools:LCTErrorValidateEmptyStringField','TerminateFcnSpec'));
            end
            terminateFcnSpec=char(terminateFcnSpec);
        end
        varargout{1}=terminateFcnSpec;

    case 'HeaderFiles'

        headerFilesCellStr=varargin{2};
        if~isempty(headerFilesCellStr)
            if~isCellStrCompatible(headerFilesCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','HeaderFiles'));
            end

            headerFilesCellStr=cellstr(headerFilesCellStr(:));


            headerFilesCellStr(cellfun('isempty',headerFilesCellStr))=[];


            for ii=1:length(headerFilesCellStr)
                if(headerFilesCellStr{ii}(1)=='"'&&headerFilesCellStr{ii}(end)~='"')||...
                    (headerFilesCellStr{ii}(1)=='<'&&headerFilesCellStr{ii}(end)~='>')
                    error(message('Simulink:tools:LCTErrorValidateBadFile',...
                    'header',headerFilesCellStr{ii}));
                end
            end


            for ii=1:length(headerFilesCellStr)
                [p,headerFiles,e]=fileparts(headerFilesCellStr{ii});
                if~isempty(p)
                    error(message('Simulink:tools:LCTErrorValidateBadHeaderFile',p));
                end
                if~isempty(headerFiles)
                    if isempty(e)
                        e='.h';
                    end
                    headerFilesCellStr{ii}=[headerFiles,e];
                else
                    error(message('Simulink:tools:LCTErrorValidateBadFile','header',headerFilesCellStr{ii}));
                end
            end
        end
        varargout{1}=headerFilesCellStr;

    case 'IncPaths'
        IncPathsCellStr=varargin{2};

        if~isempty(IncPathsCellStr)
            if~isCellStrCompatible(IncPathsCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','IncPaths'));
            end

            IncPathsCellStr=cellstr(IncPathsCellStr(:));


            IncPathsCellStr(cellfun('isempty',IncPathsCellStr))=[];
        end
        varargout{1}=IncPathsCellStr;

    case 'SourceFiles'
        SourceFilesCellStr=varargin{2};
        FileExtStr=varargin{3};


        if~isempty(SourceFilesCellStr)
            if~isCellStrCompatible(SourceFilesCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','SourceFiles'));
            end


            SourceFilesCellStr=cellstr(SourceFilesCellStr(:));


            SourceFilesCellStr(cellfun('isempty',SourceFilesCellStr))=[];


            for ii=1:length(SourceFilesCellStr)
                [p,SourceFiles,e]=fileparts(SourceFilesCellStr{ii});
                if~isempty(SourceFiles)
                    if isempty(e)
                        e=FileExtStr;
                    end
                    SourceFilesCellStr{ii}=fullfile(p,[SourceFiles,e]);
                else
                    error(message('Simulink:tools:LCTErrorValidateBadFile','source',SourceFilesCellStr{ii}));
                end
            end
        end

        varargout{1}=SourceFilesCellStr;

    case 'SrcPaths'
        SrcPathsCellStr=varargin{2};


        if~isempty(SrcPathsCellStr)
            if~isCellStrCompatible(SrcPathsCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','SrcPaths'));
            end

            SrcPathsCellStr=cellstr(SrcPathsCellStr(:));


            SrcPathsCellStr(cellfun('isempty',SrcPathsCellStr))=[];
        end
        varargout{1}=SrcPathsCellStr;

    case 'HostLibFiles'
        HostLibFilesCellStr=varargin{2};

        if~isempty(HostLibFilesCellStr)
            if~isCellStrCompatible(HostLibFilesCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','HostLibFiles'));
            end


            HostLibFilesCellStr=cellstr(HostLibFilesCellStr(:));


            HostLibFilesCellStr(cellfun('isempty',HostLibFilesCellStr))=[];


            for ii=1:length(HostLibFilesCellStr)
                [p,HostLibFiles,e]=fileparts(HostLibFilesCellStr{ii});
                if~isempty(HostLibFiles)
                    HostLibFilesCellStr{ii}=fullfile(p,[HostLibFiles,e]);
                else
                    error(message('Simulink:tools:LCTErrorValidateBadFile','library',HostLibFilesCellStr{ii}));
                end
            end
        end
        varargout{1}=HostLibFilesCellStr;

    case 'TargetLibFiles'
        TargetLibFilesCellStr=varargin{2};


        if~isempty(TargetLibFilesCellStr)
            if~isCellStrCompatible(TargetLibFilesCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','TargetLibFiles'));
            end


            TargetLibFilesCellStr=cellstr(TargetLibFilesCellStr(:));


            TargetLibFilesCellStr(cellfun('isempty',TargetLibFilesCellStr))=[];


            for ii=1:length(TargetLibFilesCellStr)
                [p,TargetLibFiles,e]=fileparts(TargetLibFilesCellStr{ii});
                if~isempty(TargetLibFiles)
                    TargetLibFilesCellStr{ii}=fullfile(p,[TargetLibFiles,e]);
                else
                    error(message('Simulink:tools:LCTErrorValidateBadFile','library',TargetLibFilesCellStr{ii}));
                end
            end
        end
        varargout{1}=TargetLibFilesCellStr;

    case 'LibPaths'
        LibPathsCellStr=varargin{2};


        if~isempty(LibPathsCellStr)
            if~isCellStrCompatible(LibPathsCellStr)
                error(message('Simulink:tools:LCTErrorValidateCellString','LibPaths'));
            end

            LibPathsCellStr=cellstr(LibPathsCellStr(:));


            LibPathsCellStr(cellfun('isempty',LibPathsCellStr))=[];
        end
        varargout{1}=LibPathsCellStr;

    end
end

function is_allowed=loc_AllowStartFcnSpecAsCell(defs,fieldName)

    if isfield(defs,'Options')&&isfield(defs.Options,'stubSimBehavior')
        is_allowed=defs.Options.stubSimBehavior&&...
        strcmp(fieldName,'StartFcnSpec');
    else
        is_allowed=false;
    end
end

