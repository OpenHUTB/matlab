classdef openModelSelector<handle

















    properties(SetObservable=true)

        modelName='';
        position=[];
        dialogTag='';
        dialogTitle='';
        dialogDesc='';
        launchCallback=[];
        hConfigSetControllerCache=[];
        thisDlg=[];
    end

    methods

        function varType=getPropDataType(~,~)

            varType='string';
        end

        function launchDialog(obj,csDialog,...
            key,dlgTitle,dlgDesc,launchFcn)




























            hController=[];
            if~isempty(csDialog.getSource)
                cs=csDialog.getSource;

                if isa(cs,'Simulink.SolverCC')
                    cs=cs.getConfigSet;
                else
                    cs=cs.Source.getCS;
                end

                hController=cs.getDialogController;
                obj.hConfigSetControllerCache=hController;
            end

            openDialog=false;
            if~isempty(hController)&&...
                ~isempty(hController.getSourceObject.getModel)
                model=get_param(hController.getSourceObject.getModel,'Name');
            else
                model=...
                hController.getSourceObject.getConfigSet.ReferenceModelContext;
                openDialog=true;
            end
            obj.modelName=model;



            csDialogPosition=csDialog.Position;
            if~isempty(csDialogPosition)
                x=csDialogPosition(1);
                y=csDialogPosition(2);
                h=csDialogPosition(3);
                w=csDialogPosition(4);
                obj.position=[x+w/2,y+h/2,400,120];
            else
                pos=get(0,'ScreenSize');
                x=pos(3)/4;
                y=pos(4)/2;
                obj.position=[x,y,300,140];
            end


            obj.dialogTag=['_Model_Selector_DDG_',key];
            obj.dialogTitle=dlgTitle;
            obj.dialogDesc=dlgDesc;
            obj.launchCallback=launchFcn;


            if openDialog


                if~obj.showDialogIfExists(cs,obj.dialogTag)
                    hdlg=DAStudio.Dialog(obj);


                    obj.thisDlg=hdlg;

                    hController=cs.getDialogController;


                    hController.ModelSelectorObjs{end+1}=obj;
                end
            else
                if~isempty(obj.launchCallback)
                    feval(obj.launchCallback,obj.modelName);
                end
            end

        end

        function launchUsingBrowser(obj,~,varargin)



            if(nargin>2)
                assert(strcmp(varargin{1},'ForTestingPurposes'));
                mdl=openModelFromBrowser(obj,varargin{2},varargin{3});
            else
                mdl=openModelFromBrowser(obj);
            end

            if isempty(mdl)
                return;
            end
            obj.modelName=mdl;
        end

        function dlg=getDialogSchema(obj)



            modelSelDesc.Name=obj.dialogDesc;
            modelSelDesc.Type='text';



            modelNameEdit.Name='';
            modelNameEdit.Type='edit';
            modelNameEdit.ObjectProperty='modelName';
            modelNameEdit.Tag='modelName_tag';
            modelNameEdit.Graphical=true;
            modelNameEdit.Mode=1;


            Browsebutton.Name=...
            DAStudio.message('Simulink:taskEditor:BrowseButtonTxt');
            Browsebutton.Type='pushbutton';
            Browsebutton.Tag='browse_Tag';
            Browsebutton.MatlabMethod='feval';
            Browsebutton.MatlabArgs=...
            {@(d)d.getDialogSource.launchUsingBrowser(d),'%dialog'};
            Browsebutton.DialogRefresh=true;


            [indexedItems,~]=...
            slprivate('getIndexedGroupItems',2,{...
            modelSelDesc,'blank',...
            modelNameEdit,Browsebutton});



            dlg.DialogTitle=obj.dialogTitle;
            dlg.DialogTag=obj.dialogTag;
            dlg.Items=indexedItems;
            dlg.LayoutGrid=[2,2];
            dlg.RowStretch=[0,1];
            dlg.ColStretch=[1,0];
            dlg.Geometry=obj.position;
            dlg.IsScrollable=false;
            dlg.PreApplyCallback=...
            'Simulink.SoftwareTarget.modelSelectorPreApplyCallback';
            dlg.PreApplyArgs={'%source','%dialog'};
            dlg.StandaloneButtonSet={'OK','Cancel'};
        end

        function mdl=getModelNameWithoutExtension(~,fname)

            [~,modelNameWithoutExt,~]=fileparts(fname);
            mdl=modelNameWithoutExt;

        end
    end

    methods(Access=private)

        function found=showDialogIfExists(~,cs,tag)



            found=false;
            if~isempty(cs.getDialogController)
                objVec=cs.getDialogController.ModelSelectorObjs;
                for i=1:length(objVec)
                    if ishandle(objVec{i}.thisDlg)&&...
                        strcmp(objVec{i}.dialogTag,tag)&&...
                        objVec{i}.thisDlg.isStandAlone
                        objVec{i}.thisDlg.show;
                        found=true;
                        break;
                    end
                end
            end
        end
        function isCancel=resolvePathIssueForAUniqueModel(~,PathName,FileName)





            isCancel=false;

            questDlgMsg=...
            DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathQString',...
            fullfile(PathName,FileName));
            questDlgTitle=...
            DAStudio.message('Simulink:modelReference:selectedMdlPathIssueTitle');
            addPathMsg=...
            DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathAddCurrentSession');
            doNotAddPathMsg=...
            DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathDoNotAdd');
            cancelMsg=...
            DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathCancel');

            choice=questdlg(questDlgMsg,questDlgTitle,...
            addPathMsg,doNotAddPathMsg,cancelMsg,...
            cancelMsg);

            if strcmp(choice,addPathMsg)

                addpath(PathName)
            elseif strcmp(choice,cancelMsg)

                isCancel=true;
            end
        end

        function ret=openModelFromBrowser(obj,varargin)
            ret='';
            exts='*.mdl';
            dlgTitle=DAStudio.message('Simulink:modelReference:browseMdlRefsName');
            if(nargin==1)
                [FileName,PathName,~]=uigetfile(exts,dlgTitle);
            else

                FileName=varargin{1};
                PathName=varargin{2};
            end

            if(~ischar(FileName)&&~FileName)
                return;
            end

            [~,~,ext]=fileparts(FileName);

            if(~((strcmpi(ext,'.mdl'))||...
                (strcmpi(ext,'.slx'))))

                DAStudio.error(...
                'Simulink:taskEditor:selectedFileInvalidModel',...
                FileName)
            end

            filePaths=which('-all',FileName);

            if isempty(filePaths)
                isCancel=obj.resolvePathIssueForAUniqueModel(PathName,FileName);
                if(isCancel),return;end;
            end

            modelNameWithoutExt=...
            obj.getModelNameWithoutExtension(FileName);
            open_system(modelNameWithoutExt);
            ret=modelNameWithoutExt;
        end

    end
end
