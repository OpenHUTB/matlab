classdef(CaseInsensitiveProperties=true)MetricCheck<ModelAdvisor.Check

    properties(SetAccess=protected)
        MetricID='';
    end

    properties(Access=protected)
        MessagePrefix='';

        AggregationMode=0;
    end

    properties(Access=protected,Constant)
        MC='ModelAdvisor:metricchecks:';
    end

    methods
        function this=MetricCheck(checkID)

            mlock;
            this=this@ModelAdvisor.Check(checkID);
        end

        function setCheckInfo(this,checkInfo)


            mm=slmetric.internal.MetricManager();
            f=mm.getMetricFactory('');
            metricInfo=f.getMetricInformation(checkInfo.MetricID);

            this.MetricID=metricInfo.ID;


            this.MessagePrefix=[this.MC,checkInfo.MessagePrefix];
            this.Title=this.message('CheckTitle');
            this.TitleTips=this.message('CheckDesc');
            this.CSHParameters=checkInfo.CSHParameters;


            compileMode=metricInfo.CompileContext.char();
            this.setCallbackFcn(@(sys)(ModelAdvisor.check.metriccheck.MetricCheck.checkCallback(sys)),...
            compileMode,'StyleOne');


            if metricInfo.CompileContext==Advisor.CompileModes.None
                this.SupportLibrary=true;
            else
                this.SupportLibrary=false;
            end

            this.setLicense({'SL_Verification_Validation'});
            this.SupportHighlighting=false;
            this.SupportExclusion=false;


            if metricInfo.CompileContext==Advisor.CompileModes.None
                this.Value=true;
            else
                this.Value=false;
            end


            this.AggregationMode=metricInfo.AggregationMode;
        end
    end

    methods(Hidden)

        function[res,status,threshold,compliantArray,compCategory]=algorithm(this,system)
            status=0;
            threshold=0;
            compliantArray=[];
            compCategory=[];



            blocks=getAllBlockComponent(system);


            mm=slmetric.internal.MetricManager();
            mf=mm.getMetricFactory(slmetric.config.getActiveConfiguration());
            checkObj=mf.getMetric(this.MetricID);

            res={};
            for iBlk=1:length(blocks)
                component=blocks(iBlk);

                if ismember(component.Type,checkObj.ComponentScope)
                    resObj=checkObj.algorithm(component);
                    if~isempty(resObj)
                        resObj.ComponentPath=component.getPath();
                        res=[res,resObj];
                    end
                end
            end

            if~isempty(res)
                res=this.sortResults(res,'descend');

                compliantArray=zeros(1,length(res));



                MAPref=ModelAdvisor.Preferences();
                if(MAPref.MetricCheckThreshold)



                    metricConfig=slmetric.config.getActiveConfiguration();

                    if isempty(metricConfig)
                        metricConfig=slmetric.config.Configuration.openDefaultConfiguration();
                    else
                        metricConfig=slmetric.config.Configuration.open();
                    end

                    Th=metricConfig.getThresholdConfigurations();
                    TO=Th.getThresholds(this.MetricID);

                    if~isempty(TO)


                        CO=getClassifications(TO);
                        threshold=1;
                        idx=ismember({CO.Category},'Compliant');
                        compCategory=CO(idx);




                        idx=ismember({CO.Category},'Warning');
                        warnCategory=CO(idx);
                        for resIdx=1:length(res)
                            for iWarn=1:length(warnCategory)
                                if isInRange(warnCategory(iWarn),res(resIdx).Value)
                                    compliantArray(resIdx)=1;
                                    status=1;
                                    break
                                end
                            end
                        end


                        if~this.getInputParameters{1}.Value
                            status=0;
                        end




                        idx=ismember({CO.Category},'NonCompliant');
                        nonCompCategory=CO(idx);
                        for resIdx=1:length(res)
                            for iNonCom=1:length(nonCompCategory)
                                if isInRange(nonCompCategory(iNonCom),res(resIdx).Value)
                                    compliantArray(resIdx)=2;
                                    status=2;
                                    break
                                end
                            end
                        end
                    end

                end
            end
        end

        function out=outputFormatting(this,~,res,status,threshold,compliantArray,compCategory)
            out={};
            ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
            ft=ModelAdvisor.FormatTemplate('TableTemplate');
            ft.setCheckText(this.message('CheckDesc'));
            ft.setSubBar(0);



            MAPref=ModelAdvisor.Preferences();
            if~MAPref.MetricCheckThreshold
                ft.setSubResultStatus('Pass');
            end



            if status
                ma.setCheckResultStatus(false);
            else
                ma.setCheckResultStatus(true);
            end
            if~isempty(res)
                columns={...
                DAStudio.message([this.MC,'Component']),...
                this.message('Value'),...
                };

                ft.setColTitles(columns);


                if threshold
                    ft.SubResultStatusText=DAStudio.message('ModelAdvisor:metricchecks:CheckCompliantMsg');
                    ft.SubTitle=ModelAdvisor.Text('Compliant');
                    ft.SubTitle.Color='Pass';
                    ft.SubTitle.IsBold=true;
                    recActionText=['The count must be between ',num2str(compCategory.Range.Start),' and ',num2str(compCategory.Range.End)];
                    if compCategory.Range.IncludeStart
                        recActionText=[recActionText,', including the start value'];
                    else
                        recActionText=[recActionText,', excluding the start value'];
                    end
                    if compCategory.Range.IncludeEnd
                        recActionText=[recActionText,' and including the end value'];
                    else
                        recActionText=[recActionText,' and excluding the end value'];
                    end
                end

                if~isempty(find(compliantArray==2,1))

                    ft2=ModelAdvisor.FormatTemplate('TableTemplate');
                    ft2.setSubBar(0);
                    ft2.setColTitles(columns);
                    ft2.SubResultStatusText=DAStudio.message('ModelAdvisor:metricchecks:CheckNonCompliantMsg');
                    ft2.SubTitle=ModelAdvisor.Text('Non-Compliant');
                    ft2.SubTitle.Color='Fail';
                    ft2.SubTitle.IsBold=true;
                    ft2.RecAction=recActionText;


                    out{end+1}=ft2;
                end

                if~isempty(find(compliantArray==1,1))

                    ft1=ModelAdvisor.FormatTemplate('TableTemplate');

                    ft1.setSubBar(0);

                    ft1.setColTitles(columns);
                    ft1.SubResultStatusText=DAStudio.message('ModelAdvisor:metricchecks:CheckWarnMsg');
                    ft1.SubTitle=ModelAdvisor.Text('Warning');
                    ft1.SubTitle.Color='Warn';
                    ft1.SubTitle.IsBold=true;
                    ft1.RecAction=recActionText;


                    out{end+1}=ft1;
                end


                out{end+1}=ft;
                for n=1:length(res)
                    valueStr=num2str(res(n).Value);
                    value=ModelAdvisor.Text(valueStr);
                    value.setBold(true);
                    row={...
                    this.getComponentHyperlink(res(n)),...
                    value,...
                    };
                    if compliantArray(n)==0
                        ft.addRow(row);
                    elseif compliantArray(n)==1
                        ft1.addRow(row);
                    else
                        ft2.addRow(row);
                    end
                end
            else
                out{end+1}=ft;
                ft.setSubResultStatus('Pass');
                ft.setInformation(DAStudio.message([this.MC,...
                'NoDataAvailable']));
            end
        end
    end

    methods(Access=protected)

        function msg=message(this,id,varargin)
            if isempty(varargin)
                msg=DAStudio.message([this.MessagePrefix,'_',id]);
            else
                msg=DAStudio.message([this.MessagePrefix,id],varargin{:});
            end
        end
    end

    methods(Access=protected,Static)
        function res=sortResults(res,mode)


            compIDs={res.ComponentID};
            [~,i]=sort(compIDs);
            res=[res(i)];%#ok<NBRAK>

            values=[res.Value];
            [~,i]=sort(values,mode);
            res=[res(i)];%#ok<NBRAK>
        end

        function linktext=getComponentHyperlink(res)

            linktext=ModelAdvisor.Text(ModelAdvisor.check.metriccheck.MetricCheck.truncatePath(res.ComponentPath));

            linktext.setHyperlink(...
            slmetric.internal.getResultHyperlink(res.ComponentID));
        end

        function path=truncatePath(fullPath)
            limit=40;

            if(length(fullPath)>limit)


                slashIndex=strfind(fullPath,'/');

                if isempty(slashIndex)
                    path=['....',fullPath(end-limit+1:end)];
                else
                    truncatedPath='';
                    for i=1:length(slashIndex)
                        if length(fullPath)-slashIndex(i)<=limit
                            truncatedPath=fullPath(slashIndex(i)+1:end);
                            break
                        end
                    end

                    if isempty(truncatedPath)
                        truncatedPath=['....',fullPath(end-limit+1:end)];
                    else
                        truncatedPath=['..../',truncatedPath];
                    end

                    path=truncatedPath;
                end
            else
                path=fullPath;
            end
        end
    end

    methods(Hidden,Static)
        function ft=checkCallback(system)
            ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
            this=ma.ActiveCheck;

            [res,status,threshold,compliantArray,compCategory]=this.algorithm(system);

            ft=this.outputFormatting(system,res,status,threshold,compliantArray,compCategory);
        end
    end
