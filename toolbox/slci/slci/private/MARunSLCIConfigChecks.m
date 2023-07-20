function ftObjs=MARunSLCIConfigChecks(checkEnum,system,varargin)



    result=true;
    ftObjs={};
    ftFix=ModelAdvisor.Paragraph;
    modelObj=getSLCIModelObj();

    constraints=modelObj.getConstraint(checkEnum);





    additionalConstraints=getAdditionalConstraints(modelObj,checkEnum);
    constraints=[constraints,additionalConstraints];
    fix=(nargin==3);
    hasFix=false;

    for i=1:numel(constraints)
        [failures,preReqConstraintFailFlag]=constraints{i}.checkCompatibility;
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.UserData.Sid=constraints{i}.getSID;
        ft.UserData.ID=constraints{i}.getID;
        if isempty(failures)
            ft.setSubResultStatus('Pass');
            [subTitle,Information,passText,~]=constraints{i}.getMAStrings(true);
            ft.setSubResultStatusText(passText);
        else
            if fix&&constraints{i}.hasAutoFix()

                for j=numel(failures):-1:1
                    status=failures(j).getConstraint.fix();
                    [subTitle,Information,passText,~]=failures(j).getConstraint.getMAStrings(status,'fix');
                    ftFix.addItem(passText);
                    ftFix.addItem(ModelAdvisor.LineBreak);
                end
            else
                result=false;
                hasFix=hasFix||constraints{i}.hasAutoFix();
                [subTitle,Information,warnText,RecAction]=constraints{i}.getMAStrings(false);
                ft.setSubResultStatus('Warn');
                if preReqConstraintFailFlag
                    RecAction='';
                    warnText=DAStudio.message('Slci:compatibility:PrereqConstraintsWarn');
                    for j=1:numel(failures)
                        [~,~,twarn,tRecAction]=failures(j).getMAStrings();
                        warnText=[warnText,twarn];%#ok
                        RecAction=[RecAction,tRecAction];%#ok
                    end
                    warnText=[warnText,' ',DAStudio.message('Slci:compatibility:PrereqConstraintsRerun')];%#ok
                end
                ft.setSubResultStatusText(warnText);
                ft.setRecAction(RecAction);
            end
        end
        ft.setSubTitle(subTitle);
        ft.setInformation(Information);
        ftObjs{end+1}=ft;%#ok<AGROW>
    end

    if~fix
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(result);
        mdladvObj.setActionEnable(~result&&hasFix);
        ftObjs{end}.setSubBar(false);
    else
        ftObjs=ftFix;
    end
end

function additionalConstraints=getAdditionalConstraints(modelObj,checkEnum)
    additionalConstraints=[];
    if strcmp(checkEnum,'DiagnosticsPane')
        additionalConstraints=modelObj.getConstraint('StrictBusMsg');
    end
    if strcmp(checkEnum,'CodeGenerationPane')
        additionalConstraints=modelObj.getConstraint('DataExchangeInterface');
    end
end

