classdef RollupStatus<handle








    methods
        function getPropertyStyle(this,propname,propertyStyle)
            if this.dataModelObj.isUnMarked&&...
                ~slreq.app.MainManager.getInstance.viewManager.isVanillaActive
                propertyStyle.ForegroundColor=[1.,0.,0.];
            end
            if~this.dataModelObj.isFilteredIn()
                propertyStyle.Italic=1;
                propertyStyle.ForegroundColor=[0.5,0.5,0.5];

            end
            switch propname
            case 'Index'
                mgr=slreq.app.MainManager.getInstance;
                ctmgr=mgr.changeTracker;
                cView=mgr.getCurrentView;

                propertyStyle.BackgroundColor=[1,1,1,1];




                if(reqmgt('rmiFeature','ChangeTrackingSltest')||(reqmgt('rmiFeature','MLChangeTracking')))&&...
                    slreq.utils.isValidView(cView)&&cView.displayChangeInformation&&...
                    ctmgr.hasLinksWithSourceChangeIssue(this.dataUuid)

                    propertyStyle.Tooltip=getString(message('Slvnv:slreq:ReqHasSomeLinksWithChangeIssue'));

                end
            case 'Summary'
                mgr=slreq.app.MainManager.getInstance;
                ctmgr=mgr.changeTracker;
                cView=mgr.getCurrentView;

                propertyStyle.BackgroundColor=[1,1,1,1];
                if slreq.utils.isValidView(cView)&&cView.displayChangeInformation
                    if ctmgr.hasLinksWithChangeIssue(this.dataUuid)
                        propertyStyle.BackgroundColor=slreq.app.ChangeTracker.BACKGROUND_COLOR_WITH_CHANGE_ISSUE;
                        propertyStyle.Tooltip=getString(message('Slvnv:slreq:ReqHasSomeLinksWithChangeIssue'));
                    end





                end
            case 'Implemented'
                mgr=slreq.app.MainManager.getInstance;
                if mgr.isAnalysisDeferred
                    propertyStyle.Tooltip=getString(message('Slvnv:slreq:AnalysisPendingTooltip'));
                    propertyStyle.BackgroundColor=[0.5,0.5,0.5,0.2];
                else

                    visitorName=slreq.analysis.ImplementationVisitor.getName;
                    status=this.getStatus(visitorName);
                    selfStatus=this.getSelfStatus(visitorName);

                    if selfStatus==slreq.analysis.Status.Excluded
                        if slreq.app.RequirementTypeManager.isa(this.dataModelObj.typeName,slreq.custom.RequirementType.Informational)
                            propertyStyle.Tooltip=getString(message('Slvnv:slreq:NotAvailableNodeInformational'));
                        else
                            propertyStyle.Tooltip=getString(message('Slvnv:slreq:NotAvailableInformational'));
                        end

                    elseif selfStatus==slreq.analysis.Status.Justification
                        propertyStyle.Tooltip=getString(message('Slvnv:slreq:NotAvailableJustification'));
                    else
                        if(reqmgt('rmiFeature','CustomRollup'))

                            if isa(this,"slreq.das.RequirementSet")
                                customAttributes=this.dataModelObj.CustomAttributeNames;
                            elseif isa(this,"slreq.das.Requirement")
                                customAttributes=this.dataModelObj.getReqSet().CustomAttributeNames;
                            end
                            hasImplementationStatus=false;
                            for k=1:length(customAttributes)
                                if strcmp(customAttributes{k},'ImplementationStatus')
                                    hasImplementationStatus=true;
                                end
                            end

                            if(hasImplementationStatus)
                                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                                'Values',[status.implemented,status.almostDone,status.partiallyImplemented,status.justStarted,status.none,status.justified],...
                                'Colors',[[0,0,1,1],[0,1,0,1],[1,1,0,1],[0,1,1,1],[1,1,1,1],[0,0.5020,0.7529,1]]);
                                propertyStyle.Tooltip=getString(message('Slvnv:slreq:ImplementationStatusTooltipCustomRollup',...
                                status.none,status.justStarted,status.partiallyImplemented,status.almostDone,status.implemented,status.justified,status.total));
                            else
                                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                                'Values',[status.implemented,status.justified,status.none],...
                                'Colors',[[0,0,1,1],[0,0.5020,0.7529,1],[1,1,1,1]]);
                                propertyStyle.Tooltip=getString(message('Slvnv:slreq:ImplementationStatusTooltip',...
                                status.implemented,status.justified,status.none,status.total));
                            end
                        else
                            propertyStyle.WidgetInfo=struct('Type','progressbar',...
                            'Values',[status.implemented,status.justified,status.none],...
                            'Colors',[[0,0,1,1],[0,0.5020,0.7529,1],[1,1,1,1]]);
                            propertyStyle.Tooltip=getString(message('Slvnv:slreq:ImplementationStatusTooltip',...
                            status.implemented,status.justified,status.none,status.total));
                        end

                    end
                end
            case 'Verified'

                mgr=slreq.app.MainManager.getInstance;
                if mgr.isAnalysisDeferred
                    propertyStyle.Tooltip=getString(message('Slvnv:slreq:AnalysisPendingTooltip'));
                    propertyStyle.BackgroundColor=[0.5,0.5,0.5,0.2];
                else

                    visitorName=slreq.analysis.VerificationVisitor.getName;
                    status=this.getStatus(visitorName);
                    selfStatus=this.getSelfStatus(visitorName);

                    if selfStatus==slreq.analysis.Status.Excluded
                        if slreq.app.RequirementTypeManager.isa(this.dataModelObj.typeName,slreq.custom.RequirementType.Informational)
                            propertyStyle.Tooltip=getString(message('Slvnv:slreq:NotAvailableNodeInformational'));
                        else
                            propertyStyle.Tooltip=getString(message('Slvnv:slreq:NotAvailableInformational'));
                        end
                    elseif selfStatus==slreq.analysis.Status.Justification
                        propertyStyle.Tooltip=getString(message('Slvnv:slreq:NotAvailableJustification'));
                    else
                        propertyStyle.WidgetInfo=struct('Type','progressbar',...
                        'Values',[status.passed,status.justified,status.failed,status.unexecuted,status.none],...
                        'Colors',[[0.2784,0.6392,0.0980,1]...
                        ,[0,0.5020,0.7529,1]...
                        ,[0.8902,0.2000,0.0039,1]...
                        ,[0.9961,0.8235,0.0706,1]...
                        ,[1,1,1,1]]);
                        propertyStyle.Tooltip=getString(message('Slvnv:slreq:VerificationStatusTooltip',...
                        status.passed,status.justified,status.failed,...
                        status.unexecuted,status.none,status.total));
                    end
                end
            end
        end

        function status=getImplementationStatus(this)



            status=this.dataModelObj.getVerficatoinStatus();%#ok<MCNPN>
        end


        function status=getVerificationStatus(this)



            status=this.dataModelObj.getVerficatoinStatus();%#ok<MCNPN>
        end
    end
end
