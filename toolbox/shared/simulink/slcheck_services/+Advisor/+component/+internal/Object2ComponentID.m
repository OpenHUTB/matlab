classdef Object2ComponentID


    properties(Constant)
        ComponentObjectClasses={
        'Simulink.BlockDiagram',...
        'Simulink.SubSystem',...
        'Stateflow.EMChart',...
        'Stateflow.Chart',...
        'Stateflow.TruthTableChart',...
        'Stateflow.StateTransitionTableChart',...
        'Stateflow.EMFunction',...
        };

        FilteredMaskTypes={
        'System Requirements',...
        'System Requirement Item',...
        'DocBlock',...
        'PSB option menu block',...
        }
    end

    methods(Static)


        function id=get(obj,context)
            in.SID='';
            in.LibrarySID='';
            in.File='';
            in.Callstack={};

            if isempty(context)
                in.SID=Simulink.ID.getSID(obj);
            else
                in.SID=Simulink.ID.getSID(context);





                in.LibrarySID=Simulink.ID.getLibSID(obj);

                if isempty(in.LibrarySID)
                    in.LibrarySID=Simulink.ID.getSID(obj);
                end
            end

            id=Advisor.component.internal.generateID(in);
        end





        function pObj=getParentComponentObject(o)

            if Advisor.component.internal.Object2ComponentID.isComponent(o)
                pObj=o;
            elseif isa(o,'Stateflow.LinkChart')
                pObj=o;
            elseif isa(o,'Stateflow.Object')


                if isprop(o,'Chart')
                    pObj=o.Chart;
                else
                    pObj=o;

                    while~(Advisor.component.internal.Object2ComponentID.isComponent(pObj)...
                        ||isempty(pObj))
                        pObj=pObj.getParent();
                    end
                end
            else

                pObj=o;

                while~(Advisor.component.internal.Object2ComponentID.isComponent(pObj)...
                    ||isempty(pObj))
                    pObj=pObj.getParent();
                end
            end
        end








        function[object,context]=resolveObject(objIn)
            object=objIn;
            context=[];

            if isa(objIn,'Stateflow.Object')
                if isa(objIn,'Stateflow.LinkChart')

                    lcHndl=sf('get',double(objIn.Id),'.handle');
                    cId=sfprivate('block2chart',lcHndl);
                    object=idToHandle(sfroot,cId);
                    context=objIn;
                end

            elseif slprivate('is_stateflow_based_block',objIn.Handle)


                if strcmp(objIn.LinkStatus,'none')||strcmp(objIn.LinkStatus,'inactive')
                    sfID=sfprivate('block2chart',objIn.Handle);
                    object=find(objIn,'Id',sfID);

                elseif strcmp(objIn.LinkStatus,'unresolved')
                    object=[];
                    context=find(objIn,'Path',objIn.getFullName(),'-and',...
                    '-isa','Stateflow.LinkChart','-depth',1);

                else




                    sfObj=find(objIn,'Path',getfullname(objIn.Handle),'-and',...
                    '-isa','Stateflow.LinkChart','-depth',1);

                    assert(length(sfObj)==1,'Unexpected number of objects found!')
                    [object,context]=Advisor.component.internal.Object2ComponentID.resolveObject(sfObj);
                end
            else

            end
        end





        function status=isComponent(o)
            status=any(strcmp(class(o),...
            Advisor.component.internal.Object2ComponentID.ComponentObjectClasses));

            if status&&isa(o,'Simulink.SubSystem')




                status=o.isHierarchical&&...
                (isempty(o.MaskType)||...
                ~any(strcmp(Advisor.component.internal.Object2ComponentID.FilteredMaskTypes,o.MaskType)));
            end
        end
    end
end

