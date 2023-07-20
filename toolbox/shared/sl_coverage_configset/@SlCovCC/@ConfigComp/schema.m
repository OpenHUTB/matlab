function schema






    mlock;
    pk=findpackage('SlCovCC');
    parentcls=findclass(findpackage('Simulink'),'CustomCC');
    c=schema.class(pk,'ConfigComp',parentcls);

    visibility='on';
    privateVisibility='off';







    p=schema.prop(c,'CovEnable','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;

    p=schema.prop(c,'CovScope','SlCovCC.CovScopeEnum');
    p.FactoryValue='EntireSystem';
    p.Visible=visibility;
    p.SetFunction=@locSetCovScope;
    p.GetFunction=@locGetCovScope;

    p=schema.prop(c,'CovIncludeTopModel','slbool');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=schema.prop(c,'RecordCoverage','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetRecordCoverage;
    p.GetFunction=@locGetRecordCoverage;

    p=schema.prop(c,'CovPath','ustring');
    p.FactoryValue='/';
    p.Visible=visibility;
    p.SetFunction=@locSetCovPath;

    p=schema.prop(c,'CovSaveName','ustring');
    p.FactoryValue='covdata';
    p.Visible=visibility;

    p=schema.prop(c,'CovCompData','ustring');
    p.FactoryValue='';
    p.Visible=visibility;

    p=schema.prop(c,'CovMetricSettings','ustring');
    p.FactoryValue='dwe';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricSettings;

    p=schema.prop(c,'CovFilter','ustring');
    p.FactoryValue='';
    p.Visible=visibility;


    p=schema.prop(c,'CovHTMLOptions','ustring');
    p.FactoryValue='';
    p.Visible=visibility;

    p=schema.prop(c,'CovNameIncrementing','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;

    p=Simulink.TargetCCProperty(c,'CovFileNameIncrementing','slbool');

    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='on';
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=Simulink.TargetCCProperty(c,'CovHtmlReporting','slbool');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='off';
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovForceBlockReductionOff','slbool');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=Simulink.TargetCCProperty(c,'CovEnableCumulative','slbool');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=schema.prop(c,'CovSaveCumulativeToWorkspaceVar','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;

    p=schema.prop(c,'CovSaveSingleToWorkspaceVar','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;


    p=schema.prop(c,'CovCumulativeVarName','ustring');
    p.FactoryValue='covCumulativeData';
    p.Visible=visibility;

    p=schema.prop(c,'CovCumulativeReport','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;

    p=Simulink.TargetCCProperty(c,'CovSaveOutputData','slbool');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=Simulink.TargetCCProperty(c,'CovOutputDir','ustring');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='slcov_output/$ModelName$';
    p.Visible=visibility;

    p=Simulink.TargetCCProperty(c,'CovDataFileName','ustring');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='$ModelName$_cvdata';
    p.Visible=visibility;

    p=Simulink.TargetCCProperty(c,'CovShowResultsExplorer','slbool');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='off';
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovReportOnPause','slbool');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=schema.prop(c,'CovModelRefEnable','ustring');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovModelRefEnable;
    p.GetFunction=@locGetCovModelRefEnable;


    p=schema.prop(c,'CovModelRefExcluded','ustring');
    p.FactoryValue='';
    p.Visible=visibility;

    p=schema.prop(c,'CovExternalEMLEnable','slbool');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=schema.prop(c,'CovSFcnEnable','slbool');
    p.FactoryValue='on';
    p.Visible=visibility;

    p=schema.prop(c,'CovBoundaryAbsTol','double');
    p.FactoryValue=10e-6;
    p.Visible=visibility;

    p=schema.prop(c,'CovBoundaryRelTol','double');
    p.FactoryValue=10e-3;
    p.Visible=visibility;

    p=schema.prop(c,'CovUseTimeInterval','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;

    p=schema.prop(c,'CovStartTime','double');
    p.FactoryValue=0;
    p.Visible=visibility;

    p=schema.prop(c,'CovStopTime','double');
    p.FactoryValue=0;
    p.Visible=visibility;


    p=schema.prop(c,'CovMetricStructuralLevel','SlCovCC.CovMetricStructuralLevelEnum');
    p.FactoryValue='Decision';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricStructuralLevel;
    p.GetFunction=@locGetCovMetricStructuralLevel;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMetricLookupTable','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricLookupTable;
    p.GetFunction=@locGetCovMetricLookupTable;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMetricSignalRange','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricSignalRange;
    p.GetFunction=@locGetCovMetricSignalRange;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMetricSignalSize','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricSignalSize;
    p.GetFunction=@locGetCovMetricSignalSize;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMetricObjectiveConstraint','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricObjectiveConstraint;
    p.GetFunction=@locGetCovMetricObjectiveConstraint;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMetricSaturateOnIntegerOverflow','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricSaturateOnIntegerOverflow;
    p.GetFunction=@locGetCovMetricSaturateOnIntegerOverflow;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMetricRelationalBoundary','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovMetricRelationalBoundary;
    p.GetFunction=@locGetCovMetricRelationalBoundary;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovLogicBlockShortCircuit','slbool');
    p.FactoryValue='off';
    p.Visible=visibility;
    p.SetFunction=@locSetCovLogicBlockShortCircuit;
    p.GetFunction=@locGetCovLogicBlockShortCircuit;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovUnsupportedBlockWarning','slbool');
    p.FactoryValue='on';
    p.Visible=visibility;
    p.SetFunction=@locSetCovUnsupportedBlockWarning;
    p.GetFunction=@locGetCovUnsupportedBlockWarning;
    p.AccessFlags.Serialize='off';

    p=Simulink.TargetCCProperty(c,'CovHighlightResults','slbool');
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    p.FactoryValue='off';
    p.Visible=privateVisibility;
    p.SetFunction=@locSetCovHighlightResults;
    p.GetFunction=@locGetCovHighlightResults;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovMcdcMode','SlCovCC.CovMcdcModeEnum');
    p.FactoryValue='Masking';
    p.Visible='on';
    p.AccessFlags.Serialize='on';

    p=schema.prop(c,'CovAccelSimSupport','slbool');
    p.FactoryValue='off';
    p.Visible='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovExcludeInactiveVariants','slbool');
    p.FactoryValue='off';
    p.Visible='on';
    p.AccessFlags.Serialize='on';





    p=schema.prop(c,'slcovccListener','handle.listener vector');
    p.Visible=privateVisibility;
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'modelH','double');
    p.Visible='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'m_covMdlRefSelUIH','mxArray');
    p.Visible=privateVisibility;
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'CovIncludeRefModels','ustring');
    p.Visible=privateVisibility;
    p.FactoryValue='on';
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'m_CovPathActive','bool');
    p.Visible=privateVisibility;
    p.FactoryValue=false;
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.Serialize='off';





    m=schema.method(c,'isVisible');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(c,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};

    m=schema.method(c,'setCovPathStatus');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={};

    m=schema.method(c,'covScopeChangeCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(c,'parentCloseCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};



    m=schema.method(c,'postLoadCallback','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={};

    m=schema.method(c,'isDialogFeatureOn','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={'bool'};


    function newVal=locSetCovScope(this,newVal)
        switch newVal
        case 'EntireSystem'
            this.CovIncludeTopModel='on';
            this.CovIncludeRefModels='on';
            this.m_CovPathActive=false;
            this.CovPath='/';
            val=0;
        case 'ReferencedModels'
            this.CovIncludeRefModels='filtered';
            this.m_CovPathActive=false;
            this.CovPath='/';
            val=1;
        case 'Subsystem'
            this.CovIncludeTopModel='on';
            this.CovIncludeRefModels='off';
            this.m_CovPathActive=true;
            val=2;
        end
        this.covScopeChangeCallback(val);

        function covScope=locGetCovScope(this,storedVal)%#ok<INUSD>
            if strcmpi(this.CovIncludeTopModel,'on')&&this.m_CovPathActive
                covScope='Subsystem';
            elseif strcmpi(this.CovIncludeTopModel,'on')&&any(strcmpi(this.CovIncludeRefModels,{'on','all'}))
                covScope='EntireSystem';
            else
                covScope='ReferencedModels';
            end


            function newVal=locSetRecordCoverage(this,newVal)
                this.CovIncludeTopModel=newVal;


                if all(strcmpi({newVal,this.CovModelRefEnable},'off'))
                    this.CovEnable='off';
                else



                    this.CovIncludeRefModels=this.CovModelRefEnable;
                    this.CovEnable='on';
                end

                function recordCoverage=locGetRecordCoverage(this,storedVal)%#ok<INUSD>
                    if strcmpi(this.CovEnable,'off')
                        recordCoverage='off';
                    else
                        recordCoverage=this.CovIncludeTopModel;
                    end

                    function newVal=locSetCovModelRefEnable(this,newVal)



                        if strcmpi(this.CovModelRefEnable,newVal)
                            return;
                        end

                        this.CovIncludeRefModels=newVal;


                        if all(strcmpi({this.RecordCoverage,newVal},'off'))
                            this.CovEnable='off';
                        else



                            this.CovIncludeTopModel=this.RecordCoverage;
                            this.CovEnable='on';
                        end

                        function covModelRefEnable=locGetCovModelRefEnable(this,storedVal)%#ok<INUSD>
                            if strcmpi(this.CovEnable,'off')...
                                &&~strcmpi(this.CovIncludeRefModels,'off')
                                covModelRefEnable='off';
                            else
                                covModelRefEnable=this.CovIncludeRefModels;
                            end

                            function newVal=locSetCovPath(this,newVal)
                                this.m_CovPathActive=~strcmpi(newVal,'/');



                                function newVal=locSetCovMetricSettings(~,proposedVal)
                                    newVal=regexprep(proposedVal,'c','cd');
                                    newVal=regexprep(newVal,'m','mcd');
                                    newVal=locSortCovMetricSettings(newVal);

                                    function newVal=locSetCovMetricStructuralLevel(this,newVal)
                                        switch newVal
                                        case 'BlockExecution'
                                            metricCode='';
                                        case 'Decision'
                                            metricCode='d';
                                        case 'ConditionDecision'
                                            metricCode='cd';
                                        case 'MCDC'
                                            metricCode='mcd';
                                        end
                                        covMetricSettings=regexprep(this.covMetricSettings,'[mcd]','');
                                        this.covMetricSettings=locSortCovMetricSettings([covMetricSettings,metricCode]);

                                        function newVal=locSetCovMetricLookupTable(this,newVal)
                                            metricCode='t';
                                            addToString=strcmpi(newVal,'on');
                                            locEditCovMetricSettings(this,metricCode,addToString)
                                            function newVal=locSetCovMetricSignalRange(this,newVal)
                                                metricCode='r';
                                                addToString=strcmpi(newVal,'on');
                                                locEditCovMetricSettings(this,metricCode,addToString)
                                                function newVal=locSetCovMetricSignalSize(this,newVal)
                                                    metricCode='z';
                                                    addToString=strcmpi(newVal,'on');
                                                    locEditCovMetricSettings(this,metricCode,addToString)
                                                    function newVal=locSetCovMetricObjectiveConstraint(this,newVal)
                                                        metricCode='o';
                                                        addToString=strcmpi(newVal,'on');
                                                        locEditCovMetricSettings(this,metricCode,addToString)
                                                        function newVal=locSetCovMetricSaturateOnIntegerOverflow(this,newVal)
                                                            metricCode='i';
                                                            addToString=strcmpi(newVal,'on');
                                                            locEditCovMetricSettings(this,metricCode,addToString)
                                                            function newVal=locSetCovMetricRelationalBoundary(this,newVal)
                                                                metricCode='b';
                                                                addToString=strcmpi(newVal,'on');
                                                                locEditCovMetricSettings(this,metricCode,addToString)
                                                                function newVal=locSetCovLogicBlockShortCircuit(this,newVal)
                                                                    metricCode='s';
                                                                    addToString=strcmpi(newVal,'on');
                                                                    locEditCovMetricSettings(this,metricCode,addToString)
                                                                    function newVal=locSetCovUnsupportedBlockWarning(this,newVal)
                                                                        metricCode='w';
                                                                        addToString=strcmpi(newVal,'on');
                                                                        locEditCovMetricSettings(this,metricCode,addToString)
                                                                        function newVal=locSetCovHighlightResults(this,newVal)
                                                                            metricCode='e';
                                                                            addToString=strcmpi(newVal,'off');
                                                                            locEditCovMetricSettings(this,metricCode,addToString)



                                                                            function returnVal=locGetCovMetricStructuralLevel(this,storedVal)%#ok<INUSD>
                                                                                if any('m'==this.CovMetricSettings)
                                                                                    returnVal='MCDC';
                                                                                elseif any('c'==this.CovMetricSettings)
                                                                                    returnVal='ConditionDecision';
                                                                                elseif any('d'==this.CovMetricSettings)
                                                                                    returnVal='Decision';
                                                                                else
                                                                                    returnVal='BlockExecution';
                                                                                end

                                                                                function returnVal=locGetCovMetricLookupTable(this,storedVal)%#ok<INUSD>
                                                                                    if any('t'==this.CovMetricSettings)
                                                                                        returnVal='on';
                                                                                    else
                                                                                        returnVal='off';
                                                                                    end

                                                                                    function returnVal=locGetCovMetricSignalRange(this,storedVal)%#ok<INUSD>
                                                                                        if any('r'==this.CovMetricSettings)
                                                                                            returnVal='on';
                                                                                        else
                                                                                            returnVal='off';
                                                                                        end

                                                                                        function returnVal=locGetCovMetricSignalSize(this,storedVal)%#ok<INUSD>
                                                                                            if any('z'==this.CovMetricSettings)
                                                                                                returnVal='on';
                                                                                            else
                                                                                                returnVal='off';
                                                                                            end

                                                                                            function returnVal=locGetCovMetricObjectiveConstraint(this,storedVal)%#ok<INUSD>
                                                                                                if any('o'==this.CovMetricSettings)
                                                                                                    returnVal='on';
                                                                                                else
                                                                                                    returnVal='off';
                                                                                                end

                                                                                                function returnVal=locGetCovMetricSaturateOnIntegerOverflow(this,storedVal)%#ok<INUSD>
                                                                                                    if any('i'==this.CovMetricSettings)
                                                                                                        returnVal='on';
                                                                                                    else
                                                                                                        returnVal='off';
                                                                                                    end

                                                                                                    function returnVal=locGetCovMetricRelationalBoundary(this,storedVal)%#ok<INUSD>
                                                                                                        if any('b'==this.CovMetricSettings)
                                                                                                            returnVal='on';
                                                                                                        else
                                                                                                            returnVal='off';
                                                                                                        end

                                                                                                        function returnVal=locGetCovLogicBlockShortCircuit(this,storedVal)%#ok<INUSD>
                                                                                                            if any('s'==this.CovMetricSettings)
                                                                                                                returnVal='on';
                                                                                                            else
                                                                                                                returnVal='off';
                                                                                                            end

                                                                                                            function returnVal=locGetCovUnsupportedBlockWarning(this,storedVal)%#ok<INUSD>
                                                                                                                if any('w'==this.CovMetricSettings)
                                                                                                                    returnVal='on';
                                                                                                                else
                                                                                                                    returnVal='off';
                                                                                                                end

                                                                                                                function returnVal=locGetCovHighlightResults(this,storedVal)%#ok<INUSD>

                                                                                                                    if any('e'==this.CovMetricSettings)
                                                                                                                        returnVal='off';
                                                                                                                    else
                                                                                                                        returnVal='on';
                                                                                                                    end

                                                                                                                    function locEditCovMetricSettings(this,metricCode,addToString)
                                                                                                                        covMetricSettings=this.covMetricSettings;
                                                                                                                        if addToString

                                                                                                                            if~contains(covMetricSettings,metricCode)
                                                                                                                                covMetricSettings(end+1)=metricCode;
                                                                                                                            end
                                                                                                                        else

                                                                                                                            covMetricSettings=strrep(covMetricSettings,metricCode,'');
                                                                                                                        end
                                                                                                                        this.covMetricSettings=locSortCovMetricSettings(covMetricSettings);

                                                                                                                        function sorted=locSortCovMetricSettings(covMetricSettings)
                                                                                                                            allOptions='dcmtrzoibswe';
                                                                                                                            selectedIX=regexp(allOptions,['[',covMetricSettings,']']);
                                                                                                                            sorted=allOptions(selectedIX);


