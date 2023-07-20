




classdef ChooseMapping<handle
    properties(SetObservable=true)
        ModelName;
        DialogH;
        CloseListener;
        MappingType;
        cbinfo;
    end

    methods(Access=public)
        function obj=ChooseMapping(cbinfoArg)
            obj.cbinfo=cbinfoArg;
            obj.ModelName=get_param(obj.cbinfo.model.handle,'Name');

            obj.CloseListener=Simulink.listener(obj.cbinfo.model.handle,'CloseEvent',...
            @CloseCB);
            obj.MappingType='';
        end

        function varType=getPropDataType(~,~)
            varType='ustring';
        end

        function mappingType=getMappingType(obj)
            mappingType=obj.MappingType;
        end

        function[isValid,msg]=hApplyCB(obj,dlg)
            isValid=true;
            msg='';
            cmValue=dlg.getWidgetValue('MappingRadio');
            switch cmValue
            case 0
                obj.MappingType='CoderDictionary';
            case 1
                obj.MappingType='AutosarTarget';
            case 2
                obj.MappingType='';
            end
            if strcmp(obj.MappingType,'AutosarTarget')
                pb=Simulink.internal.ScopedProgressBar(...
                DAStudio.message('RTW:autosar:createDefaultProgressBar'));
                Simulink.CodeMapping.addCoderGroups(obj.ModelName,'init');
                created=Simulink.CodeMapping.create(obj.ModelName,'default',obj.MappingType);
                pb.delete();
            elseif strcmp(obj.MappingType,'CoderDictionary')
                Simulink.CodeMapping.doMigrationFromGUI(obj.ModelName,false);
            end
            if created
                st=obj.cbinfo.studio;
                ss=GLUE2.SpreadSheetComponent(st,'CodeProperties');
                ss.DestroyOnHide=false;
                obj=DataView(obj.cbinfo.model,ss);
                st.registerComponent(ss);
                st.moveComponentToDock(ss,DAStudio.message('Simulink:studio:CodeViewSS'),'Bottom','Tabbed');
                ss.setTitleViewSource(obj);
                ss.setCurrentTab(0);
            end
        end

        function setDialog(obj,dlg)
            obj.DialogH=dlg;
        end

        function refresh(obj)
            obj.DialogH.refresh;
        end


        function dlg=getDialogSchema(obj)
            isARCompliant=strcmp(get_param(obj.ModelName,'AutosarCompliant'),'on');

            mmgr=get_param(obj.ModelName,'MappingManager');
            cdm=mmgr.getActiveMappingFor('CoderDictionary');
            am=mmgr.getActiveMappingFor('AutosarTarget');
            rowOffset=1;
            columnOffset=2;
            columnCount=15;

            if isempty(cdm)&&isempty(am)
                MappingRadio.Name='This model is not configured with Software Component. You can auto create default mapping for a Software Component.';
                MappingRadio.Type='radiobutton';
                MappingRadio.Tag='MappingRadio';
                MappingRadio.OrientHorizontal=false;

                MappingRadio.Entries={'C code','AUTOSAR C code'};
                if isARCompliant
                    MappingRadio.Value=1;
                else
                    MappingRadio.Value=0;
                end
                MappingRadio.RowSpan=[rowOffset,rowOffset];
                MappingRadio.ColSpan=[columnOffset+1,columnCount];

                rowOffset=rowOffset+1;
                spacer.Type='text';
                spacer.Name='';
                spacer.Tag='spacer';
                spacer.RowSpan=[rowOffset,rowOffset];
                spacer.ColSpan=[1,columnCount];





                dlg.DialogTitle=sprintf('Create Software Component for a model %s',obj.ModelName);
                dlg.LayoutGrid=[rowOffset,columnCount];

                dlg.Items={MappingRadio,spacer,};
                dlg.Sticky=false;
                dlg.StandaloneButtonSet={'Cancel','OK'};
                dlg.PreApplyCallback='hApplyCB';
                dlg.PreApplyArgs={obj,'%dialog'};
                dlg.Source=obj;
                dlg.DialogTag='ChooseMapping';


            end
        end
    end
end


function CloseCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.find('-isa','DAStudio.Dialog','dialogTag','ChooseMapping');
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(dlgSrc.ModelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end



