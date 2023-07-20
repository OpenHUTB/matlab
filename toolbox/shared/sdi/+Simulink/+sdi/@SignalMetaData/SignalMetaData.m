classdef SignalMetaData<int32



    enumeration
        Line(0)
        SignalName(1)
        AbsTol(2)
        SyncMethod(3)
        BlockPath(4)
        RelTol(5)
        DataSource(6)
        SID(7)
        TimeSeriesRoot(8)
        TimeSource(9)
        InterpMethod(10)
        Port(11)
        Dimensions(12)
        Channel(13)
        Run(14)
        Model(15)
        Result(16)
        BlockPath1(17)
        BlockPath2(18)
        SignalName1(19)
        SignalName2(20)
        DataSource1(21)
        DataSource2(22)
        SID1(23)
        SID2(24)
        AbsTol1(25)
        RelTol1(26)
        SyncMethod1(27)
        InterpMethod1(28)
        Channel1(29)
        AlignedBy(30)
        LinkToPlot(31)
        BlockName(32)
        Units(33)
        Units1(34)
        Units2(35)
        Run1(36)
        Run2(37)
        Channel2(38)
        Model1(39)
        Model2(40)
        BlockName1(41)
        BlockName2(42)
        Dimensions1(43)
        Dimensions2(44)
        TimeSeriesRoot1(45)
        TimeSeriesRoot2(46)
        TimeSource1(47)
        TimeSource2(48)
        Line1(49)
        Line2(50)
        Port1(51)
        Port2(52)
        SigDataType(53)
        SigDataType1(54)
        SigDataType2(55)
        SigSampleTime(56)
        SigSampleTime1(57)
        SigSampleTime2(58)
        MaxDifference(59)
        TimeTol(60)
        TimeTol1(61)
        OverrideGlobalTol(62)
        OverrideGlobalTol1(63)
        SigComplexity(64)
        SigComplexFormat(65)
        SignalDescription(66)
        SigDisplayScaling(67)
        SigDisplayOffset(68)
    end

    methods(Hidden=true)

        function name=getName(obj)
            name=[];
            switch obj
            case Simulink.sdi.SignalMetaData.Line
                name=Simulink.sdi.internal.StringDict.mgLine;
            case Simulink.sdi.SignalMetaData.SignalName
                name=Simulink.sdi.internal.StringDict.mgNameLabel;
            case Simulink.sdi.SignalMetaData.AbsTol
                name=Simulink.sdi.internal.StringDict.mgAbsTolV2Short;
            case Simulink.sdi.SignalMetaData.SyncMethod
                name=Simulink.sdi.internal.StringDict.mgSyncMethodShort;
            case Simulink.sdi.SignalMetaData.BlockPath
                name=Simulink.sdi.internal.StringDict.IGBlockSourceColName;
            case Simulink.sdi.SignalMetaData.BlockName
                name=Simulink.sdi.internal.StringDict.mgBlockName;
            case Simulink.sdi.SignalMetaData.RelTol
                name=Simulink.sdi.internal.StringDict.mgRelTolV2Short;
            case Simulink.sdi.SignalMetaData.DataSource
                name=Simulink.sdi.internal.StringDict.IGDataSourceColNameShort;
            case Simulink.sdi.SignalMetaData.TimeSeriesRoot
                name=Simulink.sdi.internal.StringDict.IGRootSourceColNameShort;
            case Simulink.sdi.SignalMetaData.TimeSource
                name=Simulink.sdi.internal.StringDict.IGTimeSourceColNameShort;
            case Simulink.sdi.SignalMetaData.InterpMethod
                name=Simulink.sdi.internal.StringDict.mgInterpMethodShort;
            case Simulink.sdi.SignalMetaData.Port
                name=Simulink.sdi.internal.StringDict.IGPortIndexColName;
            case Simulink.sdi.SignalMetaData.Dimensions
                name=Simulink.sdi.internal.StringDict.mgDimensionShort;
            case Simulink.sdi.SignalMetaData.Channel
                name=Simulink.sdi.internal.StringDict.mgChannel;
            case Simulink.sdi.SignalMetaData.Run
                name=Simulink.sdi.internal.StringDict.mgRun;
            case Simulink.sdi.SignalMetaData.Model
                name=Simulink.sdi.internal.StringDict.IGModelSourceColName;
            case Simulink.sdi.SignalMetaData.Result
                name=Simulink.sdi.internal.StringDict.mgTest;
            case Simulink.sdi.SignalMetaData.BlockPath1
                name=[...
                Simulink.sdi.internal.StringDict.IGBlockSourceColName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.BlockPath2
                name=[...
                Simulink.sdi.internal.StringDict.IGBlockSourceColName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.DataSource1
                name=[...
                Simulink.sdi.internal.StringDict.IGDataSourceColNameShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.DataSource2
                name=[...
                Simulink.sdi.internal.StringDict.IGDataSourceColNameShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.SID
                name=Simulink.sdi.internal.StringDict.mgSID;
            case Simulink.sdi.SignalMetaData.SID1
                name=Simulink.sdi.internal.StringDict.mgSID1;
            case Simulink.sdi.SignalMetaData.SID2
                name=Simulink.sdi.internal.StringDict.mgSID2;
            case Simulink.sdi.SignalMetaData.AbsTol1
                name=Simulink.sdi.internal.StringDict.mgAbsTol1;
            case Simulink.sdi.SignalMetaData.RelTol1
                name=Simulink.sdi.internal.StringDict.mgRelTol1;
            case Simulink.sdi.SignalMetaData.SyncMethod1
                name=Simulink.sdi.internal.StringDict.mgSync1;
            case Simulink.sdi.SignalMetaData.InterpMethod1
                name=Simulink.sdi.internal.StringDict.mgInterp1;
            case Simulink.sdi.SignalMetaData.SignalName1
                name=[...
                Simulink.sdi.internal.StringDict.mgNameLabel...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.SignalName2
                name=[...
                Simulink.sdi.internal.StringDict.mgNameLabel...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Channel1
                name=[...
                Simulink.sdi.internal.StringDict.mgChannel...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.AlignedBy
                name=Simulink.sdi.internal.StringDict.mgAlignedBy;
            case Simulink.sdi.SignalMetaData.LinkToPlot
                name=Simulink.sdi.internal.StringDict.rgLinkToPlotColumnName;
            case Simulink.sdi.SignalMetaData.Units
                name=Simulink.sdi.internal.StringDict.mgUnits;
            case Simulink.sdi.SignalMetaData.Units1
                name=[...
                Simulink.sdi.internal.StringDict.mgUnits...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.Units2
                name=[...
                Simulink.sdi.internal.StringDict.mgUnits...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.SigDataType
                name=Simulink.sdi.internal.StringDict.mgDataType;
            case Simulink.sdi.SignalMetaData.SigDataType1
                name=[...
                Simulink.sdi.internal.StringDict.mgDataType...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.SigDataType2
                name=[...
                Simulink.sdi.internal.StringDict.mgDataType...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.SigSampleTime
                name=Simulink.sdi.internal.StringDict.mgSampleTime;
            case Simulink.sdi.SignalMetaData.SigSampleTime1
                name=[...
                Simulink.sdi.internal.StringDict.mgSampleTime...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.SigSampleTime2
                name=[...
                Simulink.sdi.internal.StringDict.mgSampleTime...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Run1
                name=[...
                Simulink.sdi.internal.StringDict.mgRun...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.Run2
                name=[Simulink.sdi.internal.StringDict.mgRun...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Channel2
                name=[Simulink.sdi.internal.StringDict.mgChannel...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Model1
                name=[Simulink.sdi.internal.StringDict.IGModelSourceColName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.Model2
                name=[Simulink.sdi.internal.StringDict.IGModelSourceColName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.BlockName1
                name=[Simulink.sdi.internal.StringDict.mgBlockName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.BlockName2
                name=[Simulink.sdi.internal.StringDict.mgBlockName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Dimensions1
                name=[Simulink.sdi.internal.StringDict.mgDimensionShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.Dimensions2
                name=[Simulink.sdi.internal.StringDict.mgDimensionShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.TimeSeriesRoot1
                name=[Simulink.sdi.internal.StringDict.IGRootSourceColNameShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.TimeSeriesRoot2
                name=[Simulink.sdi.internal.StringDict.IGRootSourceColNameShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.TimeSource1
                name=[Simulink.sdi.internal.StringDict.IGTimeSourceColNameShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.TimeSource2
                name=[Simulink.sdi.internal.StringDict.IGTimeSourceColNameShort...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Line1
                name=[Simulink.sdi.internal.StringDict.mgLine...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.Line2
                name=[Simulink.sdi.internal.StringDict.mgLine...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.Port1
                name=[Simulink.sdi.internal.StringDict.IGPortIndexColName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun1Short,')'];
            case Simulink.sdi.SignalMetaData.Port2
                name=[Simulink.sdi.internal.StringDict.IGPortIndexColName...
                ,newline...
                ,'(',Simulink.sdi.internal.StringDict.mgRun2Short,')'];
            case Simulink.sdi.SignalMetaData.MaxDifference
                name=getString(message('SDI:sdi:mgMaxDiffShort'));
            case Simulink.sdi.SignalMetaData.TimeTol
                name=Simulink.sdi.internal.StringDict.mgTimeTolShort;
            case Simulink.sdi.SignalMetaData.TimeTol1
                name=Simulink.sdi.internal.StringDict.mgTimeTol1;
            case Simulink.sdi.SignalMetaData.OverrideGlobalTol
                name=Simulink.sdi.internal.StringDict.mgOverrideGlobalTolShort;
            case Simulink.sdi.SignalMetaData.OverrideGlobalTol1
                name=Simulink.sdi.internal.StringDict.mgOverrideGlobalTol1;
            case Simulink.sdi.SignalMetaData.SigComplexity
                name=Simulink.sdi.internal.StringDict.mgComplexity;
            case Simulink.sdi.SignalMetaData.SigComplexFormat
                name=Simulink.sdi.internal.StringDict.mgComplexFormat;
            case Simulink.sdi.SignalMetaData.SignalDescription
                name=Simulink.sdi.internal.StringDict.mgDescription;
            case Simulink.sdi.SignalMetaData.SigDisplayScaling
                name=Simulink.sdi.internal.StringDict.mgDisplayScalingShort;
            case Simulink.sdi.SignalMetaData.SigDisplayOffset
                name=Simulink.sdi.internal.StringDict.mgDisplayOffsetShort;
            end
        end

    end

end

