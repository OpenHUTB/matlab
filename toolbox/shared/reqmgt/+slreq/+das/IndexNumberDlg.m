classdef IndexNumberDlg<handle



    properties
dasReq
dataReq
userNumber
displayedNumber
    end

    methods(Access=private)

        function reset(obj)
            obj.dataReq=[];
            obj.dasReq=[];
            obj.userNumber=-1;
            obj.displayedNumber='';
        end

        function tailNumber=getTailNumber(~,indexString)
            dotIdx=find(indexString=='.');
            if isempty(dotIdx)
                tailNumber=indexString;
            else
                tailNumber=indexString(dotIdx(end)+1:end);
            end
        end

    end

    methods

        function obj=IndexNumberDlg()
            obj.reset();
        end

        function setOwner(obj,owner)
            obj.dasReq=owner;
            obj.dataReq=owner.dataModelObj;
            obj.userNumber=obj.dataReq.fixedHIdx;
            obj.displayedNumber=obj.getTailNumber(owner.Index);
        end

        function dlgStruct=getDialogSchema(obj)

            chkb.Type='checkbox';
            chkb.Name=getString(message('Slvnv:slreq:SectionNumberAuto'));
            chkb.Value=obj.userNumber<0;
            chkb.Tag='IndexNumberDlg:AutoNumber';
            chkb.MatlabMethod='feval';
            chkb.MatlabArgs={@auto_check,'%source','%dialog'};
            chkb.RowSpan=[1,1];
            chkb.ColSpan=[1,2];

            lbl.Type='text';
            lbl.Name=getString(message('Slvnv:slreq:SectionNumberEnter'));
            lbl.Tag='IndexNumberDlg:LabelNumber';
            lbl.RowSpan=[2,2];
            lbl.ColSpan=[1,1];
            lbl.Enabled=(obj.userNumber>0);

            edt.Type='edit';
            edt.Value=obj.displayedNumber;
            edt.Tag='IndexNumberDlg:EditNumber';
            edt.RowSpan=[2,2];
            edt.ColSpan=[2,2];
            edt.Enabled=(obj.userNumber>0);

            group.Type='group';
            group.Name=getString(message('Slvnv:slreq:SectionNumberConfigure',obj.dasReq.Id));
            group.LayoutGrid=[2,2];
            group.Items={chkb,lbl,edt};

            srcObjSummary=obj.getSrcObjSummary();
            dlgStruct.DialogTitle=getString(message('Slvnv:slreq:SectionNumberTitle',srcObjSummary));
            dlgStruct.DialogTag='IndexNumberDlg';
            dlgStruct.Items={group};
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};

            dlgStruct.PreApplyCallback='preApplyCallback';
            dlgStruct.PreApplyArgs={obj,'%dialog'};
            dlgStruct.CloseCallback='onClose';
            dlgStruct.CloseArgs={obj,'%dialog'};
            dlgStruct.Sticky=true;
        end

        function auto_check(~,dlg)
            value=dlg.getWidgetValue('IndexNumberDlg:AutoNumber');
            dlg.setEnabled('IndexNumberDlg:LabelNumber',~value);
            dlg.setEnabled('IndexNumberDlg:EditNumber',~value);
        end

        function onClose(obj,dlg)%#ok<INUSD>
            obj.reset();
        end

        function[isValid,msg]=preApplyCallback(obj,dlg)
            isValid=true;
            msg='';
            isAuto=dlg.getWidgetValue('IndexNumberDlg:AutoNumber');
            if isAuto
                obj.dataReq.setHIdx(-1);
            else
                numberStr=dlg.getWidgetValue('IndexNumberDlg:EditNumber');
                wantedNumber=str2num(numberStr);%#ok<ST2NM> 
                if~isempty(wantedNumber)&&floor(wantedNumber)==wantedNumber
                    if wantedNumber~=obj.userNumber
                        obj.dataReq.setHIdx(wantedNumber);
                    end
                else
                    isValid=false;
                    msg=getString(message('Slvnv:rmipref:InvalidArgument',numberStr));
                end
            end
            dlgs=DAStudio.ToolRoot.getOpenDialogs(obj.dasReq);
            slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlgs);
        end

        function goodLabel=getSrcObjSummary(obj)
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
            goodLabel=adapter.getSummaryFromDataReq(obj.dataReq);
        end
    end
end

