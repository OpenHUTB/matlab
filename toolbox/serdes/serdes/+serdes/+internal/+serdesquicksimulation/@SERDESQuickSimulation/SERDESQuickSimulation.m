classdef SERDESQuickSimulation<handle




    properties

        VersionWhenSaved=[];


        AutoAnalyze=true;


        Jitter=serdes.internal.apps.serdesdesigner.jitter;


        PlotVisible_PulseRes=false;
        PlotVisible_ImpulseRes=false;
        PlotVisible_StatEye=false;
        PlotVisible_PrbsWaveform=false;
        PlotVisible_Contours=false;
        PlotVisible_Bathtub=false;
        PlotVisible_COM=false;
        PlotVisible_Report=false;
        PlotVisible_BER=false;
        PlotVisible_CTLE=false;


        BERtarget=1e-6;
        SymbolTime=100e-12;
        SamplesPerSymbol=16;
        Modulation='NRZ';
        Signaling='Differential';











    end

    properties(Constant)
        SamplesPerSymbolValues=serdes.internal.apps.serdesdesigner.Toolstrip.SamplesPerSymbolValues;
        ModulationValues=serdes.internal.apps.serdesdesigner.Toolstrip.ModulationValues;
        SignalingValues=serdes.internal.apps.serdesdesigner.Toolstrip.SignalingValues;
    end

    properties(Dependent)
