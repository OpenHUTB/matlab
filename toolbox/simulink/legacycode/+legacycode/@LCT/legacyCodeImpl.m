function varargout=legacyCodeImpl(action,varargin)




    narginchk(1,inf);
    validateattributes(action,{'char','string'},{'scalartext'},1);


    inputArgHasLctObj=false;
    if nargin>1
        inputArgHasLctObj=iCheckInputOptionalArgs(varargin{:});

        if(inputArgHasLctObj)
            lcObj=varargin{end};
        end
    end

    switch lower(action)
    case 'backward_compatibility'
        narginchk(1,1);
        addpath(fullfile(fileparts(which('legacy_code')),'legacycode'));

    case 'help'
        legacycode.LCT.help();

    case 'initialize'
        narginchk(1,3);





        if(~inputArgHasLctObj)
            if nargin==2
                lcStructArray=varargin{1};
                lcObj=iCreateLctObject(lcStructArray);
            else
                lcObj=iCreateLctObject();
            end
        end
        [varargout{1:nargout}]=legacycode.LCT.getSpecStruct(true,lcObj);

    case 'sfcn_cmex_generate'



        if nargin<2
            error(message('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct'));
        end
        lcStructArray=varargin{1};
        structSize=numel(lcStructArray);
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end
        for i=1:structSize
            lcObj(i).generatesfcn();
        end

    case 'compile'





        if nargin<2
            error(message('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct'));
        end
        if nargin>2
            if inputArgHasLctObj
                args=varargin(2:end-1);
            else
                args=varargin(2:end);
            end
        else
            args={};
        end

        lcStructArray=varargin{1};
        structSize=numel(lcStructArray);
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end

        for i=1:structSize
            lcObj(i).compile(args{:});
        end

    case 'sfcn_tlc_generate'



        if nargin<2
            error(message('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct'));
        end
        lcStructArray=varargin{1};
        structSize=numel(lcStructArray);
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end

        for i=1:structSize
            lcObj(i).generatetlc();
        end

    case 'generate_for_sim'



        if nargin<2
            error(message('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct'));
        end
        lcStructArray=varargin{1};
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end
        lcObj.generatesimfiles();

    case 'rtwmakecfg_generate'



        if nargin<2
            error(message('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct'));
        end
        lcStructArray=varargin{1};
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end
        generatemakecfg(lcObj,0);

    case 'sfcn_makecfg_generate'

        if nargin<2
            DAStudio.error('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct');
        end
        lcStructArray=varargin{1};
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end
        generatemakecfg(lcObj,1);

    case 'slblock_generate'





        if nargin<2
            error(message('Simulink:tools:LCTErrorSecondFcnArgumentMustBeStruct'));
        end
        if nargin>2
            if inputArgHasLctObj
                args=varargin(2:end-1);
            else
                args=varargin(2:end);
            end
        else
            args={};
        end

        lcStructArray=varargin{1};
        if(~inputArgHasLctObj)
            lcObj=iCreateLctObject(lcStructArray);
        end
        lcObj.generateslblock(args{:});

    otherwise
        error(message('Simulink:tools:LCTErrorInvalidAction',char(action)));

    end

    function inputArgHasLctObj=iCheckInputOptionalArgs(varargin)


        if iBaseClassIsLct(varargin{end})
            inputArgHasLctObj=true;
        else
            inputArgHasLctObj=false;
        end

        function lcObj=iCreateLctObject(lcStruct)
            if(nargin>0)
                lcObj=legacycode.LCT(lcStruct);
            else
                lcObj=legacycode.LCT();
            end

            function tf=iBaseClassIsLct(arg)


                tf=isa(arg,'legacycode.LCT');


