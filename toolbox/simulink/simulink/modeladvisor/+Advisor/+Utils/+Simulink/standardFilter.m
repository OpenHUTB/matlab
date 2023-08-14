




































function Remaining=standardFilter(System,Objects,Filters)



    if isa(Objects,'cell')
        Handles=cell2mat(get_param(Objects,'Handle'));
    elseif isa(Objects,'double')
        Handles=Objects;
    elseif isa(Objects,'char')
        Handles=get_param(Objects,'Handle');
    else
        Handles=[];
    end
    if isempty(Handles)
        Remaining=Objects;
        return;
    end



    if nargin==2
        Filters={...
        'Stateflow',...
        'Verification',...
        'Shipping'};
    end
    if ischar(Filters)
        Filters={Filters};
    end
    Filters=unique(Filters);





    for i=1:numel(Filters)
        switch Filters{i}
        case 'Stateflow'
            Handles=filterStateflowSubSystems(System,Handles);
        case 'Verification'
            Handles=filterVerificationSubSystems(System,Handles);
        case 'Shipping'
            Handles=filterShippingSubSystems(System,Handles);
        end
    end



    if isa(Objects,'cell')
        if numel(Handles)==1
            Remaining={getfullname(Handles)};
        else
            Remaining=getfullname(Handles);
        end
    elseif isa(Objects,'double')
        Remaining=Handles;
    elseif isa(Objects,'char')
        Remaining=getfullname(Handles);
    else
        Remaining=[];
    end

end

function Remaining=filterShippingSubSystems(System,Handles)

    ShippingSubSystems=getShippingSubSystems(System);
    Parents=get_param(Handles,'Parent');


    Filter=find(strcmp(get_param(Handles,'Type'),'port'));
    if~isempty(Filter)
        Parents(Filter)=get_param(Parents(Filter),'Parent');
    end

    Keep=true(size(Handles));
    for i=1:numel(ShippingSubSystems)
        thisSubSystem=ShippingSubSystems{i};
        Filter=strncmp(Parents,thisSubSystem,numel(thisSubSystem));
        Keep(Filter)=false;
    end

    Remaining=Handles(Keep);
end

function Remaining=filterVerificationSubSystems(System,Handles)

    VerificationSubSystems=getVerificationSubSystems(System);
    Parents=get_param(Handles,'Parent');


    Filter=find(strcmp(get_param(Handles,'Type'),'port'));
    if~isempty(Filter)
        Parents(Filter)=get_param(Parents(Filter),'Parent');
    end

    Keep=true(size(Handles));
    for i=1:numel(VerificationSubSystems)
        thisSubSystem=VerificationSubSystems{i};
        Filter=strncmp(Parents,thisSubSystem,numel(thisSubSystem));
        Keep(Filter)=false;
    end

    Remaining=Handles(Keep);
end

function Remaining=filterStateflowSubSystems(System,Handles)





    Keep=true(size(Handles));
    for i=1:numel(Handles)
        this=Handles(i);
        Type=get_param(this,'Type');
        switch Type
        case 'block_diagram'
        case 'annotation'
        case 'block'
            if~isSubSystem(this)
                Parent=get_param(this,'Parent');
                if isSubSystem(Parent)
                    if slprivate('is_stateflow_based_block',Parent)
                        Keep(i)=false;
                    end
                end
            end
        case 'line'
            Parent=get_param(this,'Parent');
            if isSubSystem(Parent)
                if slprivate('is_stateflow_based_block',Parent)
                    Keep(i)=false;
                end
            end
        case 'port'
            Parent=get_param(this,'Parent');
            if~isSubSystem(Parent)
                GrandParent=get_param(Parent,'Parent');
                if isSubSystem(GrandParent)
                    if slprivate('is_stateflow_based_block',GrandParent)
                        Keep(i)=false;
                    end
                end
            end
        otherwise
        end
    end

    Remaining=Handles(Keep);
end

function Result=isSubSystem(Handle)
    Result=false;
    if~isempty(Handle)
        Type=get_param(Handle,'Type');
        if strcmp(Type,'block')
            BlockType=get_param(Handle,'BlockType');
            if strcmp(BlockType,'SubSystem')
                Result=true;
            end
        end
    end
end











function SubSystems=getVerificationSubSystems(System)


    SubSystems=find_system(System,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Type','block',...
    'BlockType','SubSystem',...
    'MaskType','VerificationSubsystem');
end

function SubSystems=getShippingSubSystems(System)


    SubSystems=find_system(System,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Type','block',...
    'BlockType','SubSystem',...
    'LinkStatus','resolved');

    filter=false(size(SubSystems));
    for i=1:numel(SubSystems)
        Reference=get_param(SubSystems{i},'ReferenceBlock');
        Library=strtok(Reference,'/');
        switch Library
        case 'simulink'
            filter(i)=true;
        otherwise
            file=Advisor.component.getComponentFile(Library,...
            Advisor.component.Types.Model);
            if Advisor.component.isMWFile(file)
                filter(i)=true;
            end
        end
    end
    SubSystems=SubSystems(filter);



    SignalBuilderSubSystems=find_system(System,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Type','block',...
    'BlockType','SubSystem',...
    'MaskType','Sigbuilder block');
    SubSystems=[...
    SubSystems;...
    SignalBuilderSubSystems];
end

