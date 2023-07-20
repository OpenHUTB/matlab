classdef ReqSpecTableRow<slreq.das.Requirement





    properties
        rowObj;
        rowIdx;
    end

    methods(Access=public)
        function this=ReqSpecTableRow(rowObj)
            this.rowObj=rowObj;
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


        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.reqTableRow;
        end

        function label=getDisplayLabel(this)
            label=this.dataModelObj.id;
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
            case 'Precondition'
                propValue=this.rowObj.columns{'preCondition-2'}.columnValue;
            end
        end

        function[bIsValid]=isValidProperty(~,~)
            bIsValid=true;
        end

        function tf=isEditablePropertyInInspector(~,~)
            tf=false;
        end

        function tf=isDropAllowed(this)%#ok<MANU>
            tf=false;
        end

        function out=Precondition(this)
            out='';
            try
                cond=this.rowObj.columns{'preCondition-2'};
                out=cond.columnValue;
            catch
            end
        end

        function out=Action(this)
            out='';
            try
                cond=this.rowObj.columns{'action-2'};
                out=cond.columnValue;
            catch
            end
        end

















    end

end