function modelAdvisorSLDV()




    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineMAChecksForSldvAdvisor);
    cm.addModelAdvisorTaskFcn(@defineSldvAdvisorTasks);
end



function defineMAChecksForSldvAdvisor
    mdladvRoot=ModelAdvisor.Root;

    SldvFolder=getString(message('Sldv:ModelAdvisor:sl_customization:SimulinkDesignVerifier'));
    designErrorSubFolder=[SldvFolder,'|',getString(message('Sldv:ModelAdvisor:sl_customization:DesignErrorDetection'))];

    mdladvRoot.publish(sldvprivate('sldvadvCompatibilityRegistry'),SldvFolder);
    mdladvRoot.publish(sldvprivate('sldvadvDeadLogicRegistry'),designErrorSubFolder);
    if slavteng('feature','ModelAdvisorRuntimeErrChk')
        mdladvRoot.publish(sldvprivate('sldvadvArrayBoundsRegistry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvDivByZeroRegistry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvIntegerOverflowRegistry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvInfNaNRegistry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvSubnormalRegistry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvMinMaxRegistry'),...
        designErrorSubFolder);
        if slavteng('feature','DsmHazards')>0
            mdladvRoot.publish(sldvprivate('sldvadvDSMAccessViolationsRegistry'),...
            designErrorSubFolder);
        end
        if slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2
            mdladvRoot.publish(sldvprivate('sldvadvBlockInputRangeViolationsRegistry'),...
            designErrorSubFolder);
        end

        mdladvRoot.publish(sldvprivate('sldvadvHisl0002Registry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvHisl0003Registry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvHisl0004Registry'),...
        designErrorSubFolder);
        mdladvRoot.publish(sldvprivate('sldvadvHisl0028Registry'),...
        designErrorSubFolder);
    end
end


function defineSldvAdvisorTasks()

    mdladvRoot=ModelAdvisor.Root;


    rec1=ModelAdvisor.FactoryGroup('com.mathworks.sldv.compatgroup');
    rec1.DisplayName=getString(message('Sldv:ModelAdvisor:sl_customization:CompatibilityDisplayName'));
    rec1.Description=getString(message('Sldv:ModelAdvisor:sl_customization:CompatibilityDescription'));

    rec1.addCheck('mathworks.sldv.compatibility');
    mdladvRoot.publish(rec1);


    rec2=ModelAdvisor.FactoryGroup('com.mathworks.sldv.DesignErrorDetectionGroup');
    rec2.DisplayName=getString(message('Sldv:ModelAdvisor:sl_customization:DesignErrorDetectionDisplayName'));
    rec2.Description=getString(message('Sldv:ModelAdvisor:sl_customization:DesignErrorDetectionDescription'));

    rec2.addCheck('mathworks.sldv.deadlogic');
    if slavteng('feature','ModelAdvisorRuntimeErrChk')
        rec2.addCheck('mathworks.sldv.arraybounds');
        rec2.addCheck('mathworks.sldv.divbyzero');
        rec2.addCheck('mathworks.sldv.integeroverflow');
        rec2.addCheck('mathworks.sldv.infnan');
        rec2.addCheck('mathworks.sldv.subnormal');
        rec2.addCheck('mathworks.sldv.minmax');
        if slavteng('feature','DsmHazards')>0
            rec2.addCheck('mathworks.sldv.dsmaccessviolations');
        end
        if slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2
            rec2.addCheck('mathworks.sldv.blockinputrangeviolations');
        end

        rec2.addCheck('mathworks.sldv.hismviolationshisl_0002');
        rec2.addCheck('mathworks.sldv.hismviolationshisl_0003');
        rec2.addCheck('mathworks.sldv.hismviolationshisl_0004');
        rec2.addCheck('mathworks.sldv.hismviolationshisl_0028');
    end

    mdladvRoot.publish(rec2);

end
