function varargout=daemon(mode,varargin)















    persistent DATA;
    persistent PRECACHEMETHOD;
    persistent enable_predict;
    if isempty(DATA)
        DATA=lInitData;
        PRECACHEMETHOD=simscape.internal.cacheMethod();
    end

    varargout={};

    switch mode

    case 'START'


        simscape.slModeFcn(true);


        PRECACHEMETHOD=simscape.internal.cacheMethod(simscape.internal.CacheMethodType.None);

        if nargin==2

            assert(islogical(varargin{1}));
            consistent_only=varargin{1};
            enable_predict=true;
        else
            p=inputParser;
            validateValue=@(x)islogical(x);
            addParameter(p,'ConsistentOnly',true,validateValue);
            addParameter(p,'EnablePrediction',true,validateValue);
            parse(p,varargin{:});

            consistent_only=p.Results.ConsistentOnly;
            enable_predict=p.Results.EnablePrediction;
        end


        nem_sl_daemon(true,consistent_only);


        select_networks_for_daemon(0,'all');

    case 'STOP'


        simscape.slModeFcn(false);


        simscape.internal.cacheMethod(simscape.internal.CacheMethodType(PRECACHEMETHOD));


        nem_sl_daemon(false,false);


        select_networks_for_daemon(0,'clear');


        DATA=lInitData;

    case 'SELECT_NETWORKS'
        [solverPaths]=varargin{:};

        select_networks_for_daemon(0,solverPaths);

    case 'GET'

        outs=struct('data',{},'code',{},'visited',{},'blocks',{},'itersUsed',0,'mlFcnData',lInitMLFcnData);

        for key=fieldnames(DATA)'

            datum=DATA.(key{1});


            if~isempty(datum.points)&&datum.points(1).Index2
                pts=lInitPoint;
                for d=datum.points
                    d.B=d.B(:,1:end/2);
                    d.D=d.D(:,1:end/2);
                    pts(end+1)=d;%#ok
                end
                datum.points=pts;
            end

            outs(end+1)=struct('data',datum.points,...
            'code',datum.code,...
            'visited',datum.visited,...
            'blocks',{datum.blocks},...
            'itersUsed',datum.itersUsed,...
            'mlFcnData',datum.mlFcnData);%#ok
        end


        varargout={outs};


        DATA=lInitData;

    case 'ANNOUNCE'


        [pointer,system]=varargin{:};


        dataKey=sprintf('f%u',pointer);
        DATA.(dataKey)=lInitDatum;



        [~,code]=simscape.slModeFcn;
        DATA.(dataKey).code=code.MODE;
        code.M_P=mc_sp_to_local_sp(code.M_P);
        code.A_P=mc_sp_to_local_sp(code.A_P);
        code.B_P=mc_sp_to_local_sp(code.B_P);
        code.C_P=mc_sp_to_local_sp(code.C_P);
        code.DXF_P=mc_sp_to_local_sp(code.DXF_P);
        code.DUF_P=mc_sp_to_local_sp(code.DUF_P);
        code.DXY_P=mc_sp_to_local_sp(code.DXY_P);
        code.DUY_P=mc_sp_to_local_sp(code.DUY_P);
        DATA.(dataKey).mlFcnData=code;


        DATA.(dataKey).blocks={system.ObservableData.object}';

    case 'PUSH'


        [pointer,system,input,consistent,itersUsed]=varargin{:};
        key=sprintf('%d',input.M);
        dataKey=sprintf('f%u',pointer);
        assert(isfield(DATA,dataKey));
        if(itersUsed~=0)
            DATA.(dataKey).itersUsed=itersUsed;
        end

        if(consistent&&enable_predict)

            x=DATA.(dataKey).x_cache;
            DATA.(dataKey).x_cache=input.X;
            xu=[x;input.U];
            if isempty(x)
                xu=[];
            end


            if DATA.(dataKey).visited.isKey(key)

                DATA.(dataKey).visited(key)=[DATA.(dataKey).visited(key),xu];
            else

                DATA.(dataKey).visited(key)=xu;
            end
        end


        if DATA.(dataKey).cached.isKey(key)
            return;
        else
            DATA.(dataKey).cached(key)=[];
        end





        f=ssc_engmliprivate('ne_sparse_system_method');

        zero_input=input.clone;
        zero_input.X=0*zero_input.X;
        zero_input.U=0*zero_input.U;
        ld=struct(...
        'M',f(system,'M',input),...
        'A',f(system,'DXF',input),...
        'B',f(system,'DUF',input),...
        'C',f(system,'DXY',input),...
        'D',f(system,'DUY',input),...
        'F0',system.F(zero_input),...
        'Y0',system.Y(zero_input),...
        'MODE',input.M,...
        'X',input.X,...
        'U',input.U,...
        'Index2',system.HasConstraints);
        DATA.(dataKey).points(end+1)=ld;
    end

end

function d=lInitPoint
    d=struct('M',{},'A',{},'B',{},'C',{},'D',{},'F0',{},'Y0',{},'MODE',{},'X',{},'U',{},'Index2',{});
end

function d=lInitSparsityPattern
    d=struct('m',[],'n',[],'i',[],'j',[]);
end

function d=lInitMLFcnData
    d=struct('M','','A','','B','','C','','DXF','','DUF','','DXY','','DUY','','F','','Y','','MODE','','M_P',lInitSparsityPattern,'A_P',lInitSparsityPattern,'B_P',lInitSparsityPattern,'C_P',lInitSparsityPattern,'DXF_P',lInitSparsityPattern,'DUF_P',lInitSparsityPattern,'DXY_P',lInitSparsityPattern,'DUY_P',lInitSparsityPattern);
end

function d=lInitDatum
    d=struct('points',lInitPoint,'visited',containers.Map,'cached',containers.Map,'x_cache',[],'code','','blocks',[],'itersUsed',0,'mlFcnData',lInitMLFcnData);
end

function d=lInitData



    d=struct;
end

function lsp=mc_sp_to_local_sp(mc_sp)
    lsp=lInitSparsityPattern;
    lsp.n=mc_sp{1};
    lsp.m=mc_sp{2};
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


