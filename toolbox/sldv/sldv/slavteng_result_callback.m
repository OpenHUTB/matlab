


function slavteng_result_callback(tcompUdi,goalUdiList)




    warnBTModeName='backtrace';
    warnBTModeState=warning('query',warnBTModeName);
    warning('off',warnBTModeName);


    restoreWarnings=onCleanup(@()warning(warnBTModeState.state,warnBTModeName));


    if~sldvshareprivate('util_is_analyzing_for_fixpt_tool')
        final_str='';
        for idx=1:numel(goalUdiList)
            goalUdi=goalUdiList(idx);
            str=updateGoal(tcompUdi,goalUdi);

            if isempty(tcompUdi.progressUI)
                fprintf(1,'.');
                colPos=tcompUdi.colPos+1;
                if colPos>=80
                    fprintf(1,'\n');
                    colPos=0;
                end
                tcompUdi.colPos=colPos;
            else
                final_str=[final_str,str];%#ok<AGROW>
            end
        end


        if~isempty(tcompUdi.progressUI)
            tcompUdi.progressUI.update();
            tcompUdi.progressUI.appendToLog(final_str);
        end
    end
end

function str=updateGoal(tcompUdi,goalUdi)
    str='';

    assert(~goalUdi.isInternal(),'Not expecting an internal goal');





    if sldvprivate('sldv_datamodel_isempty',goalUdi,'Goal')||strcmp(goalUdi.type,'AVT_GOAL_PATH_OBJECTIVE')
        return;
    end


    if strcmp(goalUdi.type,'AVT_GOAL_ASSERT')||strcmp(goalUdi.type,'AVT_GOAL_CUSPROOF')||...
        strcmp(goalUdi.type,'AVT_GOAL_OVERFLOW')||strcmp(goalUdi.type,'AVT_GOAL_FLOAT_INF')||...
        strcmp(goalUdi.type,'AVT_GOAL_FLOAT_NAN')||strcmp(goalUdi.type,'AVT_GOAL_FLOAT_SUBNORMAL')
        mdlObj=goalUdi.up;
    else
        covObj=goalUdi.up;
        if sldvprivate('sldv_datamodel_isempty',covObj)||sldvprivate('sldv_datamodel_isa',covObj,'ModelObj')
            mdlObj=covObj;
        else
            mdlObj=covObj.up;
        end
    end


    if sldvprivate('sldv_datamodel_isempty',mdlObj,'ModelObj')
        pathStr='';
    else
        pathStr=mdlObj.label;
    end




    isXIL=SlCov.CovMode.isXIL(tcompUdi.simMode)&&goalUdi.isCodeGoal();
    if isXIL&&strcmpi(pathStr,'sldvlib')
        pathStr=sldv.code.xil.ReportDataUtils.SHARED_UTILITY_LABEL;
    end

    status=goalUdi.status;
    fstr='';
    settings=tcompUdi.activeSettings;

    hasDeadLogic=strcmp(settings.Mode,'DesignErrorDetection')&&...
    strcmp(settings.DetectDeadLogic,'on');

    isDeadLogicGoal=hasDeadLogic&&Sldv.utils.isDeadLogicGoal(goalUdi);

    if~any(strcmp(status,{'GOAL_ERROR','GOAL_INDETERMINATE'}))


        if tcompUdi.analysisInfo.erroredObjectivesInfo.isKey(goalUdi.getGoalMapId)
            tcompUdi.analysisInfo.erroredObjectivesInfo.remove(goalUdi.getGoalMapId);
        end
    end

    switch(status)
    case 'GOAL_ERROR'
        msgStructure=goal_push_message(goalUdi,getString(message('Sldv:SlavtengResCallback:ProducedErrors')));
        tcompUdi.analysisInfo.erroredObjectivesInfo(goalUdi.getGoalMapId)=msgStructure;

    case 'GOAL_UNSATISFIABLE'
        if strcmp(goalUdi.type,'AVT_GOAL_REQTABLE')



            goalUdi.status='GOAL_VALID';
            fstr=updateGoal(tcompUdi,goalUdi);
        elseif slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            deadlogic_status=getString(message('Sldv:SlavtengResCallback:DEADLOGIC'));
            fstr=['<font color="red"><b>',deadlogic_status,'</b></font>'];
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            deadlogic_status=getString(message('Sldv:SlavtengResCallback:DEADLOGIC'));
            fstr=['<font color="red"><b>',deadlogic_status,'</b></font>'];
        elseif slfeature('SldvDeprecateDisplayUnsatisfiableObjectives')||...
            strcmp(settings.DisplayUnsatisfiableObjectives,'on')
            if slavteng('feature','ChangeUnsatisfiableToDeadLogic')
                unsatisfiable_status=getString(message('Sldv:SlavtengResCallback:DEADLOGIC'));
            else
                unsatisfiable_status=getString(message('Sldv:SlavtengResCallback:UNSATISFIABLE'));
            end
            if~slfeature('SldvDeprecateDisplayUnsatisfiableObjectives')
                goal_push_message(goalUdi,getString(message('Sldv:SlavtengResCallback:WasProvenUnsatisfiable')));
                tcompUdi.hasUnsatisfiableObjs=true;
            end

            fstr=['<font color="red"><b>',unsatisfiable_status,'</b></font>'];
        end

    case 'GOAL_FALSIFIABLE'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            falsified_status=getString(message('Sldv:SlavtengResCallback:FALSIFIED'));
            fstr=['<font color="red"><b>',falsified_status,'</b></font>'];
        end

    case 'GOAL_FALSIFIABLE_NEEDS_SIMULATION'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            if goalUdi.testIndex>0||strcmp(settings.Mode,'DesignErrorDetection')









                falsifiedneedssimulation_status=getString(message('Sldv:SlavtengResCallback:FALSIFIEDNEEDSSIMULATION'));
                if strcmp(settings.Mode,'DesignErrorDetection')
                    fstr=['<font color="red"><b>',falsifiedneedssimulation_status,'</b></font>'];
                else
                    fstr=['<font color="orange"><b>',falsifiedneedssimulation_status,'</b></font>'];
                end
            else



                falsified_status=getString(message('Sldv:SlavtengResCallback:FALSIFIEDNOCOUNTEREXAMPLE'));
                fstr=['<font color="red"><b>',falsified_status,'</b></font>'];
            end
        end

    case 'GOAL_UNDECIDED_WITH_COUNTEREXAMPLE'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            undecidedwithcounterexample_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDWITHCOUNTEREXAMPLE'));
            fstr=['<font color="orange"><b>',undecidedwithcounterexample_status,'</b></font>'];
        end

    case 'GOAL_VALID'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            deadlogic_status=getString(message('Sldv:SlavtengResCallback:DEADLOGIC'));
            fstr=['<font color="red"><b>',deadlogic_status,'</b></font>'];
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            deadlogic_status=getString(message('Sldv:SlavtengResCallback:DEADLOGIC'));
            fstr=['<font color="red"><b>',deadlogic_status,'</b></font>'];
        else
            provenvalid_status=getString(message('Sldv:SlavtengResCallback:PROVENVALID'));
            fstr=['<font color="green"><b>',provenvalid_status,'</b></font>'];
        end

    case 'GOAL_VALID_BOUNDED'
        settings=tcompUdi.activeSettings;
        nocounterexample_status=getString(message('Sldv:SlavtengResCallback:NOCOUNTEREXAMPLESOF0numberinteger',settings.MaxViolationSteps));
        fstr=['<font color="green"><b>',nocounterexample_status,'</b></font>'];

    case 'GOAL_SATISFIABLE'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        elseif strcmp(goalUdi.type,'AVT_GOAL_REQTABLE')



            goalUdi.status='GOAL_FALSIFIABLE';
            fstr=updateGoal(tcompUdi,goalUdi);
        else
            satisfied_status=getString(message('Sldv:SlavtengResCallback:SATISFIED'));
            fstr=['<font color="green"><b>',satisfied_status,'</b></font>'];
        end

    case 'GOAL_SATISFIED_BY_COVERAGE_DATA'
        satisfied_by_cov_data_status=getString(message('Sldv:SlavtengResCallback:SATISFIEDBYCOVERAGEDATA'));
        fstr=['<font color="green"><b>',satisfied_by_cov_data_status,'</b></font>'];

    case 'GOAL_SATISFIED_BY_EXISTING_TESTCASE'
        satisfied_by_existing_tc_status=getString(message('Sldv:SlavtengResCallback:SATISFIEDBYEXISTINGTESTCASE'));
        fstr=['<font color="green"><b>',satisfied_by_existing_tc_status,'</b></font>'];

    case 'GOAL_SATISFIABLE_NEEDS_SIMULATION'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        elseif strcmp(goalUdi.type,'AVT_GOAL_REQTABLE')&&goalUdi.testIndex



            goalUdi.status='GOAL_FALSIFIABLE_NEEDS_SIMULATION';
            fstr=updateGoal(tcompUdi,goalUdi);
        else
            if goalUdi.testIndex>0||isXIL
                satisfiedneedssimulation_status=getString(message('Sldv:SlavtengResCallback:SATISFIEDNEEDSSIMULATION'));
                fstr=['<font color="orange"><b>',satisfiedneedssimulation_status,'</b></font>'];
            else
                satisfiednotestcase_status=getString(message('Sldv:SlavtengResCallback:SATISFIEDNOTESTCASE'));
                fstr=['<font color="green"><b>',satisfiednotestcase_status,'</b></font>'];
            end
        end

    case 'GOAL_UNDECIDED_WITH_TESTCASE'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            undecidedwithtestcase_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDWITHTESTCASE'));
            fstr=['<font color="orange"><b>',undecidedwithtestcase_status,'</b></font>'];
        end

    case 'GOAL_UNDECIDED_RUNTIME_ERROR'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            undecidedwithruntimeerror_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDRUNTIMEERROR'));
            fstr=['<font color="orange"><b>',undecidedwithruntimeerror_status,'</b></font>'];
        end

    case 'GOAL_UNDECIDED_STUB'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            undecidedstub_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDDUETOSTUBBING'));
            fstr=['<font color="orange"><b>',undecidedstub_status,'</b></font>'];
        end

    case 'GOAL_NONLINEAR'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            nonlinear_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDDUETONONLINEARITIES'));
            fstr=['<font color="orange"><b>',nonlinear_status,'</b></font>'];
        end

    case 'GOAL_DIVBYZERO'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            divbyzero_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDDUETODIVISION'));
            fstr=['<font color="orange"><b>',divbyzero_status,'</b></font>'];
        end

    case 'GOAL_OUTOFBOUNDS'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            fstr='';
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            fstr='';
        else
            outofbounds_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDDUETOOUTOFBOUNDS'));
            fstr=['<font color="orange"><b>',outofbounds_status,'</b></font>'];
        end

    case 'GOAL_INDETERMINATE'
        undecided_status=getString(message('Sldv:SlavtengResCallback:UNDECIDED'));
        fstr=['<font color="orange"><b>',undecided_status,'</b></font>'];

    case 'GOAL_VALID_APPROX'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            deadlogicunderapprox_status=getString(message('Sldv:SlavtengResCallback:DEADLOGICUNDERAPPROX'));
            fstr=['<font color="red"><b>',deadlogicunderapprox_status,'</b></font>'];
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            deadlogicunderapprox_status=getString(message('Sldv:SlavtengResCallback:DEADLOGICUNDERAPPROX'));
            fstr=['<font color="red"><b>',deadlogicunderapprox_status,'</b></font>'];
        else
            validapprox_status=getString(message('Sldv:SlavtengResCallback:VALIDAPPROX'));
            fstr=['<font color="orange"><b>',validapprox_status,'</b></font>'];
        end

    case 'GOAL_UNSATISFIABLE_APPROX'
        if slfeature('SLDVCombinedDLRTE')&&isDeadLogicGoal
            deadlogic_status=getString(message('Sldv:SlavtengResCallback:DEADLOGICUNDERAPPROX'));
            fstr=['<font color="red"><b>',deadlogic_status,'</b></font>'];
        elseif~slfeature('SLDVCombinedDLRTE')&&hasDeadLogic
            deadlogic_status=getString(message('Sldv:SlavtengResCallback:DEADLOGICUNDERAPPROX'));
            fstr=['<font color="red"><b>',deadlogic_status,'</b></font>'];
        elseif strcmp(settings.DisplayUnsatisfiableObjectives,'on')
            unsatapprox_status=getString(message('Sldv:SlavtengResCallback:UNSATAPPROX'));
            fstr=['<font color="orange"><b>',unsatapprox_status,'</b></font>'];
        end

    case 'GOAL_UNDECIDED_APPROX'
        undecidedapprox_status=getString(message('Sldv:SlavtengResCallback:UNDECIDEDDUETOAPPROXIMATIONS'));
        fstr=['<font color="orange"><b>',undecidedapprox_status,'</b></font>'];
    end


    if strcmpi(status,'GOAL_INDETERMINATE')
        elapsedTime=-1;
    else
        elapsedTime=tcompUdi.getElapsedTime;
    end
    tcompUdi.analysisInfo.analysisTime(goalUdi.getGoalMapId)=elapsedTime;


    str='';
    if~isempty(fstr)
        str=sprintf('%s\n%s\n%s\n%s\n\n',...
        fstr,to_html(pathStr),to_html(goalUdi.description),sec2hhmmss(elapsedTime));
    end
end

function out=to_html(in)
    out=strrep(in,'<','&lt;');
    out=strrep(out,'>','&gt;');
end

function str=sec2hhmmss(ctime)
    analtime=getString(message('Sldv:SlavtengResCallback:AnalysisTime'));
    if ctime<0

        notApplicable=getString(message('Sldv:SlavtengResCallback:NotApplicable'));
        str=[analtime,' = ',notApplicable];
    else
        hh=floor(ctime/3600);
        mm=floor((ctime-hh*3600)/60);
        ss=ctime-hh*3600-mm*60;
        str=sprintf('%s = %02d:%02d:%02d',analtime,hh,mm,ss);
    end
end








