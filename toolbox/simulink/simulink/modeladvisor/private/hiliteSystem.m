function hiliteSystem(varargin)





mlock
    last_system=hilitedSystem;


    systemNotFound=false;


    openStateflowDialog=false;



    vararginActual=varargin(1:end);
    narginActual=nargin;

    if nargin>1&&strcmp(varargin{end},'on')
        openStateflowDialog=true;

        vararginActual=varargin(1:end-1);
        narginActual=nargin-1;
    elseif nargin>1&&strcmp(varargin{end},'off')



        vararginActual=varargin(1:end-1);
        narginActual=nargin-1;
    end

    if narginActual>=2





        system=vararginActual{1};
        checkIndex=strtok(vararginActual{2},'_');
        IndexInCheck=vararginActual{2}(length(checkIndex)+2:end);

        try
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(modeladvisorprivate('HTMLjsencode',system,'decode'));
            FOUND_OBJECTS=mdladvObj.CheckCellArray{str2double(checkIndex)}.FoundObjects(str2double(IndexInCheck)).handle;
        catch %#ok<CTCH>

            warndlg(DAStudio.message('ModelAdvisor:engine:ModelClosed'));
            return;
        end

        if isempty(FOUND_OBJECTS)
            systemNotFound=true;
        else
            system=FOUND_OBJECTS;
        end

    elseif narginActual==1






        system=vararginActual{1};

        try



            if strncmp(system,'SID:',4)

                modelName=strtok(system(5:end),':');
                load_system(modelName);

                system=Simulink.ID.getHandle(system(5:end));
            elseif strncmp(system,'USE_SID:',8)

                modelName=strtok(system(9:end),':');
                load_system(modelName);
                Simulink.ID.hilite(system(9:end));
                return
            elseif strncmp(system,'MACHINELEVEL_SID:',17)
                [modelName,dataName]=strtok(system(18:end),':');
                dataName=dataName(2:end);
                load_system(modelName);

                rt=sfroot;
                m=rt.find('-isa','Simulink.BlockDiagram','-and',...
                'Name',modelName);
                s=m.find('-isa','Stateflow.Data','Path',modelName,'Name',dataName);
                if isempty(s)

                    cObj=m.find('-isa','Stateflow.Chart','Path',modelName);
                    if~isempty(cObj)
                        s=cObj.find('-isa','Stateflow.Data','Name',dataName);
                    end
                end

                if~isempty(s)
                    s.view;
                end

                return
            elseif strncmp(system,'USE_MULTIPLE_SID:',17)
                originalString=system(18:end);
                sidCell=jsondecode(strrep(originalString,'&quot','"'));






                modelName=strtok(sidCell{1},':');
                load_system(modelName);
                Simulink.ID.hilite(sidCell);
                return
            else
                name=modeladvisorprivate('HTMLjsencode',system,'decode');

                modelName=strtok(name,'/');
                load_system(modelName);

                system=get_param(name,'Handle');
            end
        catch %#ok<CTCH>
            systemNotFound=true;
        end

    else


        return;

    end


    if systemNotFound
        warndlg(DAStudio.message('Simulink:tools:MARegenerateReport'));
        return;
    end

    if isa(system,'Stateflow.Object')
        if isa(system,'Stateflow.EMFunction')
            Simulink.ID.hilite(Simulink.ID.getSID(system));
        else
            sf('Open',system.Id);
        end
        return;

    elseif strcmpi(get_param(system,'Type'),'block')&&...
        strcmp(get_param(system,'BlockType'),'SubSystem')



        try
            subsystemObj=get_param(system,'Object');
            slFunction=Stateflow.SLINSF.SimfcnMan.getSLFunction(subsystemObj);

            if isa(slFunction,'Stateflow.SLFunction')
                sid=Simulink.ID.getSID(slFunction);
                Simulink.ID.hilite(sid);
                return;
            end
        catch E

            disp(E.message);
        end
    end

    try
        systemType=get_param(system,'Type');



        bdroot(system);
    catch %#ok<CTCH>
        warndlg(DAStudio.message('Simulink:tools:MARegenerateReport'));
        return;
    end



    if~isempty(last_system);
        try
            hilite_system(last_system,'none');
        catch %#ok<CTCH>
        end
    end
    try

        notRoot=get_param(system,'parent');
        if~isempty(notRoot)
            tryagain=0;
            try
                hilite_system(system,'find');
                if strcmpi(systemType,'block')
                    if openStateflowDialog&&slprivate('is_stateflow_based_block',system)

                        subsystemObj=get_param(system,'Object');
                        chartObj=subsystemObj.getHierarchicalChildren;
                        chartObj.dialog;
                    else

                    end
                end
            catch %#ok<CTCH>
                tryagain=1;
            end
            if tryagain




                hilite_system(system,'find');
                if strcmpi(systemType,'block')
                    if openStateflowDialog&&slprivate('is_stateflow_based_block',system)

                        subsystemObj=get_param(system,'Object');
                        chartObj=subsystemObj.getHierarchicalChildren;
                        chartObj.dialog;
                    else

                    end
                end
            end
        else



            open_system(system);
        end
        last_system=system;
        hilitedSystem(last_system);
    catch %#ok<CTCH>
    end
