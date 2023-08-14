classdef RequirementInfoHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="RequirementInfo";
    end

    properties(Constant,Access=private)
        UnhandledUpstream=i_makeTypes("LinkSet","MATLABFile","DataDictionary","TestManager");
        NavigateUpstream=i_makeTypes("RequirementSet");
    end

    methods
        function unhilite=openDownstream(~,dependency)
            unhilite=i_navigateWithReqAPI(dependency.DownstreamNode,...
            dependency.DownstreamComponent);
        end

        function unhilite=openUpstream(this,dependency)
            subtype=dependency.Type.Leaf;

            if ismember(subtype,this.UnhandledUpstream)
                unhilite=@()[];
            elseif ismember(subtype,this.NavigateUpstream)
                unhilite=i_navigateWithReqAPI(dependency.UpstreamNode,...
                dependency.UpstreamComponent);
            else
                unhilite=i_handleSimulinkOrStateflow(dependency.UpstreamComponent);
            end

        end

    end
end

function types=i_makeTypes(varargin)
    types=cellfun(@dependencies.internal.graph.Type,varargin);
end

function unhilite=i_navigateWithReqAPI(node,component)
    unhilite=@()[];

    id=char(component.Path);

    if ""==id
        return;
    end

    location=node.Location{1};

    rmi.navigate('other',location,id);
end

function unhilite=i_handleSimulinkOrStateflow(component)
    location=component.Path;
    if Simulink.ID.isValid(location)
        unhilite=i_handle_SID(location);
    elseif i_is_valid_block_path(location)
        unhilite=i_handle_block_path(location);
    else
        unhilite=@()[];

        [block_path,ssid]=strtok(location,":");

        if contains(location,":")&&i_is_valid_block_path(block_path)

            sid=Simulink.ID.getSID(block_path);
            attemptedLocation=sid+ssid;

            if Simulink.ID.isValid(attemptedLocation)
                unhilite=i_handle_SID(attemptedLocation);
                return;
            end

        end
        i_warn_for_location_not_found(location);
    end
end

function unhilite=i_handle_SID(validSID)

    h=Simulink.ID.getHandle(validSID);

    if isa(h,'Stateflow.Object')
        unhilite=@()[];
        h.view();
        i_open_RMI_editor(h);
        return
    end

    if isa(h,'Simulink.Object')
        location=getfullname(h.handle);
    else
        location=getfullname(h);
    end

    unhilite=i_handle_block_path(location);
end


function bool=i_is_valid_block_path(location)
    path=Simulink.BlockPath(location);
    try
        path.validate();
        bool=true;
    catch
        bool=false;
    end
end


function unhilite=i_handle_block_path(location)
    hilite_system(location,"find");
    unhilite=@()hilite_system(location,"none");

    i_open_RMI_editor(location);
end

function i_open_RMI_editor(location)
    reqlocn=location;




    opFcn=i_get_param(location,'openfcn');
    if strncmp(opFcn,'sigbuilder_block',16)

        open_system(location);
    else

        reqs=rmi('get',reqlocn);
        if~isempty(reqs)
            rmi('edit',reqlocn);
        else

            i_warn_for_location_not_found(reqlocn);
        end
    end

end

function i_warn_for_location_not_found(location)
    dependencies.warning('RequirementsLocationNotFound',location);
end

function out=i_get_param(varargin)



    try
        out=builtin('get_param',varargin{:});
    catch

        out='';
    end
end


