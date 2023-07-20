function retVal=hdlfeature(varargin)








    narginchk(1,2);

    mlock;
    persistent featureMap;

    if isempty(featureMap)
        featureMap=containers.Map('KeyType','char','ValueType','any');

        featureMap('AXI4StreamControlSignal')='off';


        featureMap('SkipModelGeneration')='off';




        featureMap('InterfaceTableEnum')='off';

        featureMap('IPCoreSoftwareInterfaceLibrary')='off';

        featureMap('QuartusAdditionalSettings')='off';

        featureMap('DNNFPGACodegen')='off';


        featureMap('CheckMinAlgLoopOccurrences')='on';



        featureMap('AXI4StreamSampleControlBus')='off';



        featureMap('VHDLImport')='off';


        featureMap('NFPLogApprxImpl')='off';




        featureMap('SystemObjectML2PIR')='off';

        featureMap('IPCoreResetSync')='on';






        featureMap('SSCHDLLogicTableMinimization')='on';


        featureMap('SSCHDLModeIterOpt')='on';


        featureMap('SSCHDLModelOrderReduction')='off';


        featureMap('SSCHDLNonLinear')='off';


        featureMap('SSCHDLAutoReplace')='on';


        featureMap('SSCHDLLogicTable')='off';



        featureMap('SSCHDLLogicTableMinCover')='off';




        featureMap('SSCHDLAutoSharing')='off';



        featureMap('AXI4SlaveWideData')='off';


        featureMap('EnableForIterator')='off';


        featureMap('EnableMatrixAtDUT')='on';


        featureMap('NonTopNoModelReference')='on';


        featureMap('ScopedGotoBlockSupport')='on';


        featureMap('DetectValidHDLRegistrations')='off';


        featureMap('SupportCommentThrough')='on';


        featureMap('ForEachMatrix')='on';


        featureMap('MatrixMultiplyTransform')='on';


        featureMap('HDLCodeView')='on';


        featureMap('EnableFlattenSFComp')='off';



        featureMap('EnableClockDrivenOutput')='on';


        featureMap('EnableConditionalSubsystem')='on';


        featureMap('BackAnnotateV2')='on';


        featureMap('BackAnnotateGM')='off';


        featureMap('HDLBlockAsDUT')='off';


        featureMap('GenEMLHDLCounter')='off';


        featureMap('TranslateInternal')='off';


        featureMap('VarDelaySupport')='on';


        featureMap('MLHDLSystemC')='on';


        featureMap('MLHDLSystemCVitisHLS')='off';


        featureMap('EnableUnboundedLoopsForHLS')='off';


        featureMap('VarDelaySupport')='on';


        featureMap('DisableLoopUnrollingForSelector')='off';


        featureMap('ExposeWriteSyncSignal')='off';
    end

    featureName=varargin{1};


    retVal=[];
    if featureMap.isKey(featureName)
        retVal=featureMap(featureName);
    end

    if nargin==2

        featureValue=varargin{2};


        featureMap(featureName)=featureValue;
    end





end