Elements
AutoUpdate
View
    end

    properties(Access=private)
        PrivateElements=[]
        PrivateAutoUpdate=true
        PrivateView=[]
    end

    properties(Dependent,Access=private)
        Computable=false
    end

    properties(Constant,Hidden)
        Version=1.0
    end

    methods
        function obj=SERDESQuickSimulation(varargin)




            obj.Elements=[];
            obj.AutoUpdate=true;
            obj.View=[];
        end

        function val=get.Computable(obj)
            val=~isempty(obj.PrivateElements);
        end

        function val=get.VersionWhenSaved(obj)
            val=obj.VersionWhenSaved;
        end
        function set.VersionWhenSaved(obj,val)
            obj.VersionWhenSaved=val;
        end

        function val=get.Jitter(obj)
            val=obj.Jitter;
        end
        function set.Jitter(obj,val)
            obj.Jitter=val;
        end

        function val=get.BERtarget(obj)
            val=obj.BERtarget;
        end
        function set.BERtarget(obj,val)
            if obj.isNonZeroPositiveNumberLessThanEqual('BER Target',val,1e-3,1)
                if ischar(val)||isstring(val)
                    obj.BERtarget=str2double(val);
                else
                    obj.BERtarget=val;
                end
            end
        end

        function val=get.SymbolTime(obj)
            val=obj.SymbolTime;
        end
        function set.SymbolTime(obj,val)
            if obj.isNonZeroPositiveNumberBetween('Symbol Time (ps)',val,5e-12,1e-08,1e12)
                if ischar(val)||isstring(val)
                    obj.SymbolTime=str2double(val);
                else
                    obj.SymbolTime=val;
                end
            end
        end

        function val=get.SamplesPerSymbol(obj)
            val=obj.SamplesPerSymbol;
        end
        function set.SamplesPerSymbol(obj,val)
            if obj.isPositiveInteger('Samples Per Symbol',val)&&...
                obj.isSupportedValue('Samples Per Symbol',val,obj.SamplesPerSymbolValues)
                if ischar(val)||isstring(val)
                    obj.SamplesPerSymbol=str2double(val);
                else
                    obj.SamplesPerSymbol=val;
                end
            end
        end

        function val=get.Modulation(obj)
            val=obj.Modulation;
        end
        function set.Modulation(obj,val)
            if obj.isSupportedValue('Modulation',val,obj.ModulationValues)
                obj.Modulation=val;
            end
        end

        function val=get.Signaling(obj)
            val=obj.Signaling;
        end
        function set.Signaling(obj,val)
            if obj.isSupportedValue('Signaling',val,obj.SignalingValues)
                obj.Signaling=val;
            end
        end


























        function val=get.View(obj)
            val=obj.PrivateView;
        end
        function set.View(obj,val)
            if~isempty(val)
                obj.PrivateView=val;
            end
        end

        function val=get.Elements(obj)
            val=obj.PrivateElements;
        end
        function set.Elements(obj,val)
            if~isempty(val)








                validateattributes(val,{'cell',},{'vector'},'','Elements')
                for i=1:numel(val)
                    if~isempty(val{i})

                        validateattributes(val{i},...
                        {'agc','ffe','vga','satAmp','dfeCdr','cdr','ctle','transparent','channel','rcTx','rcRx',...
                        'serdes.internal.serdesquicksimulation.Element',...
                        'serdes.internal.serdesquicksimulation.SERDESElement'},{'vector'},'',...
                        'Elements')
                    end
                end
            end



            if~isempty(obj.PrivateElements)
                for i=1:numel(obj.PrivateElements)
                    if isvalid(obj.PrivateElements{i})
                        obj.PrivateElements{i}.SerdesDesign=[];
                        delete(obj.PrivateElements{i}.Listener)
                    end
                end
            end



            for i=1:numel(val)
                elem=val{i};
                if isempty(elem)
                    continue;
                end
                if isempty(elem.SerdesDesign)||~isvalid(elem.SerdesDesign)
                    elem.SerdesDesign=obj;
                    c=metaclass(elem);
                    p=c.PropertyList.findobj('SetObservable',true);
                    elem.Listener=addlistener(elem,p,'PostSet',@(h,e)computeOrErase(obj));
                else


                    if i>1
                        for j=1:i-1
                            val(j).SerdesDesign=[];
                            delete(val(j).Listener)
                        end
                    end
                    error(message('serdes:serdesdesigner:InOtherSerdesDesign',i))
                end
            end
            obj.PrivateElements=val(:)';
            computeOrErase(obj)
        end

        function val=get.AutoUpdate(obj)
            val=obj.PrivateAutoUpdate;
        end
        function set.AutoUpdate(obj,val)
            if isequal(val,obj.AutoUpdate)
                return
            end
            validateattributes(val,{'logical','numeric'},...
            {'nonempty','scalar'},'','AutoUpdate')
            obj.PrivateAutoUpdate=val;
            if obj.AutoUpdate

            end



        end

        function channel=getChannel(obj)
            if~isempty(obj.Elements)
                for i=1:length(obj.Elements)
                    if isa(obj.Elements{i},'serdes.internal.apps.serdesdesigner.channel')
                        channel=obj.Elements{i};
                        return;
                    end
                end
            end
            channel=[];
        end
        function success=refreshValuesFromWorkspaceVariables(obj)

            if~isempty(obj.Elements)
                for i=1:length(obj.Elements)
                    element=obj.Elements{i};
                    element.isParameterWorkspaceValuesRestored=true;
                    if~isempty(element.ParameterWorkspaceValues)
                        for j=1:length(element.ParameterWorkspaceValues)
                            if~isempty(element.ParameterWorkspaceValues{j})
                                workspaceParamValue=element.ParameterWorkspaceValues{j};
                                workspaceParamName=element.ParameterValues{j};
                                body=[];
                                if~element.isWorkspaceVariable(workspaceParamName)
                                    body=message('serdes:serdesdesigner:LostWorkspaceVariable_Missing',workspaceParamName);
                                elseif~element.isNonBlankWorkspaceVariable(workspaceParamName)
                                    body=message('serdes:serdesdesigner:LostWorkspaceVariable_Blank',workspaceParamName);
                                elseif isa(element,'serdes.internal.apps.serdesdesigner.channel')&&...
                                    strcmpi(element.ParameterNames{j},'ImpulseResponse')&&...
                                    ~element.isValidImpulseResponseWorkspaceVariable(workspaceParamName)
                                    actualValue=num2str(evalin('base',workspaceParamName));
                                    body=message('serdes:serdesdesigner:LostWorkspaceVariable_BadValue',workspaceParamName,actualValue);
                                elseif isa(element,'serdes.internal.apps.serdesdesigner.ctle')&&...
                                    strcmpi(element.ParameterNames{j},'myGPZ')&&...
                                    ~element.isValidGPZWorkspaceVariable(workspaceParamName)
                                    actualValue=num2str(evalin('base',workspaceParamName));
                                    body=message('serdes:serdesdesigner:LostWorkspaceVariable_BadValue',workspaceParamName,actualValue);
                                end
                                if~isempty(body)
                                    title=message('serdes:serdesdesigner:LostWorkspaceVariableTitle');
                                    h=errordlg(getString(body),getString(title),'modal');
                                    uiwait(h);
                                    success=false;
                                    return;
                                else

                                    element.setWorkspaceVariableValue(element.ParameterNames{j},workspaceParamName);
                                    if strcmpi(element.ParameterNames{j},'myGPZ')&&isa(element,'serdes.internal.apps.serdesdesigner.ctle')

                                        index=find(strcmpi(element.ParameterNames,'GPZ'));
                                        if index>=1
                                            actualValue=evalin('base',workspaceParamName);
                                            element.ParameterValues{index}=actualValue;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            success=true;
        end
        function restoreWorkspaceVariables(obj)

            if~isempty(obj.Elements)
                for i=1:length(obj.Elements)
                    element=obj.Elements{i};
                    element.isParameterWorkspaceValuesRestored=true;
                    if~isempty(element.ParameterWorkspaceValues)
                        for j=1:length(element.ParameterWorkspaceValues)
                            if~isempty(element.ParameterWorkspaceValues{j})
                                workspaceParamValue=element.ParameterWorkspaceValues{j};
                                workspaceParamName=element.ParameterValues{j};
                                if~element.isWorkspaceVariable(workspaceParamName)


                                    assignin('base',workspaceParamName,workspaceParamValue);
                                    element.(element.ParameterNames{j})=workspaceParamName;
                                else


                                    count=0;
                                    while true
                                        count=count+1;
                                        proposedName=strcat(workspaceParamName,'_',num2str(count));
                                        if~element.isWorkspaceVariable(proposedName)
                                            assignin('base',proposedName,workspaceParamValue);
                                            element.(element.ParameterNames{j})=proposedName;
                                            element.ParameterValues{j}=proposedName;
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    methods
        function show(obj)
            serdesDesigner(obj)
        end

        function delete(obj)


            if~isempty(obj.PrivateElements)
                for i=1:numel(obj.PrivateElements)
                    if isvalid(obj.PrivateElements{i})
                        obj.PrivateElements{i}.SerdesDesign=[];
                        delete(obj.PrivateElements{i}.Listener)
                    end
                end
            end
        end
    end

    methods
        hDoc=exportScript(obj)

        serdesplot(obj,txt)
    end

    methods(Access=private)
        function computeOrErase(obj)
            if obj.AutoUpdate

            end
        end
    end

    methods
        function ckt=circuit(obj,varargin)
            if isempty(obj.Elements)
                ckt=circuit(varargin{:});
            else
                ckt=circuit(obj.Elements,varargin{:});
            end
        end
    end


    methods
        function disp(obj)
            f=fields(obj);
            if~isscalar(obj)
                [M,N]=size(obj);
                fprintf('  %dx%d <a href="matlab:helpPopup serdesquicksimulation">serdesquicksimulation</a> array with properties:\n\n',...
                M,N);
                cellfun(@(s)fprintf('    %s\n',s),f)
            else
                fprintf('  <a href="matlab:helpPopup serdesquicksimulation">serdesquicksimulation</a> with properties:\n\n')


                if isempty(obj.Elements)
                    fprintf('%23s: []\n',f{1});
                else
                    fprintf('%23s: [1x%d %s]\n',f{1},...
                    numel(obj.Elements),class(obj.Elements))
                end


                if obj.AutoUpdate
                    fprintf('%23s: true\n',f{2})
                else
                    fprintf('%23s: false\n',f{2})
                end
            end
            fprintf('\n')
        end

        function out=clone(obj)
            out=serdesquicksimulation;
            out.AutoUpdate=false;
            if~isempty(obj.Elements)
                out.VersionWhenSaved=obj.VersionWhenSaved;
                out.AutoAnalyze=obj.AutoAnalyze;

                out.Jitter=obj.Jitter;

                out.PlotVisible_PulseRes=obj.PlotVisible_PulseRes;
                out.PlotVisible_ImpulseRes=obj.PlotVisible_ImpulseRes;
                out.PlotVisible_StatEye=obj.PlotVisible_StatEye;
                out.PlotVisible_PrbsWaveform=obj.PlotVisible_PrbsWaveform;
                out.PlotVisible_Contours=obj.PlotVisible_Contours;
                out.PlotVisible_Bathtub=obj.PlotVisible_Bathtub;
                out.PlotVisible_COM=obj.PlotVisible_COM;
                out.PlotVisible_Report=obj.PlotVisible_Report;
                out.PlotVisible_BER=obj.PlotVisible_BER;
                out.PlotVisible_CTLE=obj.PlotVisible_CTLE;

                out.BERtarget=obj.BERtarget;
                out.SymbolTime=obj.SymbolTime;
                out.SamplesPerSymbol=obj.SamplesPerSymbol;
                out.Modulation=obj.Modulation;
                out.Signaling=obj.Signaling;


                out.Elements{1}=serdesClone(obj.Elements{1});
                for i=2:numel(obj.Elements)
                    out.Elements{i}=serdesClone(obj.Elements{i});
                end
            end
            out.PrivateAutoUpdate=obj.AutoUpdate;
        end
    end

    methods(Static,Hidden)


        function pos=newPos(p,x,y)

            ht=p(4)-p(2);
            wd=p(3)-p(1);
            pos=[x,y-ht/2,x+wd,y+ht/2];
        end

        function isSupported=isSupportedValue(nam,val,supportedValues)
            if(ischar(val)||isstring(val)||numel(val)==1)&&numel(supportedValues)>=1
                if isnumeric(val)&&~isnumeric(supportedValues)
                    val=num2str(val);
                end
                for i=1:numel(supportedValues)
                    if strcmpi(val,supportedValues{i})
                        isSupported=true;
                        return;
                    end
                end
            end
            isSupported=false;
            title=message('serdes:serdesdesigner:BadEntryTitle');
            body=message('serdes:serdesdesigner:UnsupportedEntryMessage',val,nam);
            h=errordlg(getString(body),getString(title),'modal');
            uiwait(h);
        end

        function isInt=isInteger(nam,val)
            if numel(val)==1&&~isnan(val)&&isnumeric(val)
                isInt=val==floor(val);
            else
                num=str2double(val);
                if numel(num)==1&&~isnan(num)&&num==floor(num)
                    isInt=true;
                else
                    isInt=false;
                end
            end
            if~isInt
                str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                title=message('serdes:serdesdesigner:BadEntryTitle');
                body=message('serdes:serdesdesigner:NonIntegerEntryMessage',str,nam);
                h=errordlg(getString(body),getString(title),'modal');
                uiwait(h);
            end
        end
        function isNum=isNumber(nam,val)
            if numel(val)==1&&~isnan(val)&&isnumeric(val)
                isNum=true;
            else
                num=str2double(val);
                if numel(num)==1&&~isnan(num)&&isreal(num)
                    isNum=true;
                else
                    isNum=false;
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:NonNumericEntryMessage',str,nam);
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end

        function isPlusInt=isPositiveInteger(nam,val)
            if~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isInteger(nam,val)
                isPlusInt=false;
            else
                if isnumeric(val)
                    isPlusInt=val>=0;
                else
                    isPlusInt=str2double(val)>=0;
                end
                if~isPlusInt
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:NegativeIntegerEntryMessage',str,nam);
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end
        function isPlusNum=isPositiveNumber(nam,val)
            if~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isNumber(nam,val)
                isPlusNum=false;
            else
                if isnumeric(val)
                    isPlusNum=val>=0;
                else
                    isPlusNum=str2double(val)>=0;
                end
                if~isPlusNum
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:NegativeNumericEntryMessage',str,nam);
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end

        function isNonZeroPlusInt=isNonZeroPositiveInteger(nam,val)
            if~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isPositiveInteger(nam,val)
                isNonZeroPlusInt=false;
            else
                if isnumeric(val)
                    isNonZeroPlusInt=val>0;
                else
                    isNonZeroPlusInt=str2double(val)>0;
                end
                if~isNonZeroPlusInt
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:ZeroIntegerEntryMessage',str,nam);
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end
        function isNonZeroPlusNum=isNonZeroPositiveNumber(nam,val)
            if~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isPositiveNumber(nam,val)
                isNonZeroPlusNum=false;
            else
                if isnumeric(val)
                    isNonZeroPlusNum=val>0;
                else
                    isNonZeroPlusNum=str2double(val)>0;
                end
                if~isNonZeroPlusNum
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:ZeroNumericEntryMessage',str,nam);
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end
        function isNonZeroPlusNumLessThan=isNonZeroPositiveNumberLessThanEqual(nam,val,lessThanValue,displayFactor)
            if~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isNonZeroPositiveNumber(nam,val)
                isNonZeroPlusNumLessThan=false;
            else
                if isnumeric(val)
                    isNonZeroPlusNumLessThan=val<=lessThanValue;
                else
                    isNonZeroPlusNumLessThan=str2double(val)<=lessThanValue;
                end
                if~isNonZeroPlusNumLessThan
                    if displayFactor~=1

                        val=serdes.internal.apps.serdesdesigner.BlockDialog.getNumericValue(val)*displayFactor;
                        lessThanValue=lessThanValue*displayFactor;
                    end
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:NumericEntry_GE_Message',str,nam,num2str(lessThanValue));
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end
        function isNonZeroPlusNumBetween=isNonZeroPositiveNumberBetween(nam,val,lowerLimit,upperLimit,displayFactor)
            if~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isNonZeroPositiveNumber(nam,val)
                isNonZeroPlusNumBetween=false;
            else
                if isnumeric(val)
                    isNonZeroPlusNumBetween=val>lowerLimit&&val<upperLimit;
                else
                    isNonZeroPlusNumBetween=str2double(val)>lowerLimit&&str2double(val)<upperLimit;
                end
                if~isNonZeroPlusNumBetween
                    if displayFactor~=1

                        val=serdes.internal.apps.serdesdesigner.BlockDialog.getNumericValue(val)*displayFactor;
                        lowerLimit=lowerLimit*displayFactor;
                        upperLimit=upperLimit*displayFactor;
                    end
                    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(val);
                    title=message('serdes:serdesdesigner:BadEntryTitle');
                    body=message('serdes:serdesdesigner:OutOfRangeEntryMessage2',str,nam,num2str(lowerLimit),num2str(upperLimit));
                    h=errordlg(getString(body),getString(title),'modal');
                    uiwait(h);
                end
            end
        end
    end
end