end

function val=isInRange(CO,value)


    if CO.Range.IncludeStart&&CO.Range.IncludeEnd
        val=(value>=CO.Range.Start)&&(value<=CO.Range.End);
    elseif~CO.Range.IncludeStart&&CO.Range.IncludeEnd
        val=(value>CO.Range.Start)&&(value<=CO.Range.End);
    elseif CO.Range.IncludeStart&&~CO.Range.IncludeEnd
        val=(value>=CO.Range.Start)&&(value<CO.Range.End);
    else
        val=(value>CO.Range.Start)&&(value<CO.Range.End);
    end
end

function blockComp=getAllBlockComponent(system)


    blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','on');
    blocks=unique(get_param(blocks,'Parent'));
    blocks=blocks(3:end);


    maskTypes=getMaskTypes();
    blocks=blocks(~ismember(get_param(blocks,'MaskType'),maskTypes));
    blockComp=[];
    blocks=[system;blocks];
    for iblk=1:length(blocks)
        uddObj=get_param(blocks{iblk},'object');
        [slCompObj,contextObject]=Advisor.component.internal.Object2ComponentID.resolveObject(uddObj);
        component=Advisor.component.internal.ComponentFactory.createSlComponent(slCompObj,contextObject);
        blockComp=[blockComp,component];

        if isa(slCompObj,'Stateflow.Chart')
            emlBlk=uddObj.find('-isa','Stateflow.EMFunction','-and','Chart',slCompObj);
            for iEml=1:length(emlBlk)
                component=Advisor.component.internal.ComponentFactory.createSlComponent(emlBlk(iEml),contextObject);
                blockComp=[blockComp,component];
            end
        end
    end
