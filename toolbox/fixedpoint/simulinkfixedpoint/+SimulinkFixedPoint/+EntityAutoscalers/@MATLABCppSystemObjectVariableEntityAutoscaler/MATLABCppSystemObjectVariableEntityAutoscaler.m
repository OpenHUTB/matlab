classdef MATLABCppSystemObjectVariableEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler





    methods

        function[DTConInfo,comments,paramName]=...
            gatherSpecifiedDT(~,variableIdentifier,varargin)











            paramName='';
            comments={};
            sysObjMxInfoID=variableIdentifier.MATLABExpressionIdentifiers(1).MxInfoID;
            sysObjMxInfo=variableIdentifier.MasterInferenceReport.MxInfos{sysObjMxInfoID};
            sysObjPropNames={sysObjMxInfo.ClassProperties(:).PropertyName};


            idx=strcmpi(sysObjPropNames,'cSFunObject');
            cSFunObjectProp=sysObjMxInfo.ClassProperties(idx);
            cSFunObjectMxInfo=variableIdentifier.MasterInferenceReport.MxInfos{cSFunObjectProp.MxInfoID};
            sysObjInstance=variableIdentifier.MasterInferenceReport.MxArrays{cSFunObjectMxInfo.SEACompID};
            loggedPropName=regexp(varargin{1},'\.','split');
            loggedPropName=loggedPropName{end};
            parentPropName=regexprep(loggedPropName,'Custom','');
            parentPropValue=get(sysObjInstance,parentPropName);
            if isempty(regexpi(parentPropValue,'Custom'))
                specifiedDTStr=parentPropValue;
            else
                specifiedDTNumType=variableIdentifier.MasterInferenceReport.MxArrays{variableIdentifier.MasterInferenceReport.MxInfos{variableIdentifier.MxInfoID}.NumericTypeID};
                specifiedDTStr=tostring(specifiedDTNumType);
                mdl=variableIdentifier.getHighestLevelParent;
                if~isempty(mdl)&&...
                    ~(strcmpi(get_param(mdl,'SimulationStatus'),'stopped')||...
                    strcmpi(get_param(mdl,'SimulationStatus'),'terminating'))



                    if strncmpi(specifiedDTNumType.Signedness,'Auto',4)
                        specifiedDTNumType.Signedness='Signed';
                        specifiedDTStr=tostring(specifiedDTNumType);
                    end
                end
            end
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,variableIdentifier.getMATLABFunctionBlock);
        end

        function[min_val,max_val]=gatherDesignMinMax(~,~,varargin)

            min_val=[];
            max_val=[];
        end

        function sharedList=gatherSharedDT(~,~)
            sharedList={};
        end

        function sharedList=gatherSharedDTWithBusObj(~,~,~,~)
            sharedList={};
        end

        function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(~,~,~,~)
            busObjHandleAndICList=[];
        end

    end

end


