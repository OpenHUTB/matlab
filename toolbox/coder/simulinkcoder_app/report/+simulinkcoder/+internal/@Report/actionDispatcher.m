function actionDispatcher(obj,msg)




    model=msg.model;
    evt=simulinkcoder.internal.CodeViewEventData(msg);

    if isempty(model)

        obj.notify('CodeViewEvent',evt);
    else
        fcn=str2func(['loc_',msg.action]);
        fcn(obj,evt);
    end

    function loc_start(obj,evt)%#ok<*DEFNU>
        msg=evt.data;
        if isfield(msg,'cid')

            obj.notify('CodeViewEvent',evt);
        else

            model=msg.model;
            try
                data=obj.getCodeData(model);
            catch ME
                data.error=ME.message;
            end
            obj.publish(model,'init',data,msg.uid);
        end

        function loc_ready(obj,evt)
            obj.notify('CodeReady',evt);

            function loc_CodeReady(obj,evt)
                obj.notify('CodeViewEvent',evt);

                function loc_line2mdl(obj,evt)
                    obj.onClick(evt.data);
                    obj.notify('Click',evt);

                    function loc_hdl_line2mdl(obj,evt)
                        loc_line2mdl(obj,evt)

                        function loc_token2mdl(obj,evt)
                            obj.onClick(evt.data);
                            obj.notify('Click',evt);

                            function loc_blk2mdl(obj,evt)
                                obj.onClick(evt.data);
                                obj.notify('Click',evt);

                                function loc_code2mapping(obj,evt)
                                    obj.onClick(evt.data);
                                    obj.notify('Click',evt);

                                    function loc_hover(obj,evt)
                                        obj.onMouseEnter(evt.data);
                                        obj.notify('MouseEnter',evt);

                                        function loc_clear(obj,evt)
                                            obj.onMouseLeave(evt.data);
                                            obj.notify('MouseLeave',evt);

                                            function loc_code2req(obj,evt)
                                                obj.onClick(evt.data);

                                                function loc_LaunchStandaloneReport(~,evt)
                                                    coder.internal.toolstrip.callback.openReport(evt.data.model);

                                                    function loc_Annotation(obj,evt)
                                                        obj.notify('CodeViewEvent',evt);

                                                        function loc_FileChange(obj,evt)
                                                            obj.notify('CodeViewEvent',evt);

                                                            function loc_configset(~,evt)
                                                                msg=evt.data;
                                                                cs=getActiveConfigSet(msg.model);
                                                                configset.highlightParameter(cs,msg.param);
                                                                dlg=cs.getDialogHandle;
                                                                if isa(dlg,'DAStudio.Dialog')
                                                                    dlg.show;
                                                                end

                                                                function loc_openFile(~,evt)
                                                                    edit(evt.data.fileName);


                                                                    function loc_reportV2CallLegacyMFunc(~,evt)
                                                                        try
                                                                            eval(evt.data.mExpression);
                                                                        catch ME
                                                                            warndlg(ME.message);
                                                                        end


