classdef Popup<handle
    properties
        violations;
        uiData=containers.Map('KeyType','char','ValueType','any');
        detailsMode=false;
        currentRow=0;
        backgroundColor=[255,255,223];
        system='';
        segH=0;
        position;

        positionFlag=false;
        groupLook=true;
        backgroundControl=false;
        stackedLook=false;
    end

    methods(Access=public)
        function this=Popup(system,segH,position)
            this.system=system;
            this.segH=segH;
            this.position=position([1,2]);
            this.setEditTimeViolations();
        end

        function setEditTimeViolations(obj)
            obj.setViolations(Simulink.EditTimeMismatchUtils.getAttributeMismatchesForSeg(obj.segH));
        end

        function setViolations(obj,editTimeViolations)
            if obj.typeCheck(editTimeViolations)
                obj.violations=editTimeViolations;
            else
                error('Wrong Type');
            end
        end

        function flag=typeCheck(~,editTimeViolations)
            flag=false;
            if(isstruct(editTimeViolations))
                flag=isequal(fieldnames(editTimeViolations),{'SrcBlockPath';'SrcPortIdx';'DstMismatches'});
            end
        end

        function setDetailsMode(obj,flag)
            obj.detailsMode=flag;
        end

        function selectRow(obj,h,row)
            obj.currentRow=row;
            h.refresh();
        end

        function showDetails(obj,row)
            obj.detailsMode=~obj.detailsMode;
            obj.currentRow=str2double(row);
            src=Advisor.edittime.dialogs.Popup(obj.system,...
            obj.sid);
            src.setDetailsMode(obj.detailsMode);
            src.setCurrentRow(obj.currentRow);
            src.setViolations(obj.violations)
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
        end

        function openBlockDlg(~,blockPath,portIdx,selAttr,isInputPort)
            blockObj=get_param(blockPath,'Object');
            if isa(blockObj,'Simulink.SubSystem')

                subObj=blockObj;
                if~isempty(subObj.TemplateBlock)
                    subObj=subObj.getChildren;
                end
                ch=subObj.getChildren;
                if(isInputPort)
                    filt=arrayfun(@(x)isa(x,'Simulink.Inport')&&str2double(x.Port)==portIdx,ch);
                else
                    filt=arrayfun(@(x)isa(x,'Simulink.Outport')&&str2double(x.Port)==portIdx,ch);
                end
                ch=ch(filt);
                blockObj=ch(1);
            end
            blockObj.Selected='on';
            blockObj.view;

            if~isempty(selAttr)
                t=timer;
                t.startDelay=0.5;
                t.TimerFcn=@(~,~)hiliteAttribute(selAttr);
                start(t);
            end

        end

        function show(this,dlg)
            width=min(416,dlg.position(3));
            height=min(250,dlg.position(4));
            if~this.positionFlag
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'SingleSelectionFlyout',this.position);
                this.position=dlg.position;
            else

                dlg.position=this.position;
            end
            dlg.position(3)=max(416,dlg.position(3));
            dlg.position(4)=max(250,dlg.position(4));
            dlg.show();

        end

    end

    methods(Static)
        function create()


        end

        function opendlg(src)
            bdHandle=get_param(src.system,'handle');
            dlg=Simulink.EditTimeMismatchUtils.retrieveDlgHandle(bdHandle);

            if~isempty(dlg)&&isa(dlg,'DAStudio.Dialog')
                src.position=dlg.position;
                src.positionFlag=true;
                delete(dlg);
            end

            dlg=DAStudio.Dialog(src);
            src.show(dlg);

            Simulink.EditTimeMismatchUtils.cacheDlgHandle(bdHandle,dlg);
        end
    end
end

function hiliteAttribute(attr)

    st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if~isempty(st)
        st=st(1);
        piCmp=st.getComponent('GLUE2:PropertyInspector','Property Inspector');
        st.showComponent(piCmp);
        inspector=piCmp.getInspector();
        dlg=inspector.getSlimDialog('Simulink:Dialog:Parameters');
        if isa(dlg,'DAStudio.Dialog')
            switch attr
            case DAStudio.message('Simulink:tools:EditTimeMismatchDataTypeAttr')
                dlg.setFocus('Data type:');
            case DAStudio.message('Simulink:tools:EditTimeMismatchDimensionsAttr')
                dlg.setFocus('Port dimensions (-1 for inherited):');
            case DAStudio.message('Simulink:tools:EditTimeMismatchUnitAttr')
                dlg.setFocus('Unit (e.g., m, m/s^2, N*m):');
            case DAStudio.message('Simulink:tools:EditTimeMismatchComplexityAttr')
                dlg.setFocus('Signal type:');
            end
        end
    end


end
