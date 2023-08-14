classdef(CaseInsensitiveProperties=true)Check<ModelAdvisor.Check

    properties
SObjs
SubChecksCfg
CheckCatalogPrefix
zGroup
LicenseString
subLicenses
GuidelineID
relevantEntities
    end

    properties(Hidden)
SubChecksMetaInfo
    end

    methods
        function obj=Check(checkID,subcheckcfg,group)
            obj=obj@ModelAdvisor.Check(checkID);

            parts=strsplit(checkID,'.');
            obj.GuidelineID=parts{3};
            standard=parts{2};


            obj.CheckCatalogPrefix=getCatalogPrefix(standard);

            obj.Title=DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_title']);
            obj.TitleTips=[DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_guideline']),newline,newline,DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_tip'])];
            obj.CSHParameters.MapKey=getCSHMapByStandard(standard);
            obj.CSHParameters.TopicID=checkID;
            obj.SupportHighlighting=true;
            obj.SupportExclusion=true;
            obj.CallbackStyle='DetailStyle';

            [compileModes,licenses,hasFixit]=obj.parseAndValidateSubcheckCfg(subcheckcfg);

            obj.subLicenses=licenses;

            obj.SubChecksCfg=subcheckcfg;

            if any(strcmp(compileModes,'PostCompile'))
                obj.Value=false;
                obj.SupportLibrary=false;
                obj.CallbackContext='PostCompile';
            else
                obj.Value=true;
                obj.SupportLibrary=true;
                obj.CallbackContext='None';
            end

            obj.CallbackHandle=@(system,checkObj)obj.CheckCallBackFcn(system,checkObj);


            if hasFixit
                modifyAction=ModelAdvisor.Action;
                modifyAction.setCallbackFcn(@(taskObj)obj.CheckActionCallback(taskObj));
                modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
                modifyAction.Description=DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_action_description']);
                modifyAction.Enable=false;
                obj.setAction(modifyAction);
            end

            obj.zGroup=group;
        end

        function register(this)
            lics=unique([this.LicenseString,this.subLicenses]);
            this.setLicense(lics(cellfun(@(x)~isempty(x),lics)));

            mdladvRoot=ModelAdvisor.Root;
            mdladvRoot.publish(this,this.zGroup);
        end




        CheckCallBackFcn(this,system,checkObj);

        result=CheckActionCallback(this,taskObj);

        inputParamList=setDefaultInputParams(this,bAddFLLUM);

        gatherAndSetResults(this,results,checkObj,mdladvObj);

        [compileModes,licenses,hasFixit]=parseAndValidateSubcheckCfg(this,sccfg)

    end

    methods(Static)


        function defaultInputParamCallback(taskobj,tag,inpIndices)

            if numel(inpIndices)<=1
                return;
            end

            allNeededTags=arrayfun(@(x)['InputParameters_',num2str(x)],inpIndices,'UniformOutput',false);


            if~ismember(tag,allNeededTags)
                return;
            end

            inpId=regexp(tag,'InputParameters_(\d+)','tokens');
            inpId=str2double(inpId{1});

            if isnan(inpId)
                return;
            end

            if isa(taskobj,'ModelAdvisor.Task')
                inputParameters=taskobj.Check.InputParameters;
            elseif isa(taskobj,'ModelAdvisor.ConfigUI')
                inputParameters=taskobj.InputParameters;
            else
                return;
            end

            if inputParameters{inpId}.Value==0


                if all(cellfun(@(x)x.Value==0,inputParameters(inpIndices)))
                    inputParameters{inpId}.Value=1;
                    warndlgHandle=warndlg(DAStudio.message('ModelAdvisor:engine:SubCheck_InputParam_SelectionWarning'));
                    set(warndlgHandle,'Tag','MACEInvalidSubCheckSelection');
                    if isa(taskobj.MAObj,'Simulink.ModelAdvisor')
                        taskobj.MAObj.DialogCellArray{end+1}=warndlgHandle;
                    end
                end
            end

        end
    end

end

function map=getCSHMapByStandard(standard)
    if strcmp(standard,'jmaab')
        map='ma.mw.jmaab';
    else
        map=['ma.',standard];
    end
end

function prefix=getCatalogPrefix(standard)
    if strcmp(standard,'maab')
        prefix='ModelAdvisor:styleguide:';
    else
        prefix=['ModelAdvisor:',standard,':'];
    end
end


function C=flattenCell(A)
    C={};
    for i=1:numel(A)
        if(~iscell(A{i}))
            C=[C,A{i}];%#ok<AGROW>
        else
            Ctemp=flattenCell(A{i});
            C=[C,Ctemp{:}];%#ok<AGROW>
        end
    end
end


