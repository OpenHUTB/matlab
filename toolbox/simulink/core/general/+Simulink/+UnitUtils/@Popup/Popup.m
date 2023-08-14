classdef Popup<handle
    properties
        violations;
        uiData=containers.Map('KeyType','char','ValueType','any');
        detailsMode=false;
        currentRow=0;
        backgroundColor=[255,255,223];
        system='';
        sid='';
        portH=0;


        groupLook=true;
        backgroundControl=false;
        stackedLook=false;
    end

    methods(Access=public)
        function this=Popup(system,sid,portH)
            this.sid=sid;
            this.system=system;
            this.portH=portH;

        end

        function setEditTimeViolations(obj)
        end

        function setViolations(obj,editTimeViolations)
            if obj.typeCheck(editTimeViolations)
                obj.violations=editTimeViolations;
            else
                error('Wrong Type');
            end
        end

        function flag=typeCheck(obj,editTimeViolations)
            flag=false;
            if isscalar(editTimeViolations)
                if isa(editTimeViolations,'Simulink.UnitDiagnostic')
                    flag=true;
                end
                return;
            else
                for i=1:length(editTimeViolations)
                    if~isa(editTimeViolations(i),'Simulink.UnitDiagnostic')
                        return;
                    end
                    flag=true;
                    return;
                end
            end
        end

        function setDetailsMode(obj,flag)
            obj.detailsMode=flag;
        end

        function setCurrentRow(obj,row)
            obj.currentRow=row;
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

        function nextIssue(obj)
            obj.currentRow=obj.currentRow+1;
        end

        function previousIssue(obj)
            obj.currentRow=obj.currentRow-1;
        end

        function show(this,dlg)


            dlg.position=Simulink.harness.internal.calcDialogGeometry(dlg.position(3),dlg.position(4),'Port',this.portH);

            dlg.show();
        end



















    end

    methods(Static)
        function create()


        end

        function opendlg(src)
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
        end
    end
end

