


classdef(Sealed=true)EnhancedVariantConditionLegend<handle

    properties(Access=private)
        legendDataForAllModels;
        spreadSheetTag='VariantsDDGSpreadsheet';
    end

    methods(Access=public)



        showLegend(evclHandle,mdlName,varargin);






        removeModel(evclHandle,mdlName);


        dlgstruct=getDialogSchema(handleEnhancedVariantConditionLegend,mdlName);



        printLegend(evclHandle,modelName);





        closeLegend(evclHandle,mdlName);

        controlCodeGenColumn(evclHandle,action,modelName);






        function handle=testPrintAPI(this,mdlName,showCodeGenColumn)
            indexOfModel=this.findIndexForModel(mdlName);
            this.legendDataForAllModels(indexOfModel).uiCheckboxIndicator=showCodeGenColumn;
            handle=this.getAsHGFigure(mdlName);
        end

    end

    methods(Static)



        function obj=getInstance()

mlock
            persistent instance
            if isempty(instance)
                instance=Simulink.EnhancedVariantConditionLegend;



                instance.legendDataForAllModels=struct(...
                'modelName',{},...
                'uiCheckboxIndicator',{},...
                'legendDlg',{});
            end
            obj=instance;
        end
    end


    methods(Access=private)

        function obj=EnhancedVariantConditionLegend
        end


        retFig=getAsHGFigure(~,modelName);


        changeModelName(evclHandle,oldModelName,newModelName);


        function indexOfModel=findIndexForModel(this,mdlName)
            indexOfModel=double.empty();
            for indexOpenDialog=1:size(this.legendDataForAllModels,2)
                if strcmp(this.legendDataForAllModels(indexOpenDialog).modelName,mdlName)
                    indexOfModel=indexOpenDialog;
                end
            end
        end

        function isLegendOpen=isLegendOpen(this,indx)
            isLegendOpen=true;
            if isempty(this.legendDataForAllModels(indx).legendDlg)
                isLegendOpen=false;
            end
        end



        function showCGVCE=checkBoxValueForModel(this,mdlName)
            showCGVCE=false;
            for dialogIndex=1:size(this.legendDataForAllModels,2)
                if strcmp(this.legendDataForAllModels(dialogIndex).modelName,mdlName)
                    showCGVCE=this.legendDataForAllModels(dialogIndex).uiCheckboxIndicator;
                end
            end
        end
    end
end







