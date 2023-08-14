function filtered_children=filter(children)




    filtered_children=[];

    if(isempty(children))
        return;
    end


    children=find(children,'-depth',0,...
    '-not','-isa','Stateflow.EMChart',...
    '-not','-isa','Stateflow.EMFunction',...
    '-not','-isa','DAStudio.WorkspaceNode',...
    '-not','-isa','Simulink.slobject.WorkspaceNode',...
    '-not','-isa','Simulink.ConfigSet',...
    '-not','-isa','Simulink.code',...
    '-not','-isa','Simulink.ModelAdvisor',...
    '-not','-isa','Simulink.Annotation',...
    '-not','-isa','DAStudio.Shortcut',...
    '-not','-isa','Simulink.Target');%#ok<GTARG>


    for i=1:numel(children)
        subsys=children(i);
        if locIsValid(subsys)
            filtered_children=[filtered_children,subsys];%#ok<AGROW>
        end
    end

end


function b=locIsValid(subsys)

    b=subsys.isHierarchical;
    if~b
        return;
    end


    if isa(subsys,'Stateflow.Object')||...
        isa(subsys,'Simulink.BlockDiagram')||...
        isa(subsys,'Simulink.ModelReference')
        return;
    end


    if isa(subsys.getChildren,'Simulink.Annotation')
        b=false;
        return;
    end


    try
        if(~isempty(strfind(subsys.OpenFcn,'demo'))||...
            ~isempty(strfind(subsys.OpenFcn,'fxptdlg'))||...
            ~isempty(strfind(subsys.OpenFcn,'simcad'))||...
            ~isempty(strfind(subsys.OpenFcn,'helpbrowser')))
            b=false;
        end
    catch me %#ok<NASGU>
        b=false;
    end


    isSFMaskedSubSystem=subsys.isa('Simulink.Block')&&slprivate('is_stateflow_based_block',subsys.Handle);
    if subsys.isMasked&&~isSFMaskedSubSystem
        if strcmp(subsys.MaskHideContents,'on')
            b=false;
            return;
        end
    end

end
