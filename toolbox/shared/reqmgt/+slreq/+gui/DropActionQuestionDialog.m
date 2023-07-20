classdef DropActionQuestionDialog<handle


    properties
        srcObj=slreq.das.Requirement.empty();
        dstObj=slreq.das.Requirement.empty();
dlg
    end

    methods

        function this=DropActionQuestionDialog(srcObj,dstObj)
            this.srcObj=srcObj;
            this.dstObj=dstObj;
        end

        function dlgstruct=getDialogSchema(this)

            topLabel=struct('Type','text','Name','Selection drop action:','RowSpan',[1,1],'ColSpan',[1,2]);
            moveBtn=struct('Type','pushbutton','Name','Move','RowSpan',[1,1],'ColSpan',[1,1],'Tag','moveBtn');
            moveBtn.MatlabMethod='slreq.gui.DropActionQuestionDialog.move';
            moveBtn.MatlabArgs={this};

            linkBtn=struct('Type','pushbutton','Name','Link','RowSpan',[2,2],'ColSpan',[1,1],'Tag','linkBtn');
            linkBtn.MatlabMethod='slreq.gui.DropActionQuestionDialog.link';
            linkBtn.MatlabArgs={this};
            if isa(this.dstObj,'slreq.das.Requirement')
                linkBtn.Enabled=true;
            else
                linkBtn.Enabled=false;
            end

            dlgstruct.DialogTag='DropActionDialog';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.IsScrollable=false;
            dlgstruct.Transient=true;
            dlgstruct.DialogStyle='frameless';
            dlgstruct.DialogTitle='';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.MinimalApply=true;
            dlgstruct.Items={topLabel,moveBtn,linkBtn};
        end
    end

    methods(Static)
        function show(src,dst)
            obj=slreq.gui.DropActionQuestionDialog(src,dst);
            obj.dlg=DAStudio.Dialog(obj);
        end
        function move(this)
            this.srcObj.reparentObjectUnder(this.dstObj);
            if isa(this.dstObj,'slreq.das.Requirement')
                reqSetData=this.dstObj.dataModelObj.getReqSet;
            else

                reqSetData=this.dstObj.dataModelObj;
            end

            reqSetData.updateHIdx();
            this.dstObj.view.update;
            this.dlg.hide;
        end
        function link(this)
            this.dstObj.addLink(this.srcObj);
            this.dstObj.view.update;
            this.dlg.hide;
        end
    end
end