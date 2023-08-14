function varargout=swldaemon(mode,varargin)




















    persistent DATA;

    persistent OLDCACHEMETHOD;

    persistent ORIGLTIENGINE;

    if(isempty(DATA))
        DATA=lInitData;
        OLDCACHEMETHOD=simscape.internal.cacheMethod();
        ORIGLTIENGINE=simscape_lti_engine();
    end

    varargout={};

    switch mode
    case 'START'


        simscape_swl_daemon(true);


        OLDCACHEMETHOD=simscape.internal.cacheMethod(simscape.internal.CacheMethodType.None);


        ORIGLTIENGINE=simscape_lti_engine(false);


        select_networks_for_daemon(1,'all');

    case 'STOP'


        simscape_swl_daemon(false);


        simscape.internal.cacheMethod(simscape.internal.CacheMethodType(OLDCACHEMETHOD));


        simscape_lti_engine(ORIGLTIENGINE);


        select_networks_for_daemon(1,'clear');


        DATA=lInitData;

    case 'SELECT_NETWORKS'
        [solverPaths]=varargin{:};

        select_networks_for_daemon(1,solverPaths);

    case 'ANNOUNCE'

        featureIntModes=matlab.internal.feature("SSC2HDLIntegerModes");

        if(featureIntModes)
            [pointer,solverPath,sampleTime,yFunc,modeFunc,modeIndices,qFcn,cacheFcn,intModes]=varargin{:};
        else
            [pointer,solverPath,sampleTime,yFunc,modeFunc,modeIndices,qFcn,cacheFcn]=varargin{:};
        end

        datakey=sprintf('f%u',pointer);
        DATA.(datakey)=lInitSwlNetworkInfo(featureIntModes);

        DATA.(datakey).SolverPath=solverPath;
        DATA.(datakey).SampleTime=sampleTime;
        DATA.(datakey).Y=yFunc;
        DATA.(datakey).GlobalModeFcn=modeFunc;
        DATA.(datakey).ModeIndices=(modeIndices+1);
        DATA.(datakey).QFcn=qFcn;
        DATA.(datakey).CacheFcn=cacheFcn;
        if(featureIntModes)
            DATA.(datakey).IntModes=DATA.(datakey).ModeIndices(logical(intModes));
        end

    case 'ANNOUNCE_DIFF_CLUMP'
        [pointer,diffStates,F,M,M_P,matrixModes,matrixQs]=varargin{:};

        datakey=sprintf('f%u',pointer);
        assert(isfield(DATA,datakey));

        diffClumpInfo=struct('F',F,'DiffStates',diffStates+1,'MatrixModes',(matrixModes+1),'MatrixQs',(matrixQs+1),'MatrixInfo',lInitSwlMatrixInfo,'M',M,'M_P',mc_sp_to_local_sp(M_P));

        DATA.(datakey).DiffClumpInfo=diffClumpInfo;

    case 'ANNOUNCE_SWL_CLUMP'

        featureIntModes=matlab.internal.feature("SSC2HDLIntegerModes");

        if(featureIntModes)
            [pointer,clumpIdx,F,modeFcn,M,M_P,A,A_P,refModes,refStates,refInputs,refQs,refCIs,ownedStates,outFlags,ownedModes,matrixModes,matrixQs,intModes]=varargin{:};
        else
            [pointer,clumpIdx,F,modeFcn,M,M_P,A,A_P,refModes,refStates,refInputs,refQs,refCIs,ownedStates,outFlags,ownedModes,matrixModes,matrixQs]=varargin{:};
        end

        datakey=sprintf('f%u',pointer);
        assert(isfield(DATA,datakey));

        clumpInfo=struct('F',F,'ModeFcn',modeFcn,'ReferencedModes',(refModes+1),'ReferencedStates',(refStates+1),'ReferencedQs',(refQs+1),'ReferencedCIs',(refCIs+1),'ReferencedInputs',(refInputs+1),'OwnedModes',(ownedModes+1),'OwnedStates',(ownedStates+1),'OutFlags',outFlags,'MatrixModes',(matrixModes+1),'MatrixQs',(matrixQs+1),'MatrixInfo',lInitSwlMatrixInfo,'M',M,'M_P',mc_sp_to_local_sp(M_P),'A',A,'A_P',mc_sp_to_local_sp(A_P));

        if(featureIntModes)
            clumpInfo.IntModes=clumpInfo.OwnedModes(logical(intModes));
        end

        DATA.(datakey).ClumpInfo(clumpIdx+1)=clumpInfo;

    case 'PUSH_IC'
        [pointer,icX,icM,icQ,icU,icC]=varargin{:};

        datakey=sprintf('f%u',pointer);
        assert(isfield(DATA,datakey));

        ic=struct('X',icX,'M',icM,'Q',icQ,'U',icU,'C',icC);

        DATA.(datakey).IC=ic;

    case 'PUSH_NUM_ITERS'
        [pointer,n]=varargin{:};

        datakey=sprintf('f%u',pointer);
        assert(isfield(DATA,datakey));

        DATA.(datakey).itersUsed=n;

    case 'PUSH'

        [pointer,clumpIndex,M,A,mode,q]=varargin{:};

        datakey=sprintf('f%u',pointer);
        assert(isfield(DATA,datakey));
        if(clumpIndex==0)
            for(i=1:length(M))
                matrixInfo=struct('M',{M{i}},'A',{A{i}},'ModeVec',{mode{i}},'QVec',{q{i}});
                DATA.(datakey).DiffClumpInfo.MatrixInfo(i)=matrixInfo;
            end
        else
            for(i=1:length(M))
                matrixInfo=struct('M',{M{i}},'A',{A{i}},'ModeVec',{mode{i}},'QVec',{q{i}});
                DATA.(datakey).ClumpInfo(clumpIndex).MatrixInfo(i)=matrixInfo;
            end
        end

    case 'GET'

        varargout={DATA};
    end
