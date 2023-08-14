classdef DesignfiltTaskModel<matlab.mixin.SetGet





    properties(Access=protected,Constant,Transient)

        OutputVariable="designedFilter";

        ToolboxVersion=ver('signal');
    end

    properties(Transient)
        ViewMagAndPhase(1,1)logical=true;
        ViewGroupDelay(1,1)logical=false;
        ViewPhaseDelay(1,1)logical=false;
        ViewImpulseResponse(1,1)logical=false;
        ViewStepResponse(1,1)logical=false;
        ViewPZPlot(1,1)logical=false;
        ViewFilterInfo(1,1)logical=false;
    end

    properties(Dependent)
Response
    end

    properties(Access=private)



        pResponseModelsMap;
        pResponse(1,1)string="select";
    end

    methods
        function this=DesignfiltTaskModel()

            this.pResponseModelsMap=containers.Map;
        end
    end




    methods

        function set.Response(this,resp)
            this.pResponse=resp;



            if~strcmp(resp,'select')&&~isKey(this.pResponseModelsMap,resp)
                mdl=signal.task.internal.designfilt.responseModelFactory(resp);
                this.pResponseModelsMap(resp)=mdl;
            end
        end
        function val=get.Response(this)
            val=this.pResponse;
        end

        function flag=isResponseValid(this)
            flag=~strcmp(this.Response,'select');
        end

        function mdl=getCurrentModel(this)
            mdl=[];
            if isResponseValid(this)
                mdl=this.pResponseModelsMap(this.Response);
            end
        end
    end




    methods

        function viewSettings=updateModelAndGetViewSettings(this,whatChanged,evtData)




            if whatChanged=="response"
                this.Response=evtData.Value;
            end


            mdl=getCurrentModel(this);
            viewSettings=[];
            if isempty(mdl)
                return;
            end
            if whatChanged=="response"


                viewSettings=getViewSettings(mdl,whatChanged,evtData);
            else
                updateModel(mdl,whatChanged,evtData);
                viewSettings=getViewSettings(mdl,whatChanged,evtData);
            end
        end
    end




    methods
        function[code,outputs]=generateScript(this)


            import signal.task.internal.designfilt.msgid2txt

            if~isReadyForScript(this)

                code='';
                outputs={};
                return;
            end

            mdl=getCurrentModel(this);
            [successFlag,designFiltCode]=generateScript(mdl);


            if successFlag
                str=StringWriter;
                str.addcr('%% %s',msgid2txt('GenCodeH1Line'));
                str.addcr('%s = %s',this.OutputVariable,designFiltCode);
                str.indentCode();
                code=string(str.char());
                newCode=breakCodeIntoMultipleLines(code);
                str=StringWriter;
                str.addcr('%s',newCode);
                str.indentCode();
                code=deblank(str.char());

                outputs={this.OutputVariable};
            else
                code='';
            end
        end

        function code=generateVisualizationScript(this)



            import signal.task.internal.designfilt.msgid2txt

            code='';
            if~isReadyForScript(this)

                return;
            else
                mdl=getCurrentModel(this);
                [isFreqUnitsHz,fsName]=getSampleRateInfo(mdl);
                if isFreqUnitsHz
                    if isfir(mdl)
                        inputArgs=this.OutputVariable+".Coefficients,1,[],"+fsName;
                    else
                        [isMinOrderDesign,orderValue]=getOrderSettings(mdl);
                        if~isMinOrderDesign&&orderValue<3
                            inputArgs="["+this.OutputVariable+".Coefficients;[1 0 0 1 0 0]],[],"+fsName;
                        else
                            inputArgs=this.OutputVariable+".Coefficients,[],"+fsName;
                        end
                    end
                else
                    if isfir(mdl)
                        inputArgs=this.OutputVariable+".Coefficients";
                    else
                        [isMinOrderDesign,orderValue]=getOrderSettings(mdl);
                        if~isMinOrderDesign&&orderValue<3
                            inputArgs="["+this.OutputVariable+".Coefficients;[1 0 0 1 0 0]]";
                        else
                            inputArgs=this.OutputVariable+".Coefficients";
                        end
                    end
                end

                str=StringWriter;
                addEmptyLine=false;
                varsToClear=[];
                if this.ViewMagAndPhase
                    str.addcr('%% %s',msgid2txt('MagAndPhaseH1'));
                    str.addcr('freqz(%s)',inputArgs);
                    addEmptyLine=true;
                end
                if this.ViewGroupDelay
                    if addEmptyLine
                        str.addcr('');
                    end
                    str.addcr('%% %s',msgid2txt('GroupDelayH1'));
                    str.addcr('grpdelay(%s)',inputArgs);
                    addEmptyLine=true;
                end
                if this.ViewPhaseDelay
                    if addEmptyLine
                        str.addcr('');
                    end
                    str.addcr('%% %s',msgid2txt('PhaseDelayH1'));
                    str.addcr('phasedelay(%s)',inputArgs);
                    addEmptyLine=true;
                end
                if this.ViewImpulseResponse
                    if addEmptyLine
                        str.addcr('');
                    end
                    str.addcr('%% %s',msgid2txt('ImpulseResponseH1'));
                    str.addcr('impz(%s)',inputArgs);
                    addEmptyLine=true;
                end
                if this.ViewStepResponse
                    if addEmptyLine
                        str.addcr('');
                    end
                    str.addcr('%% %s',msgid2txt('StepResponseH1'));
                    str.addcr('stepz(%s)',inputArgs);
                    addEmptyLine=true;
                end
                if this.ViewPZPlot
                    if addEmptyLine
                        str.addcr('');
                    end
                    str.addcr('%% %s',msgid2txt('PZPlotH1'));
                    if isfir(mdl)
                        str.addcr('zplane(%s.Coefficients)',this.OutputVariable);
                    else
                        str.addcr('[z,p] = sos2zp(%s.Coefficients);',this.OutputVariable);
                        str.addcr('zplane(z,p)');
                        varsToClear=["z","p"];
                    end
                    addEmptyLine=true;
                end
                if this.ViewFilterInfo
                    if addEmptyLine
                        str.addcr('');
                    end
                    str.addcr('%% %s',msgid2txt('FilterInfoH1'));
                    str.addcr('info(%s)',this.OutputVariable);
                end
                if~isempty(varsToClear)
                    str.addcr('');
                    str.addcr('%% %s',msgid2txt('ClearVarsH1'));
                    str.addcr('clear %s',strjoin(varsToClear,' '));
                end
                str.indentCode();
                code=deblank(str.char());
            end
        end

        function summary=generateSummary(this)


            import signal.task.internal.designfilt.msgid2txt

            summary=msgid2txt('TaskDefaultSummary');

            if isReadyForScript(this)
                summary=msgid2txt(this.Response+"Summary");
            end
        end

        function modelState=getState(this)


            modelState=struct;


            allResponses=keys(this.pResponseModelsMap);
            modelState.ResponseList=cell(numel(allResponses),1);
            for idx=1:numel(allResponses)
                resp=allResponses{idx};
                mdl=this.pResponseModelsMap(resp);
                modelState.(resp)=getState(mdl);
                modelState.ResponseList{idx}=resp;
            end




            modelState.Response=this.Response;

            modelState.ViewMagAndPhase=this.ViewMagAndPhase;
            modelState.ViewGroupDelay=this.ViewGroupDelay;
            modelState.ViewPhaseDelay=this.ViewPhaseDelay;
            modelState.ViewImpulseResponse=this.ViewImpulseResponse;
            modelState.ViewStepResponse=this.ViewStepResponse;
            modelState.ViewPZPlot=this.ViewPZPlot;
            modelState.ViewFilterInfo=this.ViewFilterInfo;
            modelState.ToolboxVersion=this.ToolboxVersion;
        end

        function setState(this,modelState)





            for idx=1:numel(modelState.ResponseList)
                resp=modelState.ResponseList{idx};
                this.Response=resp;
                mdl=getCurrentModel(this);
                setState(mdl,modelState.(resp));
            end


            this.Response=modelState.Response;


            this.ViewMagAndPhase=modelState.ViewMagAndPhase;
            this.ViewGroupDelay=modelState.ViewGroupDelay;
            this.ViewPhaseDelay=modelState.ViewPhaseDelay;
            this.ViewImpulseResponse=modelState.ViewImpulseResponse;
            this.ViewStepResponse=modelState.ViewStepResponse;
            this.ViewPZPlot=modelState.ViewPZPlot;
            this.ViewFilterInfo=modelState.ViewFilterInfo;
        end

        function reset(this)

            this.ViewMagAndPhase=true;
            this.ViewGroupDelay=false;
            this.ViewPhaseDelay=false;
            this.ViewImpulseResponse=false;
            this.ViewStepResponse=false;
            this.ViewPZPlot=false;
            this.ViewFilterInfo=false;

            this.pResponseModelsMap=containers.Map;
            this.Response=this.pResponse;
        end

        function flag=isReadyForScript(this)



            flag=false;
            if~strcmp(this.Response,'select')
                flag=true;
            end
        end
    end
end

function newStr=breakCodeIntoMultipleLines(str)

    s=strsplit(str,',');

    if numel(s)<6
        newStr=str;
        return;
    end

    cnt=0;
    newStr=string(sprintf('%s, ...\n',s(1)));
    for idx=2:numel(s)



        currentStr=s(idx);
        if contains(currentStr,'{')
            continue;
        end
        cnt=cnt+1;
        if contains(currentStr,'}')
            currentStr=s(idx-1)+","+currentStr;
        end
        newStr=newStr+currentStr;
        if idx==numel(s)
            break;
        else
            newStr=newStr+",";
        end
        if cnt==4
            newStr=string(sprintf('%s ...\n',newStr));
            cnt=0;
        end
    end
end