classdef ReqSpecTable<slreq.das.Requirement





    properties
        tableObj;
    end

    methods(Access=public)
        function this=ReqSpecTable(tableObj)
            this.tableObj=tableObj;
        end


        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.reqTable;
        end


        function ch=getChildren(this,~)

            if isempty(this.children)
                dataChildren=this.dataModelObj.children;
                view=this.view;
                eventListener=this.eventListener;
                for i=1:numel(dataChildren)
                    thisRowObj=dataChildren(i).tableData;
                    reqDasObj=slreq.das.ReqSpecTableRow(thisRowObj);
                    reqDasObj.postConstructorProcess(dataChildren(i),this,view,eventListener)
                    this.addChildObject(reqDasObj);
                end
            end
            this.childrenCreated=true;


            ch=this.children;
        end
        function label=getDisplayLabel(this)
            label=this.dataModelObj.summary;
        end


        function propValue=getPropValue(this,propName)
            propValue='';

            switch propName
            case 'Index'
                propValue=this.getDisplayLabel;
            case 'ID'
                propValue=this.dataModelObj.id;
            case 'Summary'
                propValue=this.dataModelObj.summary;

            case 'Description'
                propValue=this.Description;
            end
        end

        function[bIsValid]=isValidProperty(~,~)
            bIsValid=true;
        end

        function tf=isDropAllowed(this)%#ok<MANU>
            tf=false;
        end

        function dlgstruct=getDialogSchema(this,dlg)

            chartId=str2double(this.dataModelObj.id);
            url=Stateflow.ReqTable.internal.TableManager.constructUrl(chartId);
            htmlWidget=struct('Type','webbrowser','Url',url);
            dlgstruct.Items={htmlWidget};
            dlgstruct.DialogTitle='';
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[1,1];
        end
    end
end