end

function d=lInitData
    d=struct;
end

function d=lInitSwlNetworkInfo(featureIntModes)
    if(featureIntModes)
        d=struct('SolverPath','','SampleTime',0.0,'Y','','GlobalModeFcn','','ModeIndices',[],'IC',lInitIC,'itersUsed',[],'DiffClumpInfo',lInitDiffClumpInfo,'ClumpInfo',lInitSwlClumpInfo(featureIntModes),'QFcn','','CacheFcn','','IntModes',[]);
    else
        d=struct('SolverPath','','SampleTime',0.0,'Y','','GlobalModeFcn','','ModeIndices',[],'IC',lInitIC,'itersUsed',[],'DiffClumpInfo',lInitDiffClumpInfo,'ClumpInfo',lInitSwlClumpInfo(featureIntModes),'QFcn','','CacheFcn','');
    end
end

function d=lInitIC
    d=struct('X',[],'M',[],'Q',[],'U',[],'C',[]);
end

function d=lInitSparsityPattern
    d=struct('m',[],'n',[],'i',[],'j',[]);
end

function d=lInitDiffClumpInfo
    d=struct('F','','DiffStates',[],'MatrixModes',[],'MatrixQs',[],'MatrixInfo',lInitSwlMatrixInfo,'M','','M_P',lInitSparsityPattern);
end

function d=lInitSwlClumpInfo(featureIntModes)

    if(featureIntModes)
        d=struct('F','','ModeFcn','','ReferencedModes',[],'ReferencedStates',[],'ReferencedQs',[],'ReferencedCIs',[],'ReferencedInputs',[],'OwnedModes',[],'OwnedStates',[],'OutFlags',[],'MatrixModes',[],'MatrixQs',[],'MatrixInfo',lInitSwlMatrixInfo,'M','','M_P',lInitSparsityPattern,'A','','A_P',lInitSparsityPattern,'IntModes',[]);
    else
        d=struct('F','','ModeFcn','','ReferencedModes',[],'ReferencedStates',[],'ReferencedQs',[],'ReferencedCIs',[],'ReferencedInputs',[],'OwnedModes',[],'OwnedStates',[],'OutFlags',[],'MatrixModes',[],'MatrixQs',[],'MatrixInfo',lInitSwlMatrixInfo,'M','','M_P',lInitSparsityPattern,'A','','A_P',lInitSparsityPattern);
    end
end


function d=lInitSwlMatrixInfo
    d=struct('M',{},'A',{},'ModeVec',{},'QVec',{});
end

function lsp=mc_sp_to_local_sp(mc_sp)
    lsp=lInitSparsityPattern;
    lsp.m=mc_sp{1};
    lsp.n=mc_sp{2};
    Jc=mc_sp{3};
    Ir=mc_sp{4};
    lsp.i=zeros(size(Ir));
    lsp.j=zeros(size(Ir));
    idx=1;
    for(j=1:lsp.n)
        for(i=Jc(j):Jc(j+1)-1)
            lsp.i(idx)=Ir(i+1)+1;
            lsp.j(idx)=j;
            idx=idx+1;
        end
    end
end
