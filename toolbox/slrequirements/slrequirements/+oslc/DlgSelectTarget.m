classdef DlgSelectTarget<handle



    properties
id
projName
callerObj
make2way
allowMultiselect
    end

    methods

        function obj=DlgSelectTarget(id,projName,callerObj,make2way,allowMultiselect)
            obj.id=id;
            obj.projName=projName;
            obj.callerObj=callerObj;
            obj.make2way=make2way;
            obj.allowMultiselect=allowMultiselect;
        end

        function dlgStruct=getDialogSchema(obj)

            lbl1.Type='text';
            lbl1.Name=getString(message('Slvnv:oslc:ProjectArea'));
            lbl1.ColSpan=[1,2];
            lbl1.RowSpan=[1,1];

            cmb.Type='combobox';
            cmb.Name='';
            cmb.Tag='SimulinkDNGPrjectCombo';
            cmb.Entries=[{['<',getString(message('Slvnv:oslc:ProjectNotSpecified')),'>']};...
            oslc.Project.getProjectNames()];
            currentProjectName=oslc.Project.currentProject();
            matchIdx=find(strcmp(cmb.Entries,currentProjectName));
            if length(matchIdx)==1
                cmb.Value=matchIdx-1;
            end
            cmb.RowSpan=[2,2];
            cmb.ColSpan=[1,2];

            lbl2.Type='text';
            lbl2.Name=getString(message('Slvnv:oslc:SpecifyId'));
            lbl2.RowSpan=[3,3];
            lbl2.ColSpan=[1,1];

            edt.Type='edit';
            if~isempty(obj.id)
                edt.Value=num2str(obj.id);
            end
            edt.Tag='SimulinkDNGIdEdit';
            edt.RowSpan=[3,3];
            edt.ColSpan=[2,2];

            dlgStruct.DialogTitle=getString(message('Slvnv:oslc:DngLinkTarget'));
            dlgStruct.LayoutGrid=[3,2];
            dlgStruct.Items={
            lbl1,cmb,...
            lbl2,edt};
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};

            dlgStruct.PreApplyCallback='preApplyCallback';
            dlgStruct.PreApplyArgs={obj,'%dialog'};
            dlgStruct.CloseCallback='onClose';
            dlgStruct.CloseArgs={obj,'%dialog'};
            dlgStruct.Sticky=true;

        end

        function onClose(obj,dlg)%#ok<INUSD>
            ReqMgr.activeDlgUtil('clear');
        end

        function[isValid,msg]=preApplyCallback(obj,dlg)

            idx=dlg.getWidgetValue('SimulinkDNGPrjectCombo');
            if idx==0
                msg=getString(message('Slvnv:oslc:PleaseSelectProjectName'));
                isValid=false;
                return;
            end
            givenProjName=dlg.getComboBoxText('SimulinkDNGPrjectCombo');




            project=oslc.Project.get(givenProjName);


            queryBase=project.queryBase;
            if isempty(queryBase)
                msg=getString(message('Slvnv:oslc:ProjectAreaNameInvalid',givenProjName));
                isValid=false;
                return;
            end

            givenId=strrep(dlg.getWidgetValue('SimulinkDNGIdEdit'),' ','');
            if isempty(givenId)

                msg=getString(message('Slvnv:oslc:PleaseSelectValidId'));
                isValid=false;
                return;
            elseif~all((givenId>=double('0')&givenId<=double('9'))|givenId==double(','))

                msg=getString(message('Slvnv:oslc:PleaseSelectValidId'));
                isValid=false;
                return;
            end


            ids=sscanf(givenId,'%d,');
            for i=1:length(ids)
                try
                    if isempty(oslc.getReqItem(ids(i),givenProjName))
                        msg=getString(message('Slvnv:oslc:FailedToFindIdInProject',ids(i),givenProjName));
                        isValid=false;
                        return;
                    end
                catch Mex
                    msg=Mex.message;
                    isValid=false;
                    return;
                end
            end






            if length(ids)>1
                if~obj.allowMultiselect
                    msg=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkTooManyObjects'));
                    isValid=false;
                    return;
                else
                    label=sprintf('count%d',length(ids));
                end
            else
                label='';
            end
            oslc.selection(givenId,label);

            linkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
            reqstruct=feval(linkType.SelectionLinkFcn,obj.callerObj,obj.make2way,obj.allowMultiselect);

            if~obj.allowMultiselect


                parentDlgH=ReqMgr.activeDlgUtil();
                if~isempty(parentDlgH)
                    [isValid,msg]=updateFieldsInParentDialog(parentDlgH,reqstruct);
                    ReqMgr.activeDlgUtil('clear');
                    oslc.selection('','');
                    return;
                end
            end

            try

                srcType=rmiut.resolveType(obj.callerObj);

                if strcmp(srcType,'matlab')
                    [src,bookmark]=strtok(obj.callerObj,'|');
                    rmiml.catReqs(reqstruct,src,bookmark(2:end));

                elseif strcmp(srcType,'testmgr')

                    reqs=rmitm.getReqs(obj.callerObj);
                    rmitm.setReqs(obj.callerObj,[reqs;reqstruct]);
                else

                    rmi.catReqs(obj.callerObj,reqstruct);
                    rmiut.hiliteAndFade(obj.callerObj);
                end
                isValid=true;
                msg='';

            catch Mex
                msg={getString(message('Slvnv:reqmgt:linktype_rmi_word:RequirementsFailedToAddLink')),...
                Mex.message};
                isValid=false;
            end

            oslc.selection('','');
        end

    end
end


function[status,msg]=updateFieldsInParentDialog(parentDlgH,reqstruct)


    try
        dlgSrc=parentDlgH.getSource();
        parentDlgH.setWidgetValue('docEdit',reqstruct.doc);
        dlgSrc.changeDocItem(parentDlgH);
        parentDlgH.setWidgetValue('locEdit',reqstruct.id);
        dlgSrc.doLocChange(parentDlgH);
        parentDlgH.setWidgetValue('descEdit',reqstruct.description);
        dlgSrc.changeDescItem(parentDlgH);
        status=true;
        msg='';
    catch ex
        status=false;
        msg=ex.message;
    end
end