end

function maskTypes=getMaskTypes()
    maskTypes={'Atomic Subsystem',...
    'Band-Limited White Noise.',...
    'Bit Clear',...
    'Bit Set',...
    'Bitwise Operator',...
    'Block Support Table',...
    'CMBlock',...
    'Checks_DGap',...
    'Checks_DMax',...
    'Checks_DMin',...
    'Checks_DRange',...
    'Checks_Gradient',...
    'Checks_Resolution',...
    'Checks_SGap',...
    'Checks_SMax',...
    'Checks_SMin',...
    'Checks_SRange',...
    'Code Reuse Subsystem',...
    'Compare To Constant',...
    'Compare To Zero',...
    'Conversion Inherited',...
    'Coulombic and Viscous Friction',...
    'Counter Free-Running',...
    'Counter Limited',...
    'Data Type Propagation',...
    'Data Type Propagation Examples',...
    'Dead Zone Dynamic',...
    'Decrement Time To Zero',...
    'Decrement To Zero',...
    'Detect Change',...
    'Detect Decrease',...
    'Detect Fall Negative',...
    'Detect Fall Nonpositive',...
    'Detect Increase',...
    'Detect Rise Nonnegative',...
    'Detect Rise Positive',...
    'Difference',...
    'Discrete Derivative',...
    'DocBlock',...
    'Enabled And Triggered Subsystem',...
    'Enabled Subsystem',...
    'Enumerated Constant',...
    'Environment Controller',...
    'Extract Bits',...
    'First Order Transfer Fcn',...
    'Fixed-Point State-Space',...
    'For Each Subsystem',...
    'For Iterator Subsystem',...
    'Function-Call Generator',...
    'Function-Call Subsystem',...
    'If Action Subsystem',...
    'Initialize Function Subsystem',...
    'Interval Test',...
    'Interval Test Dynamic',...
    'Lead or Lag Compensator',...
    'Lookup Table Dynamic',...
    'ManualVariantSink',...
    'ManualVariantSource',...
    'MinMax Running Resettable',...
    'PID 1dof',...
    'PID 2dof',...
    'Ramp',...
    'Rate Limiter Dynamic',...
    'Real World Value Decrement',...
    'Real World Value Increment',...
    'Repeating Sequence Interpolated',...
    'Repeating Sequence Stair',...
    'Repeating table',...
    'Reset Function Subsystem',...
    'Resettable Subsystem',...
    'Run First Subsystem',...
    'Run Last Subsystem',...
    'S-Function Builder',...
    'S-Function Examples',...
    'Saturation Dynamic',...
    'Scaling Strip',...
    'SignalEditor',...
    'Simulink Function Subsystem',...
    'Sine and Cosine',...
    'Slider Gain',...
    'Stored Integer Value Decrement',...
    'Stored Integer Value Increment',...
    'Subsystem Examples',...
    'Switch Case Action Subsystem',...
    'Tapped Delay Line',...
    'Terminate Function Subsystem',...
    'Timed Linearization',...
    'Transfer Fcn Direct Form II',...
    'Transfer Fcn Direct Form II Time Varying',...
    'Transfer Fcn Real Zero',...
    'Triggered Linearization',...
    'Triggered Subsystem',...
    'Variant Model',...
    'Variant Subsystem',...
    'Virtual Subsystem',...
    'WaveformGenerator',...
    'While Iterator Subsystem',...
    'Wrap To Zero',...
    'XY scope.',...
    'chirp'};
end
