classdef ComponentFactory
    methods(Static)
        function comp=createSlComponent(slCompObj,contextObj)

            comp=[];

            switch class(slCompObj)

            case 'Simulink.BlockDiagram'
                comp=Advisor.component.filebased.Model();
                comp.IsLibrary=strcmpi(...
                get_param(slCompObj.Handle,'BlockDiagramType'),'library');

            case 'Simulink.SubSystem'
                comp=Advisor.component.subhierarchy.SubSystem();
                comp.IsMasked=strcmp(get_param(slCompObj.Handle,'Mask'),'on');
                comp.IsAtomic=strcmp(slCompObj.IsSubsystemVirtual,'off');

            case 'Stateflow.EMChart'
                comp=Advisor.component.subhierarchy.MATLABFunction();
                comp.IsMasked=strcmp(get_param(slCompObj.Path,'Mask'),'on');

            case 'Stateflow.EMFunction'
                comp=Advisor.component.subhierarchy.MATLABFunction();
                comp.IsMasked=false;

            case 'Stateflow.Chart'

                comp=Advisor.component.subhierarchy.Chart();
                comp.IsMasked=strcmp(get_param(slCompObj.Path,'Mask'),'on');

            case{'Stateflow.StateTransitionTableChart',...
                'Stateflow.TruthTableChart'}

                comp=Advisor.component.subhierarchy.Chart();
                comp.IsMasked=strcmp(get_param(slCompObj.Path,'Mask'),'on');

            case 'Stateflow.LinkChart'


                assert(false,'Resolve object prior to calling ComponentFactory!');

            otherwise




                comp=[];
            end

            if~isempty(comp)
                comp.Name=slCompObj.Name;
                comp.ID=Advisor.component.internal.Object2ComponentID.get(slCompObj,contextObj);

                path=Advisor.component.internal.ComponentFactory.getComponentPath(...
                comp,slCompObj,contextObj);
                comp.setPath(path);

                if comp.Type~=Advisor.component.Types.Model

                    if isempty(contextObj)&&~isa(slCompObj,'Stateflow.Object')
                        if strcmp(slCompObj.LinkStatus,'implicit')
                            comp.ReferenceBlock=slCompObj.ReferenceBlock;

                        elseif strcmp(slCompObj.LinkStatus,'resolved')
                            comp.setIsLinked(true);
                            comp.ReferenceBlock=slCompObj.ReferenceBlock;
                        end

                    elseif~isempty(contextObj)
                        if strcmp(get_param(contextObj.Path,'LinkStatus'),'implicit')
                            comp.ReferenceBlock=slCompObj.getFullName();

                        elseif strcmp(get_param(contextObj.Path,'LinkStatus'),'resolved')&&...
                            ~isa(slCompObj,'Stateflow.EMFunction')






                            comp.setIsLinked(true);
                            comp.ReferenceBlock=slCompObj.getFullName();
                        end
                    end
                end
            end
        end


        function component=createProtectedModelComponent(modelName)

            componentID=Advisor.component.ComponentIDGenerator.generateID(...
            'SID',modelName);

            component=Advisor.component.filebased.ProtectedModel();
            component.ID=componentID;
            component.Name=modelName;
            component.setPath(modelName);
        end
    end

    methods(Static,Access=private)
        function path=getComponentPath(comp,slCompObj,contextObj)

            path='';

            switch(comp.Type)
            case{Advisor.component.Types.Model,Advisor.component.Types.ProtectedModel}
                path=comp.ID;

            case Advisor.component.Types.SubSystem
                path=slCompObj.getFullName();

            case Advisor.component.Types.Chart

                if~isempty(contextObj)



                    path=contextObj.getFullName();
                else
                    path=slCompObj.getFullName();
                end

            case Advisor.component.Types.MATLABFunction

                if~isempty(contextObj)





                    if isa(slCompObj,'Stateflow.EMChart')
                        path=contextObj.getFullName();
                    else
                        mlfunctionPathInLib=slCompObj.getFullName();
                        instanceChartPath=contextObj.getFullName();
                        chartPathInLib=slCompObj.Chart.getFullName();
                        path=[instanceChartPath,mlfunctionPathInLib(length(chartPathInLib)+1:end)];
                    end
                else
                    path=slCompObj.getFullName();
                end

            otherwise

            end
        end
    end
end
