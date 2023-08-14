














function[rootCompID,type,linked,file]=parseAnalysisRoot(root,intype)
    linked=false;
    file='';%#ok<NASGU>
    type=loc_parseRootType(intype);

    switch type
    case Advisor.component.Types.Model
        modelName=root;


        if~bdIsLoaded(modelName)
            load_system(modelName);
        end

        rootCompID=modelName;




        file=get_param(modelName,'FileName');

    case{Advisor.component.Types.SubSystem,...
        Advisor.component.Types.Chart,...
        Advisor.component.Types.MATLABFunction}


        idxSlash=regexp(root,'/','once');
        modelName=root(1:idxSlash-1);

        if isempty(modelName)||(idxSlash==length(root))


            DAStudio.error('Advisor:base:Components_IncorrectSubsystemPath',root);
        end


        if~bdIsLoaded(modelName)
            load_system(modelName);
        end




        file=get_param(modelName,'FileName');

        try

            linkStatus=get_param(root,'LinkStatus');
        catch E


            DAStudio.error('Advisor:base:Components_IncorrectSubsystemPath',root);
        end

        if strcmpi(linkStatus,'resolved')||strcmpi(linkStatus,'implicit')
            linked=true;
        elseif strcmpi(linkStatus,'unresolved')
            DAStudio.error('Advisor:base:Components_UnresolvedRoot',root);
        end


        slCompObj=get_param(root,'Object');
        if~Advisor.component.isValidAnalysisRoot(slCompObj)
            DAStudio.error('Advisor:base:Components_IncorrectSubsystemPath',root);
        elseif~strcmpi(slCompObj.Commented,'off')
            DAStudio.error('Advisor:base:CommentedSystemNotSupported',root);
        end

        obj=get_param(root,'Object');


        [obj,contextObj]=...
        Advisor.component.internal.Object2ComponentID.resolveObject(obj);



        if isa(obj,'Simulink.SubSystem')&&~isempty(obj.TemplateBlock)
            DAStudio.error('Advisor:base:Components_ConfigurableSubsystemAnalysisRootError');
        end



        node=Advisor.component.internal.ComponentFactory.createSlComponent(obj,contextObj);


        if isempty(node)
            DAStudio.error('Advisor:base:Components_UnsupportedComponentTypeError');
        else
            type=node.Type;

            rootCompID=node.ID;
        end

    otherwise
        DAStudio.error('Advisor:base:Components_UnsupportedComponentTypeError');
    end
end


function type=loc_parseRootType(intype)
    if ischar(intype)
        switch lower(intype)
        case 'model'
            type=Advisor.component.Types.Model;
        case 'subsystem'
            type=Advisor.component.Types.SubSystem;
        otherwise


            DAStudio.error('Advisor:base:Components_UnsupportedComponentTypeError');
        end
    elseif isa(intype,'Advisor.component.Types')
        type=intype;
    else
        DAStudio.error('Advisor:base:Components_UnsupportedComponentTypeError');
    end
end