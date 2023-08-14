

classdef(Abstract)BindModeSourceData<handle







    properties(Abstract,SetAccess=protected,GetAccess=public)
        modelName;
        clientName BindMode.ClientNameEnum;

        isGraphical logical;





        modelLevelBinding logical;





        sourceElementPath char;




        hierarchicalPathArray(1,:)cell;



        sourceElementHandle double;



        allowMultipleConnections logical;





        requiresDropDownMenu logical;





    end

    properties(SetAccess=protected,GetAccess=public)

        allowSelectAll logical=false;



        disableSorting logical=false;


        ellipsisPosition char='right';


        requiresInputField logical=false;


        inputLabel char='';

        inputPlaceholder char='';

        updateDiagramLabel char='';


    end

    methods(Abstract)
        getBindableData(this,selectionHandles,activeDropDownValue);
















    end

    methods
        function onModelSelectionChange(this,selectionStyle,selectionTypes,selectionHandles,selectionPosition,blockPosition)







            try
                simStatus=get_param(this.modelName,'SimulationStatus');
            catch

                bMObj=BindMode.BindMode.getInstance();
                BindMode.BindMode.disableBindMode(bMObj.modelObj);
                return;
            end
            if(strcmp(simStatus,'stopped')||this.allowBindWhenSimulating())
                filteredElements=BindMode.utils.filterSLElementsFromSelection(selectionTypes,selectionHandles);
                selectionTypes=filteredElements.selectionTypes;
                selectionHandles=filteredElements.selectionHandles;
                if(numel(selectionHandles)==0)
                    return;
                elseif(numel(selectionHandles)==1&&strcmp(selectionTypes{1},BindMode.SelectionTypeEnum.SLBLOCK.char)&&...
                    strcmp(selectionStyle,BindMode.SelectionStyleEnum.SINGLE.char))


                    selectionPosition=blockPosition;
                else


                    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                    canvas=allStudios(1).App.getActiveEditor.getCanvas;
                    canvas_geom=canvas.GlobalPosition;
                    if(selectionPosition(1)<canvas_geom(1))
                        selectionPosition(1)=canvas_geom(1);
                    elseif(selectionPosition(1)>(canvas_geom(1)+canvas_geom(3)))
                        selectionPosition(1)=canvas_geom(1)+canvas_geom(3);
                    end
                    if(selectionPosition(2)<canvas_geom(2))
                        selectionPosition(2)=canvas_geom(2);
                    elseif selectionPosition(2)>(canvas_geom(2)+canvas_geom(4))
                        selectionPosition(2)=canvas_geom(2)+canvas_geom(4);
                    end
                end
                bmSelectionDataObj=BindMode.BindModeSelectionData(selectionStyle,selectionTypes,selectionHandles,selectionPosition);
                BindMode.BindMode.changeSelectionData(bmSelectionDataObj);
            end
        end

        function onSFChartSelectionChange(this,selectionStyle,selectionTypes,selectionBackendIds,selectionPosition)




            if(this.allowStateflowBinding())


                try
                    simStatus=get_param(this.modelName,'SimulationStatus');
                catch

                    bMObj=BindMode.BindMode.getInstance();
                    BindMode.BindMode.disableBindMode(bMObj.modelObj);
                    return;
                end
                if strcmp(simStatus,'stopped')||this.allowBindWhenSimulating()


                    if selectionStyle==BindMode.SelectionStyleEnum.MARQUEE
                        allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                        canvas=allStudios(1).App.getActiveEditor.getCanvas;
                        canvas_geom=canvas.GlobalPosition;
                        if(selectionPosition(1)<canvas_geom(1))
                            selectionPosition(1)=canvas_geom(1);
                        elseif(selectionPosition(1)>(canvas_geom(1)+canvas_geom(3)))
                            selectionPosition(1)=canvas_geom(1)+canvas_geom(3);
                        end
                        if(selectionPosition(2)<canvas_geom(2))
                            selectionPosition(2)=canvas_geom(2);
                        elseif selectionPosition(2)>(canvas_geom(2)+canvas_geom(4))
                            selectionPosition(2)=canvas_geom(2)+canvas_geom(4);
                        end
                    end
                    bmSelectionDataObj=BindMode.BindModeSelectionData(selectionStyle,selectionTypes,[],selectionPosition,selectionBackendIds);
                    BindMode.BindMode.changeSelectionData(bmSelectionDataObj);
                end
            end
        end

        function result=onSelectAllChange(this,dropDownValue,bindableRows,isChecked)



            result=true;
        end

        function result=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)


            result=true;
        end

        function result=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)


            result=true;
        end

        function result=onTableElementClick(this,elementType,bindableMetaData)



            modelHandle=get_param(this.modelName,'Handle');
            if(isfield(bindableMetaData,'blockHandle'))
                blockHandle=str2double(bindableMetaData.blockHandle);
            else
                blockHandle=get_param(bindableMetaData.blockPathStr,'Handle');
            end
            portNumber=-1;
            if(strcmp(elementType,BindMode.BindableTypeEnum.SLSIGNAL.char))
                portNumber=bindableMetaData.outputPortNumber;
            end
            result=BindMode.utils.highlightElementInModel(modelHandle,elementType,blockHandle,portNumber);
        end

        function[result,errorMessage]=onInputFieldChange(this,row)




            result=false;
            errorMessage='';
        end

        function result=allowBindWhenSimulating(~)
            result=false;
        end

        function result=allowStateflowBinding(~)
            result=false;
        end

        function rowInfo=getSFBindableData(this,selectionBackendIds,activeDropDownValue)
            rowInfo.updateDiagramButtonRequired=false;
            rowInfo.bindableRows={};
            rowInfo.Error=false;
        end

        function rowInfo=getStandaloneBindableData(this,activeDropDownValue)
            rowInfo.updateDiagramButtonRequired=false;
            rowInfo.bindableRows={};
            rowInfo.Error=false;
        end

        function result=shouldShowHelpNotification(~)


            result=true;
        end
    end
end