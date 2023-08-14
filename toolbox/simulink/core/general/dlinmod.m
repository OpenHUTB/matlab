function[a,b,c,d,J]=dlinmod(model,Ts,varargin)


























































    if nargin<2
        Ts=[];
    end;


    lmflag=0;
    v5flag=0;
    spflag=0;
    apflag='off';
    iospec=[];

    ni2=3;
    model=convertStringsToChars(model);
    argin=varargin;
    keep=true(1,nargin-2);
    while(ni2<=nargin)
        cmd=argin{ni2-2};
        if ischar(cmd)||isStringScalar(cmd)
            cmd=convertStringsToChars(cmd);
            switch lower(cmd)
            case 'iospec'
                iospec=argin{ni2-1};
                keep(ni2-1)=false;
                keep(ni2-2)=false;
                ni2=ni2+2;
            case 'ignorediscretestates'
                lmflag=1;
                if~isequal(Ts,0)
                    MSLDiagnostic('Simulink:tools:dlinmodUseZeroTs').reportAsWarning;
                    Ts=0;
                end
                keep(ni2-2)=false;
                ni2=ni2+1;

            case 'v5'
                v5flag=1;
                keep(ni2-2)=false;
                ni2=ni2+1;
            case 'sparse'
                spflag=1;
                keep(ni2-2)=false;
                ni2=ni2+1;
            otherwise
                DAStudio.error('Simulink:tools:dlinmodUnrecognizedOption');
            end
        else
            ni2=ni2+1;
        end
    end
    argin=argin(keep);
    ni=length(argin);

    if v5flag
        if spflag
            MSLDiagnostic('Simulink:tools:dlinmodNoV5Sparse').reportAsWarning;
        end
        if strcmp(apflag,'on')
            MSLDiagnostic('Simulink:tools:dlinmodNoV5AnalysisPorts').reportAsWarning;
        end
        if(lmflag)
            [a,b,c,d]=linmodv5(model,argin{:});
        else
            [a,b,c,d]=dlinmodv5(model,Ts,argin{:});
        end
        return
    end


    [~,normalrefs]=getLinNormalModeBlocks(model);
    models=[model;normalrefs];


    preloaded=false(numel(models,1));
    for ct=1:numel(models)
        if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',models{ct}))
            load_system(models{ct});
        else
            preloaded(ct)=true;
        end
    end


    want=struct('AnalyticLinearization','on',...
    'BufferReuse','off',...
    'SimulationMode','normal',...
    'RTWInlineParameters','on',...
    'InitInArrayFormatMsg','None');


    simstat=strcmp(get_param(model,'SimulationStatus'),'stopped');
    isSimRunning=strcmp(get_param(model,'SimulationStatus'),'running');


    if ni<1,x=[];else x=argin{1};end
    if ni<2,u=[];else u=argin{2};end
    if ni<3,para=[];else para=argin{3};end

    if isempty(para),para=[0;0;0];end
    if para(1)==0,para(1)=1e-5;end
    if length(para)>1,t=para(2);else t=0;end
    if length(para)<3,para(3)=0;end




    if simstat&&ni>0
        if~isempty(x)
            want.InitialState='[]';
            want.LoadInitialState='on';
        end
        want.OutputOption='RefineOutputTimes';



        if~isempty(u)
            tu=[t,reshape(u,1,numel(u))];
            want.ExternalInput=mat2str(tu);
            want.LoadExternalInput='on';
        end
        want.BlockJacobianDiagnostics='off';
    end


    have=local_push_context({model},want);


    if~checkSingleTaskingSolver({model})&&simstat
        DAStudio.error('Simulink:tools:dlinmodMultiTaskingSolver');
    end



    autommd_orig=spparms('autommd');
    spparms('autommd',0);

    try

        if simstat
            feval(model,[],[],[],'lincompile');
        end


        if ni>0
            sizes=feval(model,[],[],[],'sizes');
        end



        if ni>0
            if isempty(x)&&simstat
                x=sl('getInitialState',model);
            end


            if(length(u)~=sizes(4))&&(numel(u)~=0)
                DAStudio.error('Simulink:tools:dlinmodWrongInputVectorSize',sizes(4));
            end

            nxz=sizes(1)+sizes(2);
            if~isstruct(x)&&length(x)<nxz
                MSLDiagnostic('Simulink:tools:dlinmodExtraStatesZero').reportAsWarning;
                x=[x(:);zeros(nxz-length(x),1)];
            end
        end






        if~isSimRunning&&ni>0
            feval(model,[],[],[],'all');
            feval(model,t,x,u,'outputs');
        end


        J=feval(model,iospec,[],[],'jacobian');

        if simstat
            feval(model,[],[],[],'term');
        end

        NestedCleanUp;
    catch e

        if simstat&&strcmp(get_param(model,'SimulationStatus'),'paused')
            feval(model,[],[],[],'term');
        end


        spparms('autommd',autommd_orig);

        NestedCleanUp;
        rethrow(e);
    end

    if nargout==2

        [a,b]=sl('dlinmod_post',J,model,t,Ts,x,u,lmflag,spflag,para);
    elseif nargout==1
        a=sl('dlinmod_post',J,model,t,Ts,x,u,lmflag,spflag,para);
    else
        [a,b,c,d]=sl('dlinmod_post',J,model,t,Ts,x,u,lmflag,spflag,para);
    end



    function NestedCleanUp

        spparms('autommd',autommd_orig);
        local_pop_context({model},have);

        for ct_clean=1:numel(models)
            if~preloaded(ct_clean)
                close_system(models{ct_clean},0);
            end
        end
    end

end


function old_values=local_push_context(models,new)


    for ct=numel(models):-1:1

        old=struct('Dirty',get_param(models{ct},'Dirty'));

        f=fieldnames(new);
        for k=1:length(f)
            prop=f{k};
            have_val=get_param(models{ct},prop);
            want_val=new.(prop);
            set_param(models{ct},prop,want_val);
            old.(prop)=have_val;
        end
        old_values(ct)=old;
    end
end


function local_pop_context(models,old)


    for ct=numel(models):-1:1
        f=fieldnames(old(ct));
        for k=1:length(f)
            prop=f{k};
            if~isequal(prop,'Dirty')
                set_param(models{ct},prop,old(ct).(prop));
            end
        end

        set_param(models{ct},'Dirty',old(ct).Dirty);
    end
end
