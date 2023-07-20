classdef(Abstract)BaseResponseModel<handle




    properties(Constant,Hidden)
        OrderModeMappings=[...
        "minimum",signal.task.internal.designfilt.msgid2txt('minimum');
        "specify",signal.task.internal.designfilt.msgid2txt('specify');];

        FrequencyUnitsMappings=[...
        "normalized",signal.task.internal.designfilt.msgid2txt('normalized');
        "Hz",signal.task.internal.designfilt.msgid2txt('Hz');];

        SelectMappings=[
        "select",signal.task.internal.designfilt.msgid2txt('select');];

        SpecifyMappings=[
        "specify",signal.task.internal.designfilt.msgid2txt('specify');];
    end

    properties(Access=protected,Transient)
        pFilterDesignerObj;
        pSampleRateSource char{mustBeMember(pSampleRateSource,...
        ['workspaceVariable','value'])}='workspaceVariable'
        pSampleRateName char
        pSampleRateValue double






        pPreviousSampleRateValue double=2


        pKaiserWinPArameter=0.5;
        pChebWinParameter=100;
    end

    methods(Abstract)



        updateModel(mdl,whatChanged,evtData);
        viewSettings=getViewSettings(mdl,whatChanged,evtData);


        stateStruct=getState(mdl);
        setState(mdl,stateStruct);
    end

    methods
        function[successFlag,code]=generateScript(this)


            fdesObj=this.pFilterDesignerObj;
            code='';

            successFlag=generateCodeForLiveTask(fdesObj);
            if successFlag
                code=fdesObj.OutputCode;
                isFreqUnits=strcmp(this.pFilterDesignerObj.FrequencyUnits,'Hz');
                if isFreqUnits
                    fsIdx=strfind(code,"'SampleRate'");
                    valIdx=strfind(code(fsIdx:end),',')-2;
                    if numel(valIdx)>1
                        valIdx=valIdx(2);
                    else
                        valIdx=strfind(code(fsIdx:end),')')-2;
                    end
                    oldStr=code(fsIdx:fsIdx+valIdx);
                    newStr="'SampleRate',"+string(this.pSampleRateName);
                    code=strrep(code,oldStr,newStr);
                else
                    code=string(code);
                end

            end
        end

        function[isFreqUnitsHz,fsName]=getSampleRateInfo(this)



            fsName=strings(0,0);
            isFreqUnitsHz=strcmp(this.pFilterDesignerObj.FrequencyUnits,'Hz');
            if isFreqUnitsHz
                fsName=string(this.pSampleRateName);
            end
        end

        function flag=isfir(this)

            fdesObj=this.pFilterDesignerObj;
            flag=isfir(fdesObj);
        end

        function[isMinOrderDesign,orderValue]=getOrderSettings(this)
            fdesObj=this.pFilterDesignerObj;
            isMinOrderDesign=isminorder(fdesObj);
            orderValue=[];
            if~isMinOrderDesign
                orderValue=ensureNumeric(this,fdesObj.Order);
            end
        end
    end

    methods(Access=protected)
        function specificationSettings=getSpecificationsSettings(this)




            specificationSettings.OrderMode=this.pFilterDesignerObj.OrderMode;
            specificationSettings.OrderRestriction='none';
            if lower(string(specificationSettings.OrderMode))=="specify"
                specificationSettings.Order=ensureNumeric(this,this.pFilterDesignerObj.Order);
                specificationSettings.OrderRestriction=getOrderRestriction(this);
            end
        end

        function algorithmSettings=getAlgorithmSettings(this)

            fdesObj=this.pFilterDesignerObj;
            algorithmSettings.MethodPopupItems=fdesObj.getValidMethods;
            algorithmSettings.MethodPopupItemsData=fdesObj.getValidMethods;
            algorithmSettings.MethodPopupValue=fdesObj.DesignMethod;

            designOpts=string(getDesignOptions(this));
            if~isempty(designOpts)


                filtStructIdx=find(ismember(designOpts,'FilterStructure'));
                if~isempty(filtStructIdx)
                    designOpts([filtStructIdx,filtStructIdx+1])=[];
                end
            end
            algorithmSettings.DesignOptions=designOpts;
        end

        function setDesignOptionsState(this,designOpts)
            fdesObj=this.pFilterDesignerObj;
            for idx=1:numel(designOpts)/2
                name=designOpts{2*idx-1};
                if strcmp(name,'FilterStructure')



                    name='Structure';
                    val=designOpts{2*idx};
                    fdesObj.(name)=convertStructure(fdesObj,val);
                else
                    val=designOpts{2*idx};
                    if islogical(val)
                        fdesObj.(name)=val;
                    else
                        fdesObj.(name)=ensureString(this,val);
                    end
                end
            end
        end

        function fVal=ensureNumeric(~,val,evalInWkspace)


            if nargin<3
                evalInWkspace=false;
            end
            if evalInWkspace
            elseif ischar(val)
                fVal=str2double(val);
            else
                fVal=val;
            end
        end

        function val=ensureString(~,val)
            if~ischar(val)&&~isstring(val)
                val=strtrim(sprintf('%11.10g',val));
            end
        end

        function restriction=getOrderRestriction(~)



            restriction='none';
        end

        function desOptions=getDesignOptions(this)
            fdesObj=this.pFilterDesignerObj;

            desOptions=fdesObj.getDesignOptions;
            for idx=1:numel(desOptions)
                if ischar(desOptions{idx})&&strcmpi(desOptions{idx},'window')
                    if iscell(desOptions{idx+1})
                        c=desOptions{idx+1};
                        windowType=func2str(c{1});
                        windowParam=ensureString(this,c{2});
                        desOptions{idx+1}=['{@',windowType,',',windowParam,'}'];
                    end
                end
            end
        end

        function updateDesignOptionValues(this,whatChanged,evtData)

            fdesObj=this.pFilterDesignerObj;
            switch whatChanged
            case 'Window'
                if any(strcmp(evtData.Value,{'kaiser','chebwin'}))
                    if strcmp(evtData.Value,'kaiser')
                        windowParam=ensureString(this,this.pKaiserWinPArameter);
                    else
                        windowParam=ensureString(this,this.pChebWinParameter);
                    end
                    windowStr=string(['{@',evtData.Value,',',windowParam,'}']);
                else
                    windowStr=evtData.Value;
                end
            case 'WindowParameter'

                windowType=evtData.Source.UserData;

                if strcmp(windowType,'kaiser')
                    this.pKaiserWinPArameter=evtData.Value;
                else
                    this.pChebWinParameter=evtData.Value;
                end
                windowParam=ensureString(this,evtData.Value);
                windowStr=['{@',windowType,',',windowParam,'}'];
            end
            fdesObj.Window=windowStr;
        end
    end
end