function vars=findVars(varargin)




































































































    if(nargin>1)
        for i=2:nargin
            if isa(varargin{i},'Simulink.data.VariableIdentifier')
                varUsg=Simulink.VariableUsage.empty(numel(varargin{i}),0);
                for j=1:numel(varargin{i})
                    varUsg(j)=varargin{i}(j).sdwTemp_getVariableUsage();
                end
                varargin{i}=varUsg;
            end
        end
    end

    if loc_SearchRefModels(varargin{2:nargin})





        mdlsInBlockContext={};
        topMdlsToLoad={};


        modelsToCompile={};
        if ischar(varargin{1})
            origContext=varargin(1);
        else
            origContext=varargin{1};
        end
        for i=1:numel(origContext)
            aContext=origContext{i};

            if loc_IsBlock(aContext)





                mdlRefBlks=find_system(aContext,...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on',...
                'BlockType','ModelReference',...
                'ProtectedModel','off');
                if~isempty(mdlRefBlks)
                    refMdls=get_param(mdlRefBlks,'ModelName');

                    mdlsInBlockContext=union(mdlsInBlockContext,refMdls);

                    topModelName=strtok(aContext,'/');
                    subModelsToCompile=loc_GetSubModelsMayNotCompile(topModelName,mdlRefBlks);
                    modelsToCompile=union(modelsToCompile,subModelsToCompile);
                end
            else

                topMdlsToLoad=union(topMdlsToLoad,{aContext});
            end
        end





        topMdlsToLoad=union(topMdlsToLoad,mdlsInBlockContext);



        for i=1:numel(topMdlsToLoad)





            [refMdls,refBlks]=find_mdlrefs(topMdlsToLoad{i},...
            'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);...


            for j=1:numel(refMdls)
                load_system(refMdls{j});
            end

            subModelsToCompile=loc_GetSubModelsMayNotCompile(topMdlsToLoad{i},refBlks);
            modelsToCompile=union(modelsToCompile,subModelsToCompile);
        end





        for i=1:numel(modelsToCompile)

            Simulink.findVarsImpl(modelsToCompile{i});
        end







        vars=Simulink.findVarsImpl(varargin{:});


        if~isempty(mdlsInBlockContext)
            vars2=Simulink.findVarsImpl(mdlsInBlockContext,varargin{2:nargin},'SearchMethod','cached');

            if~isempty(vars2)
                vars=union(vars,vars2);
            end
        end





    else

        if~isempty(varargin)
            vars=Simulink.findVarsImpl(varargin{:});
        else

            vars=Simulink.findVarsImpl();
        end
    end
end


function ret=loc_IsBlock(aContext)
    try
        type=get_param(aContext,'Type');
    catch
        DAStudio.error('Simulink:Data:TraceabilityInvalidContext',aContext);
    end
    ret=strcmp(type,'block');
end


function ret=loc_SearchRefModels(varargin)
    ret=false;


    if nargin<=1
        return;
    end


    PVPairIndex=1;
    if isa(varargin{1},'Simulink.VariableUsage')
        PVPairIndex=2;
    end


    while PVPairIndex<nargin
        param=varargin{PVPairIndex};
        if(ischar(param)||isstring(param))&&...
            strcmpi(param,'SearchReferencedModels')
            optVal=varargin{PVPairIndex+1};
            switch class(optVal)
            case 'double'
                ret=isscalar(optVal)&&optVal~=0;
            case 'logical'
                ret=isscalar(optVal)&&optVal;
            case 'char'
                ret=strcmpi(optVal,'on');
            otherwise

            end
            return;
        end
        PVPairIndex=PVPairIndex+2;
    end
end

function models=loc_GetSubModelsMayNotCompile(topModel,refBlks)




    models={};

    setting=get_param(topModel,'UpdateModelReferenceTargets');

    switch setting
    case{'Force','IfOutOfDateOrStructuralChange'}

    case{'IfOutOfDate','AssumeUpToDate'}

        for i=1:numel(refBlks)

            if strcmp(get_param(refBlks{i},'ProtectedModel'),'off')

                mode=get_param(refBlks{i},'SimulationMode');


                if~strcmp(mode,'Normal')
                    name=get_param(refBlks{i},'ModelName');
                    models=union(models,{name});
                end
            end
        end
    otherwise
        assert(false,'Unknown setting for model reference rebuild.');
    end
end


