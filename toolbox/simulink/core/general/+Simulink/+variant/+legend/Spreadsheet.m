classdef Spreadsheet<handle




    properties(SetAccess=private,GetAccess=public)
        m_DlgSource;

        m_modelName;
    end

    methods
        function obj=Spreadsheet(~,dlg,mdlName)

            obj.m_DlgSource=dlg;



            obj.m_modelName=mdlName;
        end

        function aChildren=getChildren(this)





            modelName=this.m_modelName;
            legendData=get_param(modelName,'VariantAnnotations');


            if isempty(legendData)


                legendData.Annotation='--';
                legendData.VVCE='--';
                legendData.CGVCE='--';
                legendData.Workspace='--';
            end

            numVC=length(legendData);
            displayname=modelName;
            for vcIdx=1:numVC


                Simulink.variant.utils.assert(~isempty(legendData(vcIdx).VVCE),'Conditions are empty');



                codeCondition=legendData(vcIdx).CGVCE;
                isStartupCondition=false;


                if isempty(legendData(vcIdx).CGVCE)&&~isempty(legendData(vcIdx).STVCE)
                    isStartupCondition=true;
                    codeCondition=legendData(vcIdx).STVCE;
                end



                aChildren(vcIdx)=...
                Simulink.variant.legend.SpreadsheetRow(this.m_DlgSource,...
                displayname,...
                legendData(vcIdx).Annotation,...
                legendData(vcIdx).VVCE,...
                codeCondition,...
                legendData(vcIdx).Workspace,...
                isStartupCondition);
            end

            this.m_DlgSource.m_Children=aChildren;

        end

        function aResolved=resolveSourceSelection(~,aSelections)
            aResolved=aSelections;
        end

        function registerDAListeners(this)
            bd=get_param(this.m_modelName,'Object');
            bd.registerDAListeners;
        end
    end
end

