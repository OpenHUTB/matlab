classdef Model<handle




    properties
Name
InitialState
    end

    properties(Dependent)
State
Summary
SimscapeBlocks
    end

    properties(Dependent,Access=private)
Types
TypesCount
    end

    properties(Access=private)
        ExcludeRegexp='';



        LibraryRegexp='(?!^fl_lib/Physical Signals/)^fl_lib/|^ee_lib/|^batteryecm_lib/';
        ModelUpdated=false;
    end

    methods
        function obj=Model(modelName)

            if exist('modelName','var')
                obj.Name=modelName;
            else
                obj.Name=bdroot;
            end
            if isempty(obj.Name)
                error(message('physmod:ee:billofmaterials:LoadOrOpenSimulinkModel'));
            end
            obj.InitialState=obj.State;
            obj.ModelUpdated=false;
        end

        function value=get.State(obj)

            if~obj.isLoadedOrOpen

                value='Closed';
            else

                if strcmp('off',get_param(obj.Name,'Open'))

                    value='Loaded';
                else

                    value='Open';
                end
            end
        end

        function value=get.TypesCount(obj)

            [~,~,componentTypesIdx]=unique(sort({obj.SimscapeBlocks.Type}));
            if~isempty(componentTypesIdx)
                value=histcounts(componentTypesIdx,max(componentTypesIdx))';
            else

                value=[];
            end
        end

        function value=get.Types(obj)

            value=unique({obj.SimscapeBlocks.Type})';
        end

        function value=get.SimscapeBlocks(obj)


            blocks=obj.find();
            value=ee.internal.billofmaterials.SimscapeBlock(blocks);
        end

        function value=get.Summary(obj)

            value=table(obj.TypesCount,'RowNames',obj.Types,'VariableNames',{'Quantity'});
        end

        function value=findSimscapeBlocksOfType(obj,maskType)


            maskType=strrep(maskType,'(','\(');
            maskType=strrep(maskType,')','\)');
            blocks=obj.find('MaskType',sprintf('^%s$',maskType));
            value=ee.internal.billofmaterials.SimscapeBlock(blocks);
        end

        function prePublishState(obj)

            if strcmp(obj.State,'Open')


                obj.State='Loaded';
            end
        end

        function restoreInitialState(obj)

            if~strcmp(obj.State,obj.InitialState)
                obj.State=obj.InitialState;
            end
        end

        function set.State(obj,value)

            switch value
            case 'Closed'
                if obj.isLoadedOrOpen
                    bdclose(obj.Name);
                end
            case 'Loaded'
                if obj.isLoadedOrOpen

                    if strcmp(get_param(obj.Name,'Lock'),'off')
                        set_param(obj.Name,'Open','off');
                    else

                        bdclose(obj.Name);
                        load_system(obj.Name);
                    end
                else
                    load_system(obj.Name);
                end
            case 'Open'
                open_system(obj.Name);
            otherwise

            end
        end
    end

    methods(Access=protected)
        function value=find(obj,varargin)

            if strcmp('Closed',obj.State)
                obj.State='Loaded';
            end


            if~obj.ModelUpdated
                try
                    set_param(obj.Name,'SimulationCommand','Update');
                    obj.ModelUpdated=true;
                catch ME
                    callingModelWithPath=exist(obj.Name,'file')==4&&...
                    (strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')...
                    ||strcmp(ME.identifier,'Simulink:Commands:EmptyBlockDiagramName'));

                    if callingModelWithPath
                        simplifiedME=MException('physmod:ee:billofmaterials:MustBeModelName',message('physmod:ee:billofmaterials:MustBeModelName'));
                        throw(simplifiedME);

                    elseif~strcmp(ME.identifier,'Simulink:Engine:NoBlocksInModel')

                        sldiagviewer.createStage(getString(message('physmod:ee:billofmaterials:BillOfMaterialsReport')),'ModelName',obj.Name);
                        sldiagviewer.reportError(ME);
                        simplifiedME=MException('physmod:ee:billofmaterials:CheckDiagnosticViewer',message('physmod:ee:billofmaterials:CheckDiagnosticViewer'));
                        throw(simplifiedME);
                    end
                end
            end

            findOptions=Simulink.FindOptions;
            findOptions.RegExp=1;
            findOptions.CaseSensitive=1;
            findOptions.FollowLinks=1;
            findOptions.LookInsideSubsystemReference=1;
            findOptions.LookUnderMasks='All';
            findOptions.IncludeCommented=0;
            findOptions.SearchDepth=-1;
            findOptions.Variants='ActiveVariants';
            findOptions.LoadFullyIfNeeded=1;
            value=Simulink.findBlocks(obj.Name,'BlockType','SimscapeBlock','ReferenceBlock',obj.LibraryRegexp,varargin{:},findOptions);
        end

        function value=isLoadedOrOpen(obj)




            modelNames=get_param(Simulink.allBlockDiagrams('model'),'Name');
            if isempty(modelNames)
                value=false;
            else
                value=any(strcmp(obj.Name,modelNames));
            end
        end
    end
end
