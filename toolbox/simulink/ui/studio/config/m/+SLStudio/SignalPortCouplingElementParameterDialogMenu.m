classdef SignalPortCouplingElementParameterDialogMenu %#ok<*MCDIR>






    methods(Static)

        function schema=ShowDialog(cbinfo)

            schema=sl_action_schema;
            schema.tag='Simulink:ShowCouplingElementParameterDialog';
            schema.label=DAStudio.message('Simulink:studio:ShowCouplingElementParameterDialog');
            schema.state='Enabled';
            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            if SLStudio.Utils.objectIsValidPort(target)&&...
                (strcmpi(target.type,'In Port')||...
                strcmpi(target.type,'Out Port'))
                schema.userdata.portH=target.handle;
            elseif SLStudio.Utils.objectIsValidBlock(target)
                assert(Simulink.cosimservice.internal.IsCoSimComponent(target.handle));

                schema.userdata.blockH=target.handle;
            end
            schema.callback=@SLStudio.SignalPortCouplingElementParameterDialogMenu.callBackShowDialog;
        end
    end



    methods(Static,Hidden)

        function callBackShowDialog(cbinfo)
            if isfield(cbinfo.userdata,"portH")
                portH=cbinfo.userdata.portH;
                obj=get_param(portH,'Object');
                blk=obj.Parent;
            else
                blockH=cbinfo.userdata.blockH;
                obj=[];
                blk=getfullname(blockH);
            end
            dlgSrc=Simulink.cosimservice.CoSimSignalCompensationDialog(cbinfo,blk,obj);
            dlg=DAStudio.Dialog(dlgSrc);
            dlgSrc.show(dlg);
        end
    end
end


