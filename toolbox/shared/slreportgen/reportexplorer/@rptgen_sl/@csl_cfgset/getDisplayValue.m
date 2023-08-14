function[dValue,dName,sourceInfoArr]=getDisplayValue(this,dName)




    model=get(rptgen_sl.appdata_sl,'CurrentModel');
    if~isempty(model)
        dValue=getActiveConfigSet(model);
        sourceInfoArr=cell(2,2);
        sourceInfoArr{1,1}=[this.msg('CfgSetReportField_Source'),':'];
        sourceInfoArr{2,1}=[this.msg('CfgSetReportField_SourceName'),':'];

        if isa(dValue,'Simulink.ConfigSet')
            isReference=false;

            allConfSetNames=getConfigSets(model);
            for cfsNum=1:length(allConfSetNames)
                cfsObj=getConfigSet(model,allConfSetNames{cfsNum});
                if isa(cfsObj,'Simulink.ConfigSetRef')
                    referencedCfsName=cfsObj.getRefConfigSet().Name;
                    if strcmp(dValue.Name,referencedCfsName)
                        isReference=true;
                        searchMethod='cached';
                        break;
                    end
                end
            end
        elseif isa(dValue,'Simulink.ConfigSetRef')
            cfsObj=dValue;
            isReference=true;
            searchMethod='compiled';
        else
            dValue=[];
            sourceInfoArr=[];
            return;
        end

        if~isReference
            sourceInfoArr{1,2}=this.msg('CfgSetReportField_Model');
            sourceInfoArr{2,2}=model;
        else
            [confSet,location]=locGetOutsideConfSetInfo(this,model,cfsObj,searchMethod);
            dValue=confSet;
            if~isempty(location)
                sourceInfoArr{1,2}=location.SourceType;
                sourceInfoArr{2,2}=location.SourceName;
            else
                sourceInfoArr=[];
            end
        end
    else
        dValue=[];
        sourceInfoArr=[];
    end
end

function[confSet,location]=locGetOutsideConfSetInfo(this,model,confSetRef,searchMethod)
    confSet=confSetRef.getRefConfigSet();
    location=[];


    inDD=Simulink.findVars(model,'SourceType','data dictionary','Name',confSet.Name,'SearchMethod',searchMethod);
    if~isempty(inDD)
        [~,dictName,~]=fileparts(inDD.Source);
        if strcmpi('data dictionary',inDD.SourceType)
            cfSourceType=this.msg('CfgSetReportField_DataDictionary');
        else
            cfSourceType=inDD.SourceType;
        end
        location=struct('SourceType',cfSourceType,'SourceName',dictName);
    else
        inWS=Simulink.findVars(model,'Name',confSetRef.WSVarName,'SearchMethod',searchMethod);
        if~isempty(inWS)
            if strcmpi('base workspace',inWS.SourceType)
                cfSourceType=this.msg('CfgSetReportField_BaseWorkspace');
            elseif strcmpi('model workspace',inWS.SourceType)
                cfSourceType=this.msg('CfgSetReportField_ModelWorkspace');
            else
                cfSourceType=inWS.SourceType;
            end
            location=struct('SourceType',cfSourceType,'SourceName',inWS.Name);
        end
    end
end


