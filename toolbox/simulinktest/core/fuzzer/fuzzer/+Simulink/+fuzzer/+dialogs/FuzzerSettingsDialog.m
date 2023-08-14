classdef FuzzerSettingsDialog < handle
    properties
       objId;
       distributionType;
       signalType;
       cauchyVarA;
       cauchyVarB;
       chiSqDegFree;
       fisherDegFreeNumerator;
       fisherDegFreeDenominator;
       gaussMean;
       gaussStddev;
       logNormM;
       logNormS;
       studentDegFree;
       uniformLow;
       uniformHigh;
       varSignalHigh;
       varSignalLow;
       squareSignalMax;
       squareSignalMin;
       squareSignalPeriod;
       squareSignalBounceVar;
       squareSignalBounceLen;
       squareSignalDCHigh;
       squareSignalDCLow;
       squareSignalDoBounce;
       signalInitVal;
       activeFuzzer;
       fuzzSeed;
       context;
       doPreview;
       jsonVals;
       clientId;
       
       distributionTypeEntries = {
            Simulink.fuzzer.internal.DistributionTypes.CAUCHY.name, ...
            Simulink.fuzzer.internal.DistributionTypes.CHISQUARED.name, ...
            Simulink.fuzzer.internal.DistributionTypes.FISHERF.name, ...
            Simulink.fuzzer.internal.DistributionTypes.GAUSSIAN.name, ...
            Simulink.fuzzer.internal.DistributionTypes.LOGNORM.name, ...
            Simulink.fuzzer.internal.DistributionTypes.STUDENTT.name, ...
            Simulink.fuzzer.internal.DistributionTypes.UNIFORM.name };
        
        distributionTypeValues = [
            Simulink.fuzzer.internal.DistributionTypes.CAUCHY.val, ...
            Simulink.fuzzer.internal.DistributionTypes.CHISQUARED.val, ...
            Simulink.fuzzer.internal.DistributionTypes.FISHERF.val, ...
            Simulink.fuzzer.internal.DistributionTypes.GAUSSIAN.val, ...
            Simulink.fuzzer.internal.DistributionTypes.LOGNORM.val, ...
            Simulink.fuzzer.internal.DistributionTypes.STUDENTT.val, ...
            Simulink.fuzzer.internal.DistributionTypes.UNIFORM.val ];
        
        signalTypeEntries = {
            Simulink.fuzzer.internal.SingalTypes.VARIABLE.name, ...
            Simulink.fuzzer.internal.SingalTypes.SQUARE.name};
        
        signalTypeValues = [
            Simulink.fuzzer.internal.SingalTypes.VARIABLE.val, ...
            Simulink.fuzzer.internal.SingalTypes.SQUARE.val ];
        
    end
    
    methods
        function this = FuzzerSettingsDialog(objId, context)
            this.context = context;
            this.objId = objId;
            this.distributionType = '0';
            this.signalType = '0';
            this.cauchyVarA = "";
            this.cauchyVarB = "";
            this.chiSqDegFree = "";
            this.fisherDegFreeNumerator = "";
            this.fisherDegFreeDenominator = "";
            this.gaussMean = "";
            this.gaussStddev = "";
            this.logNormM = "";
            this.logNormS = "";
            this.studentDegFree = "";
            this.uniformLow = "";
            this.uniformHigh = "";
            this.varSignalHigh = "";
            this.varSignalLow = "";
            this.squareSignalMax = "";
            this.squareSignalMin = "";
            this.squareSignalPeriod = "";
            this.squareSignalBounceVar = "";
            this.squareSignalBounceLen = "";
            this.squareSignalDCHigh = "";
            this.squareSignalDCLow = "";
            this.squareSignalDoBounce = true;
            this.signalInitVal = "";
            this.doPreview = true;
            this.fuzzSeed = 0;
            if this.context == Simulink.fuzzer.internal.ContextIndex.BLOCK_CONTEXT.valStr
                this.loadParams();
            end
        end
        
        function combobox = comboboxFactory(~, name, entries, values, objProp)
            combobox.Name = DAStudio.message(name);
            combobox.Type = 'combobox';
            combobox.Mode = true;
            combobox.ObjectProperty = objProp;
            combobox.DialogRefresh = true;
            combobox.Entries = entries;
            combobox.Values = values;
        end
        
        function checkbox = checkboxFactory(~, name, objProp)
            checkbox.Name = DAStudio.message(name);
            checkbox.ObjectProperty = objProp;
            checkbox.Mode = true;
            checkbox.DialogRefresh = true;
            checkbox.Type = 'checkbox';
        end
        
        function editbox = editboxFactory(~, name, objProp)
            editbox.Name = DAStudio.message(name);
            editbox.ObjectProperty = objProp;
            editbox.Mode = true;
            editbox.DialogRefresh = true;
            editbox.Type = 'edit';
        end
        
        function pushbutton = pushbuttonFactory(~, name, obMethod)
            pushbutton.Name = DAStudio.message(name);
            pushbutton.ObjectMethod = obMethod;
            pushbutton.Mode = true;
            pushbutton.DialogRefresh = true;
            pushbutton.Type = 'pushbutton';
        end
        
        function panelProperties = twoVariablePanel(this, nameStr1, objProp1, nameStr2, objProp2)
            panelProperties.LayoutGrid = [2 3];
           
            varEditBox1 = this.editboxFactory( ...
                nameStr1 , ...
                objProp1);
            varEditBox1.Tag = this.makeTag(DAStudio.message(nameStr1));
            varEditBox1.RowSpan = [1 1];
            varEditBox1.ColSpan = [1 3];
            
            varEditBox2 = this.editboxFactory( ...
               nameStr2 , ...
               objProp2);
            varEditBox2.Tag = this.makeTag(DAStudio.message(nameStr2));
            varEditBox2.RowSpan = [2 2];
            varEditBox2.ColSpan = [1 3];
            
            panelProperties.Items = {varEditBox1, varEditBox2};
            
            
        end
        
        
        function panelProperties = oneVariablePanel(this, nameStr, objProp)
            panelProperties.LayoutGrid = [1 3];
            varEditBox = this.editboxFactory( ...
                nameStr , ...
                objProp);
            varEditBox.Tag = this.makeTag(DAStudio.message(nameStr));
            varEditBox.RowSpan = [1 1];
            varEditBox.ColSpan = [1 3];
            panelProperties.Items = {varEditBox};
        end
        
        function newTag = makeTag(this, tagBase)
            newTag = tagBase + "_" + this.objId + "_" + "Tag";
        end
        
        function signalProperties = createSquareUI(this)
        
            signalProperties.LayoutGrid = [3 3];
            
            sqSigMaxBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalMax' , ...
                'squareSignalMax');
            sqSigMaxBox.Tag = this.makeTag( ...
                DAStudio.message('sltest:fuzzer:SquareSignalMax'));
            sqSigMaxBox.RowSpan = [1 1];
            sqSigMaxBox.ColSpan = [1 1];
            
            sqSigMinBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalMin' , ...
                'squareSignalMin');
            sqSigMinBox.Tag = this.makeTag( ... 
                DAStudio.message('sltest:fuzzer:SquareSignalMin'));
            sqSigMinBox.RowSpan = [1 1];
            sqSigMinBox.ColSpan = [2 2];
            
            sqSigPeriodBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalPeriod' , ...
                'squareSignalPeriod');
            sqSigPeriodBox.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:SquareSignalPeriod'));
            sqSigPeriodBox.RowSpan = [1 1];
            sqSigPeriodBox.ColSpan = [3 3];
            
            sqSigBVarBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalBounceVar' , ...
                'squareSignalBounceVar');
            sqSigBVarBox.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:SquareSignalBounceVar'));
            sqSigBVarBox.RowSpan = [2 2];
            sqSigBVarBox.ColSpan = [1 1];
            
            sqSigBLenBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalBounceLen' , ...
                'squareSignalBounceLen');
            sqSigBLenBox.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:SquareSignalBounceLen'));
            sqSigBLenBox.RowSpan = [2 2];
            sqSigBLenBox.ColSpan = [2 2];
            
            sqSigDoBonceChkBox = this.checkboxFactory(...
                'sltest:fuzzer:SquareSignalDoBounce', ...
                'squareSignalDoBounce');
            sqSigDoBonceChkBox.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:SquareSignalDoBounce'));
            sqSigDoBonceChkBox.RowSpan = [2 2];
            sqSigDoBonceChkBox.ColSpan = [3 3];
            
            sqSigDCHighBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalDCHigh' , ...
                'squareSignalDCHigh');
            sqSigDCHighBox.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:SquareSignalDCHigh'));
            sqSigDCHighBox.RowSpan = [3 3];
            sqSigDCHighBox.ColSpan = [1 1];
            
            sqSigDCLowBox = this.editboxFactory( ...
                'sltest:fuzzer:SquareSignalDCLow' , ...
                'squareSignalDCLow');
            sqSigDCLowBox.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:SquareSignalDCLow'));
            sqSigDCLowBox.RowSpan = [3 3];
            sqSigDCLowBox.ColSpan = [2 2];
            
            
            
            signalProperties.Items = {sqSigMaxBox, sqSigMinBox, ...
                                      sqSigPeriodBox, sqSigBVarBox, ... 
                                      sqSigBLenBox, sqSigDCHighBox, ...
                                      sqSigDCLowBox, sqSigDoBonceChkBox};
    
        end
        
        function distroProperties = getDistroProperties(this)
            switch(this.distributionType)
                case Simulink.fuzzer.internal.DistributionIndex.CAUCHY_DISTRO.valStr
                    distroProperties = this.twoVariablePanel(... 
                        'sltest:fuzzer:CauchyVarA', ...
                        'cauchyVarA', ...
                        'sltest:fuzzer:CauchyVarB', ...
                        'cauchyVarB');
                case Simulink.fuzzer.internal.DistributionIndex.CHISQUARED_DISTRO.valStr
                    distroProperties = this.oneVariablePanel(...
                        'sltest:fuzzer:ChiSqDegFree', ...
                        'chiSqDegFree');
                case Simulink.fuzzer.internal.DistributionIndex.FISHERF_DISTRO.valStr
                    distroProperties = this.twoVariablePanel(... 
                        'sltest:fuzzer:FisherDegFreeNumerator', ...
                        'fisherDegFreeNumerator', ...
                        'sltest:fuzzer:FisherDegFreeDenominator', ...
                        'fisherDegFreeDenominator');
                case Simulink.fuzzer.internal.DistributionIndex.GAUSSIAN_DISTRO.valStr
                    distroProperties = this.twoVariablePanel(... 
                        'sltest:fuzzer:GaussMean', ...
                        'gaussMean', ...
                        'sltest:fuzzer:GaussStddev', ...
                        'gaussStddev');
                case Simulink.fuzzer.internal.DistributionIndex.LOGNORM_DISTRO.valStr
                    distroProperties = this.twoVariablePanel(... 
                        'sltest:fuzzer:LogNormM', ...
                        'logNormM', ...
                        'sltest:fuzzer:LogNormS', ...
                        'logNormS');
                case Simulink.fuzzer.internal.DistributionIndex.STUDENTT_DISTRO.valStr
                    distroProperties = this.oneVariablePanel(...
                        'sltest:fuzzer:StudentDegFree', ...
                        'studentDegFree');
                case Simulink.fuzzer.internal.DistributionIndex.UNIFORM_DISTRO.valStr
                    distroProperties = this.twoVariablePanel(... 
                        'sltest:fuzzer:UniformLow', ...
                        'uniformLow', ...
                        'sltest:fuzzer:UniformHigh', ...
                        'uniformHigh');
            end
            distroProperties.Name = DAStudio.message( ...
                'sltest:fuzzer:DistroProp');
            distroProperties.Type = 'group';
            distroProperties.Tag = this.makeTag(DAStudio.message( ...
                'sltest:fuzzer:DistributionPropTag'));
        end
        
        function signalProperties = getSignalProperties(this)
            switch(this.signalType)
                case Simulink.fuzzer.internal.SingalIndex.VARIABLE_SIGNAL.valStr
                    signalProperties = this.twoVariablePanel(...
                        'sltest:fuzzer:VarSignalLow', ...
                        'varSignalLow', ...
                        'sltest:fuzzer:VarSignalHigh', ...
                        'varSignalHigh');
                case Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.valStr
                    signalProperties = this.createSquareUI();
            end
            
            signalProperties.Name = DAStudio.message('sltest:fuzzer:SigProp');
            signalProperties.Type = 'group';
            signalProperties.Tag = this.makeTag( ...
                DAStudio.message('sltest:fuzzer:SignalPropTag'));
        end
        
        function genSeed(this)
            this.fuzzSeed = num2str(randi(65536));
        end
        
        function schema = getDialogSchema(this)
            schema.DialogTitle = DAStudio.message('sltest:fuzzer:DialogTitle');
            schema.DialogTag = this.makeTag( ... 
                DAStudio.message('sltest:fuzzer:FuzzerSchemeTag'));
            
            % signal type drop down
            sigTypeList = this.comboboxFactory('sltest:fuzzer:SigType', ...
                this.signalTypeEntries, this.signalTypeValues, ...
                'signalType');
            
            sigTypeList.Tag = this.makeTag( ... 
                DAStudio.message('sltest:fuzzer:SignalTypeTag'));
            
            sigTypeList.RowSpan = [1 1];
            sigTypeList.ColSpan = [1 2];
            
            if this.signalType ~= Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.valStr
            
                % Distribution type drop down

                distroTypeList = this.comboboxFactory( ... 
                    'sltest:fuzzer:DistroType', ...
                     this.distributionTypeEntries, ... 
                     this.distributionTypeValues, ...
                    'distributionType');


                distroTypeList.Tag = this.makeTag( ... 
                    DAStudio.message('sltest:fuzzer:DistributionTypeTag'));

                distroTypeList.RowSpan = [1 1];
                distroTypeList.ColSpan = [3 4];
            end
            
            
            % signal properties panel
            sigProperties = this.getSignalProperties();
            sigProperties.RowSpan = [2 4];
            sigProperties.ColSpan = [1 2];
            if this.signalType ~= Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.valStr
                % distribution properties panel
                distroProperties = this.getDistroProperties();
                distroProperties.RowSpan = [2 3];
                distroProperties.ColSpan = [3 4];
            end
            
            if this.signalType ~= Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.valStr
                initValEditBox = this.editboxFactory(...
                    'sltest:fuzzer:SignalInitVal', ...
                    'signalInitVal');
                initValEditBox.Tag = this.makeTag(DAStudio.message('sltest:fuzzer:SigInitValTag'));
                initValEditBox.RowSpan = [5 5];
                initValEditBox.ColSpan = [1 1];
            end
            
            % seed
            seedBox = this.editboxFactory( ...
                'sltest:fuzzer:Seed' , ...
                'fuzzSeed');
            seedBox.Tag = this.makeTag(DAStudio.message('sltest:fuzzer:SeedTag'));
            seedBox.RowSpan = [1 1];
            seedBox.ColSpan = [5 5];
            
            doPreviewChkBox = this.checkboxFactory(...
                'sltest:fuzzer:DoPreview', 'doPreview');
            doPreviewChkBox.Tag = this.makeTag(DAStudio.message('sltest:fuzzer:DoPreviewTag'));
            doPreviewChkBox.RowSpan = [3 3];
            doPreviewChkBox.ColSpan = [5 5];
            
            genNewSeedBtn = this.pushbuttonFactory('sltest:fuzzer:GenNewSeed', 'genSeed');
            genNewSeedBtn.Tag = this.makeTag(DAStudio.message('sltest:fuzzer:GenNewSeedTag'));
            genNewSeedBtn.RowSpan = [2 2];
            genNewSeedBtn.ColSpan = [5 5];
            
            
            % create panel for all of the elements
            panel.Type = 'panel';
            panel.LayoutGrid  = [7 5];
            if this.signalType ~= Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.valStr
                panel.Items = {initValEditBox, seedBox, sigTypeList,  ...
                                distroTypeList, distroProperties, ...
                                sigProperties, doPreviewChkBox, ... 
                                genNewSeedBtn}; 
            else
                panel.Items = {seedBox, sigTypeList, sigProperties, ...
                                doPreviewChkBox, genNewSeedBtn}; 
            end
            
            schema.Items = {panel};
            schema.CloseMethod = '';
            
            schema.PostApplyMethod = 'saveParams';
            schema.PostApplyArgs   = {'%dialog'};
            schema.PostApplyArgsDT = {'handle'};

            schema.HelpMethod = '';
            
            schema.StandaloneButtonSet = {'OK', 'Cancel', 'Help'};
        end
        
        function show(~, dlg)
            dlg.show();
        end
        
        function fInfo = getParams(this, ~)
            fInfo.distributionType = str2double(this.distributionType);
            fInfo.signalType = str2double(this.signalType);
            fInfo.objId = this.objId;
            fInfo.fuzzSeed = str2double(this.fuzzSeed);
            fInfo.signalInitVal = str2double(this.signalInitVal);
            if this.doPreview
                fInfo.doPreview = "1";
            else
                fInfo.doPreview = "0";
            end
            switch(this.distributionType)
                case Simulink.fuzzer.internal.DistributionIndex.CAUCHY_DISTRO.valStr
                    fInfo.cauchyVarA = str2double(this.cauchyVarA);
                    fInfo.cauchyVarB = str2double(this.cauchyVarB);
                case Simulink.fuzzer.internal.DistributionIndex.CHISQUARED_DISTRO.valStr
                    fInfo.chiSqDegFree = str2double(this.chiSqDegFree);
                case Simulink.fuzzer.internal.DistributionIndex.FISHERF_DISTRO.valStr
                    fInfo.fisherDegFreeNumerator = str2double(this.fisherDegFreeNumerator);
                    fInfo.fisherDegFreeDenominator = str2double(this.fisherDegFreeDenominator);
                case Simulink.fuzzer.internal.DistributionIndex.GAUSSIAN_DISTRO.valStr
                    fInfo.gaussMean = str2double(this.gaussMean);
                    fInfo.gaussStddev = str2double(this.gaussStddev);
                case Simulink.fuzzer.internal.DistributionIndex.LOGNORM_DISTRO.valStr
                    fInfo.logNormM = str2double(this.logNormM);
                    fInfo.logNormS = str2double(this.logNormS);
                case Simulink.fuzzer.internal.DistributionIndex.GAUSSIAN_DISTRO.valStr
                    fInfo.logNormM = str2double(this.logNormM);
                    fInfo.logNormS = str2double(this.logNormS);
                case Simulink.fuzzer.internal.DistributionIndex.STUDENTT_DISTRO.valStr
                    fInfo.studentDegFree = str2double(this.studentDegFree);
                case Simulink.fuzzer.internal.DistributionIndex.UNIFORM_DISTRO.valStr
                    fInfo.uniformLow = str2double(this.uniformLow);
                    fInfo.uniformHigh = str2double(this.uniformHigh);
            end
            switch(this.signalType)
                case Simulink.fuzzer.internal.SingalIndex.VARIABLE_SIGNAL.valStr
                    fInfo.varSignalLow = str2double(this.varSignalLow);
                    fInfo.varSignalHigh = str2double(this.varSignalHigh);
                case Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.valStr
                    fInfo.squareSignalMax = str2double(this.squareSignalMax);
                    fInfo.squareSignalMin = str2double(this.squareSignalMin);
                    fInfo.squareSignalPeriod = str2double(this.squareSignalPeriod);
                    fInfo.squareSignalBounceVar = str2double(this.squareSignalBounceVar);
                    fInfo.squareSignalBounceLen = str2double(this.squareSignalBounceLen);
                    fInfo.squareSignalDCHigh = str2double(this.squareSignalDCHigh);
                    fInfo.squareSignalDCLow = str2double(this.squareSignalDCLow);
                    fInfo.squareSignalDoBounce = str2double(this.squareSignalDoBounce);
            end
        end
        
        function ts = createTimeSeries(this, fInfo, len, ~)
            this.jsonVals = jsonencode(fInfo);
            raw_data = Simulink.fuzzer.internal.getFuzzerTimeSeries(fInfo, len);
            ts = timeseries(raw_data, 0:length(raw_data) - 1);
        end
        
        function plotPreviewSignal(this, fInfo, ~)
            if this.doPreview == 1
                ts = this.createTimeSeries(fInfo, 100);
                plot(ts);
                title('Preview Signal')
                xlabel('Time (timesteps)')
                ylabel('Signal value')
                % set(gcf, 'units', 'normalized');
                set(gcf, 'Position', [150, 990, 1500, 300]);
                % save('times.mat', "ts");
            end
        end
        
        function saveParams(this, ~)
            fInfo = this.getParams();
            switch(this.context)
                case Simulink.fuzzer.internal.ContextIndex.BLOCK_CONTEXT.valStr
                    Simulink.fuzzer.internal.saveFuzzerParameters(fInfo);
                case Simulink.fuzzer.internal.ContextIndex.ASSESSMENT_CONTEXT.valStr
                    message.publish(['/Assessments/' this.clientId '/fuzzerMainCallBack'], fInfo);
            end
            this.plotPreviewSignal(fInfo)
        end
        
        
        function loadParams(this)
            outInfo.distributionType = str2double(this.distributionType);
            outInfo.objId = this.objId;
            outInfo.fuzzSeed = str2double(this.fuzzSeed);
            fInfo = Simulink.fuzzer.internal.getFuzzerParameters(outInfo);
            this.assignParams(fInfo)
        end
        
        
        function assignParams(this, fInfo) 
            if ~isempty(fInfo)
                switch(this.context)
                    case Simulink.fuzzer.internal.ContextIndex.BLOCK_CONTEXT.valStr
                        this.clientId = "None";
                    case Simulink.fuzzer.internal.ContextIndex.ASSESSMENT_CONTEXT.valStr
                        this.clientId = fInfo.clientId;
                end
                if ~isempty(fInfo.distributionType)
                    this.distributionType = fInfo.distributionType;
                end
                if ~isempty(fInfo.signalType)
                    this.signalType = fInfo.signalType;
                end
                if ~isempty(fInfo.cauchyVarA)
                    this.cauchyVarA = fInfo.cauchyVarA;
                end
                if ~isempty(fInfo.cauchyVarB)
                    this.cauchyVarB = fInfo.cauchyVarB;
                end
                if ~isempty(fInfo.chiSqDegFree)
                    this.chiSqDegFree = fInfo.chiSqDegFree;
                end
                if ~isempty(fInfo.fisherDegFreeNumerator)
                    this.fisherDegFreeNumerator = fInfo.fisherDegFreeNumerator;
                end
                if ~isempty(fInfo.fisherDegFreeDenominator)
                    this.fisherDegFreeDenominator = fInfo.fisherDegFreeDenominator;
                end
                if ~isempty(fInfo.gaussMean)
                    this.gaussMean = fInfo.gaussMean;
                end
                if ~isempty(fInfo.gaussStddev)
                    this.gaussStddev = fInfo.gaussStddev;
                end
                if ~isempty(fInfo.logNormM)
                    this.logNormM = fInfo.logNormM;
                end
                if ~isempty(fInfo.logNormS)
                    this.logNormS = fInfo.logNormS;
                end
                if ~isempty(fInfo.studentDegFree)
                    this.studentDegFree = fInfo.studentDegFree;
                end
                if ~isempty(fInfo.uniformLow)
                    this.uniformLow = fInfo.uniformLow;
                end
                if ~isempty(fInfo.uniformHigh)
                    this.uniformHigh = fInfo.uniformHigh;
                end
                if ~isempty(fInfo.varSignalHigh)
                    this.varSignalHigh = fInfo.varSignalHigh;
                end
                if ~isempty(fInfo.varSignalLow)
                    this.varSignalLow = fInfo.varSignalLow;
                end
                if ~isempty(fInfo.squareSignalMax)
                    this.squareSignalMax = fInfo.squareSignalMax;
                end
                if ~isempty(fInfo.squareSignalMin)
                    this.squareSignalMin = fInfo.squareSignalMin;
                end
                if ~isempty(fInfo.squareSignalPeriod)
                    this.squareSignalPeriod = fInfo.squareSignalPeriod;
                end
                if ~isempty(fInfo.squareSignalBounceVar)
                    this.squareSignalBounceVar = fInfo.squareSignalBounceVar;
                end
                if ~isempty(fInfo.squareSignalBounceLen)
                    this.squareSignalBounceLen = fInfo.squareSignalBounceLen;
                end
                if ~isempty(fInfo.squareSignalDCHigh)
                    this.squareSignalDCHigh = fInfo.squareSignalDCHigh;
                end
                if ~isempty(fInfo.squareSignalDCLow)
                    this.squareSignalDCLow = fInfo.squareSignalDCLow;
                end
                if ~isempty(fInfo.squareSignalDoBounce)
                    this.squareSignalDoBounce = fInfo.squareSignalDoBounce;
                end
                if ~isempty(fInfo.signalInitVal)
                    this.signalInitVal = fInfo.signalInitVal;
                end
                if ~isempty(fInfo.fuzzSeed)
                    this.fuzzSeed = fInfo.fuzzSeed;
                end
            end
        end

        % need this and getPropDataType to get varables
        function setPropValue(obj, varName, varVal)
            if strcmp(varName, 'distributionType')
                obj.distributionType = varVal;
            elseif strcmp(varName, 'signalType')
                obj.signalType = varVal;
            elseif strcmp(varName, 'cauchyVarA')
                obj.cauchyVarA = varVal;
            elseif strcmp(varName, 'cauchyVarB')
                obj.cauchyVarB = varVal;
            elseif strcmp(varName, 'chiSqDegFree')
                obj.chiSqDegFree = varVal;
            elseif strcmp(varName, 'fisherDegFreeNumerator')
                obj.fisherDegFreeNumerator = varVal;
            elseif strcmp(varName, 'fisherDegFreeDenominator')
                obj.fisherDegFreeDenominator = varVal;
            elseif strcmp(varName, 'gaussMean')
                obj.gaussMean = varVal;
            elseif strcmp(varName, 'gaussStddev')
                obj.gaussStddev = varVal;
            elseif strcmp(varName, 'logNormM')
                obj.logNormM = varVal;
            elseif strcmp(varName, 'logNormS')
                obj.logNormS = varVal;
            elseif strcmp(varName, 'studentDegFree')
                obj.studentDegFree = varVal;
            elseif strcmp(varName, 'uniformLow')
                obj.uniformLow = varVal;
            elseif strcmp(varName, 'uniformHigh')
                obj.uniformHigh = varVal;
            elseif strcmp(varName, 'varSignalHigh')
                obj.varSignalHigh = varVal;
            elseif strcmp(varName, 'varSignalLow')
                obj.varSignalLow = varVal;
            elseif strcmp(varName, 'squareSignalMax')
                obj.squareSignalMax = varVal;
            elseif strcmp(varName, 'squareSignalMin')
                obj.squareSignalMin = varVal;
            elseif strcmp(varName, 'squareSignalPeriod')
                obj.squareSignalPeriod = varVal;
            elseif strcmp(varName, 'squareSignalBounceVar')
                obj.squareSignalBounceVar = varVal;
            elseif strcmp(varName, 'squareSignalBounceLen')
                obj.squareSignalBounceLen = varVal;
            elseif strcmp(varName, 'squareSignalDCHigh')
                obj.squareSignalDCHigh = varVal;
            elseif strcmp(varName, 'squareSignalDCLow')
                obj.squareSignalDCLow = varVal;
            elseif strcmp(varName, 'squareSignalDoBounce')
                obj.squareSignalDoBounce = varVal;
            elseif strcmp(varName, 'signalInitVal')
                obj.signalInitVal = varVal;
            elseif strcmp(varName, 'fuzzSeed')
                obj.fuzzSeed = varVal;
            elseif strcmp(varName, 'doPreview')
                obj.doPreview = varVal;
            DAStudio.Protocol.setPropValue(obj, varName, varVal);
            end
        end
        
        % need this and setPropValue to get varables
        function varType = getPropDataType(this, varName) %#ok
            switch(varName)
                case {'distributionType', ...
                      'signalType', ...
                      'cauchyVarA', ...
                      'cauchyVarB', ...
                      'chiSqDegFree', ...
                      'fisherDegFreeNumerator', ...
                      'fisherDegFreeDenominator', ...
                      'gaussMean', ...
                      'gaussStddev', ...
                      'logNormM', ...
                      'logNormS', ...
                      'studentDegFree', ...
                      'uniformLow', ...
                      'uniformHigh', ...
                      'varSignalHigh', ...
                      'varSignalLow', ...
                      'squareSignalMax', ...
                      'squareSignalMin', ...
                      'squareSignalPeriod', ...
                      'squareSignalBounceVar', ...
                      'squareSignalBounceLen', ...
                      'squareSignalDCHigh', ...
                      'squareSignalDCLow', ...
                      'signalInitVal', ...
                      'fuzzSeed'
                      }
                    varType = 'double';
                 case {'doPreview', ...
                       'squareSignalDoBounce'}
                    varType = 'bool';
                otherwise
                    varType = 'other';
            end
        end
        
    end
    
    methods(Static)  
        function create(objId, context, ~)
            if context == Simulink.fuzzer.internal.ContextIndex.BLOCK_CONTEXT.valStr
                bSID = Simulink.ID.getSID(objId);
                dlg = Simulink.fuzzer.dialogs.findDialog(bSID);
            elseif context == Simulink.fuzzer.internal.ContextIndex.ASSESSMENT_CONTEXT.valStr
                dlg = Simulink.fuzzer.dialogs.findDialog(objId);
            end
                
            if ~isempty(dlg)
                dlg.show()
                return;
            else
                import Simulink.fuzzer.dialogs.FuzzerSettingsDialog;
                src = FuzzerSettingsDialog(objId, context);
                dlg = DAStudio.Dialog(src);
                src.show(dlg);
            end
        end
        
        function ts = createFuzzerTimeSeries(objId, fInfo, len)
            import Simulink.fuzzer.dialogs.FuzzerSettingsDialog;
            src = FuzzerSettingsDialog(objId, Simulink.fuzzer.internal.ContextIndex.ASSESSMENT_CONTEXT.valStr);
            ts = src.createTimeSeries(fInfo, len);
        end
        
        function createNoBlock(objId, context, fInfo, ~)
            if context == Simulink.fuzzer.internal.ContextIndex.BLOCK_CONTEXT.valStr
                bSID = Simulink.ID.getSID(objId);
                dlg = Simulink.fuzzer.dialogs.findDialog(bSID);
            elseif context == Simulink.fuzzer.internal.ContextIndex.ASSESSMENT_CONTEXT.valStr
                dlg = Simulink.fuzzer.dialogs.findDialog(objId);
            end
                
            if ~isempty(dlg)
                dlg.show()
                return;
            else
                import Simulink.fuzzer.dialogs.FuzzerSettingsDialog;
                src = FuzzerSettingsDialog(objId, context);
                src.assignParams(fInfo);
                dlg = DAStudio.Dialog(src);
                src.show(dlg);
            end
        
        end
    end
end
