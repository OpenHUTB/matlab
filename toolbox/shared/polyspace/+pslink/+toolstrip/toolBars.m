function schema=toolBars(funcname,cbinfo,eventData)
    fnc=str2func(funcname);
    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end



    function polyspaceAdvancedConfigCallback(~)
        pslinkfun('advancedoptions');

        function polyspaceRemoveHighlightCallback(callbackInfo)
            slprivate('remove_hilite',callbackInfo.model.Handle);


            function findBugsActionCB(callbackInfo,eventData)
                if callbackInfo.EventData
                    pssharedprivate('initConfigComp',callbackInfo.model.Handle);
                    opts=pslinkoptions(callbackInfo.model.Handle);
                    opts.VerificationMode='BugFinder';

                    customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                    customContext.setVerificationMode(opts.VerificationMode);
                end

                function findBugsActionRF(callbackInfo,action)


                    opts=pslinkoptions(callbackInfo.model.Handle);
                    if strcmpi(opts.VerificationMode,'BugFinder')
                        action.selected=true;
                    end

                    function proveCodeActionCB(callbackInfo,eventData)
                        if callbackInfo.EventData
                            pssharedprivate('initConfigComp',callbackInfo.model.Handle);
                            opts=pslinkoptions(callbackInfo.model.Handle);
                            opts.VerificationMode='CodeProver';

                            customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                            customContext.setVerificationMode(opts.VerificationMode);
                        end

                        function proveCodeActionRF(callbackInfo,action)


                            opts=pslinkoptions(callbackInfo.model.Handle);
                            if strcmpi(opts.VerificationMode,'CodeProver')
                                action.selected=true;
                            end


                            function psUseTargetLinkPolyspaceActionCB(callbackInfo,eventData)

                                customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                customContext.toggleTargetLink();


                                function schema=selectComponentActionRF(callbackInfo)

                                    schema=sl_action_schema;

                                    customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                    if strcmpi(customContext.CodeAs,'TopModel')
                                        schema.icon='selectModelComponent';
                                        schema.label=message('polyspace:toolstrip:CodeAsTopModelPolyspaceActionText').getString();
                                    elseif strcmpi(customContext.CodeAs,'CustomCode')
                                        schema.icon='selectModelComponent';
                                        schema.label=message('polyspace:toolstrip:CustomCodePolyspaceActionText').getString();
                                    else
                                        schema.icon='selectModelComponent';
                                        schema.label=message('polyspace:toolstrip:CodeAsRefModelPolyspaceActionText').getString();
                                    end

                                    function codeAsTopModelActionCB(callbackInfo,eventData)
                                        if callbackInfo.EventData

                                            customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                            customContext.setCodeAsMode('TopModel');
                                        end

                                        function codeAsRefModelActionCB(callbackInfo,eventData)
                                            if callbackInfo.EventData

                                                customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                customContext.setCodeAsMode('RefModel');
                                            end

                                            function customCodeActionCB(callbackInfo,eventData)
                                                if callbackInfo.EventData
                                                    customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                    customContext.setCodeAsMode('CustomCode');
                                                end


                                                function PolyspaceViewerCB(callbackInfo)

                                                    customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                    codeAsMode=customContext.CodeAs;
                                                    if strcmpi(codeAsMode,'RefModel')
                                                        asRefModel=true;
                                                    else
                                                        asRefModel=false;
                                                    end

                                                    selection=callbackInfo.getSelection;
                                                    if pslink.util.UserInterfaceHelper.isValidSubsystem(selection)||pslink.util.UserInterfaceHelper.isSFunctionBlock(selection)

                                                        sysToAnalyse=selection.getFullName();
                                                    else

                                                        sysToAnalyse=callbackInfo.model.getFullName();
                                                    end
                                                    pslinkprivate('openPolyspaceViewer',sysToAnalyse,asRefModel);


                                                    function accessAndMetricsCB(~)
                                                        pslinkprivate('openPolyspaceAccess');

                                                        function schema=accessAndMetricsRF(~)
                                                            schema=sl_action_schema;
                                                            schema.callback=@accessAndMetricsCB;

                                                            schema.icon='onlineResultsPolyspace';
                                                            schema.label=message('polyspace:toolstrip:ViewAccessPolyspaceActionText').getString();
                                                            schema.tooltip=message('polyspace:toolstrip:ViewAccessPolyspaceActionDescription').getString();


                                                            function selectResultsCB(~)
                                                                pslinkprivate('selectResults');


                                                                function runVerificationActionCB(callbackInfo)

                                                                    customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                                    codeAsMode=customContext.CodeAs;
                                                                    isTargetLink=customContext.IsTargetLink;


                                                                    selection=callbackInfo.studio.App.getPinnedSystem('systemSelectionPolyspaceAction');
                                                                    if isempty(selection)
                                                                        selection=callbackInfo.getSelection();
                                                                    end
                                                                    try

                                                                        if numel(selection)==1
                                                                            sysToAnalyse=selection.Handle;
                                                                            if isa(selection,'Simulink.SFunction')

                                                                                allInstances=true;

                                                                                pssharedprivate('initConfigComp',sysToAnalyse);

                                                                                meObj=pssharedprivate('checkSystemValidity',sysToAnalyse,true);
                                                                                if~isempty(meObj)
                                                                                    throw(meObj);
                                                                                end
                                                                                pslinkprivate('launchSFunctionVerification',sysToAnalyse,[],allInstances);
                                                                            elseif isa(selection,'Simulink.SubSystem')
                                                                                if pssharedprivate('isTlTarget',selection.Handle)&&isTargetLink

                                                                                    pssharedprivate('initConfigComp',sysToAnalyse);
                                                                                    pslinkprivate('launchCodeVerification',sysToAnalyse,[],pslink.verifier.tl.Coder.CODER_ID,false);
                                                                                elseif pssharedprivate('isErtTarget',selection.Handle)||pslinkprivate('pslinkattic','getBinMode','allowGrtTarget')

                                                                                    pssharedprivate('initConfigComp',sysToAnalyse);

                                                                                    pslink.toolstrip.generateCode(sysToAnalyse)

                                                                                    pslinkprivate('launchCodeVerification',sysToAnalyse,[],pslink.verifier.ec.Coder.CODER_ID,false);
                                                                                end
                                                                            elseif isa(selection,'Simulink.BlockDiagram')
                                                                                pssharedprivate('initConfigComp',sysToAnalyse);
                                                                                if strcmpi(codeAsMode,'TopModel')

                                                                                    pslink.toolstrip.generateCode(sysToAnalyse)

                                                                                    pslinkprivate('launchCodeVerification',sysToAnalyse,[],pslink.verifier.ec.Coder.CODER_ID,false);
                                                                                elseif strcmpi(codeAsMode,'CustomCode')

                                                                                    meObj=pssharedprivate('checkSystemValidity',sysToAnalyse,true,pslink.verifier.slcc.Coder.CODER_ID);
                                                                                    if~isempty(meObj)
                                                                                        throw(meObj);
                                                                                    end
                                                                                    pslinkprivate('launchSlccVerification',sysToAnalyse,[]);
                                                                                else

                                                                                    pslinkprivate('launchCodeVerification',sysToAnalyse,[],pslink.verifier.ec.Coder.CODER_ID,true);
                                                                                end
                                                                            else

                                                                            end
                                                                        elseif numel(selection)==0
                                                                            sysToAnalyse=callbackInfo.model.Handle;
                                                                            pssharedprivate('initConfigComp',sysToAnalyse);
                                                                            if strcmpi(codeAsMode,'TopModel')

                                                                                pslink.toolstrip.generateCode(sysToAnalyse)

                                                                                pslinkprivate('launchCodeVerification',sysToAnalyse,[],pslink.verifier.ec.Coder.CODER_ID,false);
                                                                            elseif strcmpi(codeAsMode,'CustomCode')
                                                                                pslinkprivate('launchSlccVerification',sysToAnalyse,[]);
                                                                            else

                                                                                pslinkprivate('launchCodeVerification',sysToAnalyse,[],pslink.verifier.ec.Coder.CODER_ID,true);
                                                                            end
                                                                        else

                                                                        end
                                                                    catch Me



                                                                        pslinkPrefix='pslink:';
                                                                        polyspacePrefix='polyspace:';
                                                                        if strncmp(Me.identifier,pslinkPrefix,numel(pslinkPrefix))||...
                                                                            strncmp(Me.identifier,polyspacePrefix,numel(polyspacePrefix))
                                                                            modelName=get_param(callbackInfo.model.Handle,'Name');

                                                                            stage=sldiagviewer.createStage('Polyspace','ModelName',modelName);%#ok<NASGU>
                                                                            sldiagviewer.reportError(Me);
                                                                        else
                                                                            rethrow(Me);
                                                                        end
                                                                    end


                                                                    function schema=runVerificationActionRF(callbackInfo)
                                                                        schema=sl_action_schema;
                                                                        schema.callback=@runVerificationActionCB;
                                                                        schema.icon='run';


                                                                        selection=callbackInfo.studio.App.getPinnedSystem('systemSelectionPolyspaceAction');
                                                                        if isempty(selection)
                                                                            selection=callbackInfo.getSelection();
                                                                        end
                                                                        if numel(selection)>1

                                                                            schema.state='Disabled';
                                                                        elseif numel(selection)==1
                                                                            if isa(selection,'Simulink.BlockDiagram')||...
                                                                                isa(selection,'Simulink.SFunction')
                                                                                schema.state='Enabled';
                                                                            elseif isa(selection,'Simulink.SubSystem')

                                                                                customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                                                if customContext.CodeAsCustomCode
                                                                                    schema.state='Disabled';
                                                                                else
                                                                                    schema.state='Enabled';
                                                                                end
                                                                            else
                                                                                schema.state='Disabled';
                                                                            end
                                                                        else

                                                                            schema.state='Enabled';
                                                                        end


                                                                        opts=pslinkoptions(callbackInfo.model.Handle);
                                                                        if strcmpi(opts.VerificationMode,'CodeProver')
                                                                            schema.tooltip=message('polyspace:toolstrip:RunAnalysisPolyspaceCodeProverActionDescription').getString();
                                                                        else
                                                                            schema.tooltip=message('polyspace:toolstrip:RunAnalysisPolyspaceBugFinderActionDescription').getString();
                                                                        end


                                                                        function EcoderAnnotationEditCB(callbackInfo)

                                                                            selection=callbackInfo.getSelection;
                                                                            if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)...
                                                                                &&~pslink.BlockAnnotation.isDialogOpened(selection.getFullName)
                                                                                o=pslink.BlockAnnotation(selection);
                                                                                DAStudio.Dialog(o);
                                                                            end

                                                                            function schema=EcoderAnnotationEditRF(callbackInfo)
                                                                                schema=sl_action_schema;
                                                                                schema.callback=@EcoderAnnotationEditCB;
                                                                                schema.icon='addAnnotationPolyspace';
                                                                                schema.label=message('polyspace:toolstrip:AddPolyspaceAnnotationActionText').getString();
                                                                                schema.tooltip=message('polyspace:toolstrip:AddPolyspaceAnnotationActionDescription').getString();

                                                                                selection=callbackInfo.getSelection();
                                                                                if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)
                                                                                    schema.state='Enabled';
                                                                                else
                                                                                    schema.state='Disabled';
                                                                                end



                                                                                function EcoderAnnotationCopyCB(callbackInfo)
                                                                                    selection=callbackInfo.getSelection;
                                                                                    if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)
                                                                                        annotation=rtwprivate('getPolySpaceBlockComment',selection.Handle());

                                                                                        if ispref('PolySpace','annotation')
                                                                                            setpref('PolySpace','annotation',annotation{1});
                                                                                            setpref('PolySpace','annotationend',annotation{2});
                                                                                        else
                                                                                            addpref('PolySpace','annotation',annotation{1});
                                                                                            setpref('PolySpace','annotationend',annotation{2});
                                                                                        end

                                                                                        customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                                                        customContext.toggleRefreshAnnotations();
                                                                                    end

                                                                                    function schema=EcoderAnnotationCopyRF(callbackInfo)
                                                                                        schema=sl_action_schema;
                                                                                        schema.callback=@EcoderAnnotationCopyCB;
                                                                                        schema.icon='copy';
                                                                                        selection=callbackInfo.getSelection();
                                                                                        if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)
                                                                                            annotation=rtwprivate('getPolySpaceBlockComment',selection.Handle());
                                                                                            if~isempty(annotation{1})
                                                                                                schema.state='Enabled';
                                                                                            else
                                                                                                schema.state='Disabled';
                                                                                            end
                                                                                        else
                                                                                            schema.state='Disabled';
                                                                                        end


                                                                                        function EcoderAnnotationPasteCB(callbackInfo)
                                                                                            selection=callbackInfo.getSelection;
                                                                                            if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)&&ispref('PolySpace','annotation')&&~isempty(getpref('PolySpace','annotation'))

                                                                                                if strcmpi(get_param(callbackInfo.model.getFullName(),'InsertPolySpaceComments'),'off')
                                                                                                    set_param(callbackInfo.model.getFullName(),'InsertPolySpaceComments','on');
                                                                                                end

                                                                                                annoAction='-replace';
                                                                                                annoBegin=getpref('PolySpace','annotation');
                                                                                                annoEnd=getpref('PolySpace','annotationend');
                                                                                                annotation.dispInModel='Polyspace annotation';

                                                                                                rtwprivate('setPolySpaceBlockComment',selection.Handle(),annoAction,annoBegin,annoEnd);
                                                                                                set_param(selection.Handle(),'AttributesFormatString',annotation.dispInModel);

                                                                                                customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                                                                customContext.toggleRefreshAnnotations();
                                                                                            end

                                                                                            function schema=EcoderAnnotationPasteRF(callbackInfo)
                                                                                                schema=sl_action_schema;
                                                                                                schema.callback=@EcoderAnnotationPasteCB;
                                                                                                schema.icon='paste';
                                                                                                if ispref('PolySpace','annotation')&&~isempty(getpref('PolySpace','annotation'))...
                                                                                                    &&pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,callbackInfo.getSelection)
                                                                                                    schema.state='Enabled';
                                                                                                else
                                                                                                    schema.state='Disabled';
                                                                                                end


                                                                                                function EcoderAnnotationDelCB(callbackInfo)
                                                                                                    selection=callbackInfo.getSelection;
                                                                                                    if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)
                                                                                                        rtwprivate('setPolySpaceBlockComment',selection.Handle(),'-replace','','');
                                                                                                        set_param(selection.Handle(),...
                                                                                                        'AttributesFormatString','',...
                                                                                                        'HiliteAncestors','off');

                                                                                                        customContext=pslink.toolstrip.PslinkContextManager.getContext(callbackInfo.model.Handle);
                                                                                                        customContext.toggleRefreshAnnotations();
                                                                                                    end

                                                                                                    function schema=EcoderAnnotationDelRF(callbackInfo)
                                                                                                        schema=sl_action_schema;
                                                                                                        schema.callback=@EcoderAnnotationDelCB;
                                                                                                        schema.icon='delete';
                                                                                                        if slreq.utils.selectionHasMarkup(callbackInfo)
                                                                                                            schema.state='Disabled';
                                                                                                            return;
                                                                                                        end
                                                                                                        selection=callbackInfo.getSelection();
                                                                                                        if pslink.util.UserInterfaceHelper.isValidBlockForAnnotation(callbackInfo,selection)
                                                                                                            annotation=rtwprivate('getPolySpaceBlockComment',selection.Handle());
                                                                                                            if~isempty(annotation{1})
                                                                                                                schema.state='Enabled';
                                                                                                            else
                                                                                                                schema.state='Disabled';
                                                                                                            end
                                                                                                        else
                                                                                                            schema.state='Disabled';
                                                                                                        end



