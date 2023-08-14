classdef ReqSetInSL<slreq.das.RequirementSet





    properties
        modelObj;
    end

    methods(Access=public)
        function this=ReqSetInSL(dataReqSet,parent,view,eventListener)
            this@slreq.das.RequirementSet(dataReqSet,parent,view,eventListener)

            modelObj=get_param(dataReqSet.description,'Object');
            this.modelObj=modelObj;
        end

        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.slModel;
        end

        function addChild(this,req)
            if~strcmp(req.typeName,'ReqTable')
                return;
            end
            blockH=Simulink.ID.getHandle(req.id);
            chartId=sfprivate('block2chart',blockH);
            specBlock=Stateflow.ReqTable.internal.TableManager.getReqTableModel(chartId);

            reqDasObj=slreq.das.ReqSpecTable(specBlock);
            reqDasObj.postConstructorProcess(req,this,this.view,this.eventListener);
            if isempty(req.parent)
                this.addChildObject(reqDasObj);
            else
                parentDasObj=req.parent.getDasObject();
                if~isempty(parentDasObj)
                    parentDasObj.addChildObject(reqDasObj);
                else

                end
            end
        end

        function label=getDisplayLabel(this)
            label=get(this.modelObj,'Name');
            if strcmp(get(this.modelObj,'Dirty'),'on')
                label=[label,'*'];
            end
        end

        function propValue=getPropValue(this,propName)
            propValue='';
            switch propName
            case 'Index'
                propValue=this.getDisplayLabel;
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

        function dlgstruct=getDialogSchema(this,~)





            dlgstruct=this.modelObj.getDialogSchema('');
        end
    end

end
