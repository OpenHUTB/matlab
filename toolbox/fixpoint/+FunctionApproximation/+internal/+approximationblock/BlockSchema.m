classdef BlockSchema




    properties(Constant,Hidden)

        PackageName='FunctionApproximation.internal.approximationblock.callback';
    end

    properties(Constant)

        OriginalBlockName='Original';


        ApproximatePrefix='Approximate';


        SourceName='Source';


        CreatedByParameterName='createdBy';


        CreatedByParameterValue='FunctionApproximation';


        ShowOriginalButtonParameterName='showOriginal';



        ShowOriginalPrompt=message('SimulinkFixedPoint:functionApproximation:rfabShowOriginalPrompt').getString();



        ShowOriginalTooltip=message('SimulinkFixedPoint:functionApproximation:rfabShowOriginalTooltip').getString();


        ShowCurrentButtonParameterName='showCurrent';



        ShowCurrentPrompt=message('SimulinkFixedPoint:functionApproximation:rfabShowCurrentPrompt').getString();




        ShowCurrentTooltip=message('SimulinkFixedPoint:functionApproximation:rfabShowCurrentTooltip').getString();



        FunctionVersionParameterName='functionVersion';




        SelectFunctionVersionPrompt=message('SimulinkFixedPoint:functionApproximation:rfabSelectFunctionVersionPrompt').getString();


        CurrentActiveParameterName='currentActive';


        NumApproximatesParameterName='nApproximates';


        VariantTagParameterName='variantTag';


        CreatedOnParameterName='createdOn';


        MATLABVersionOnParameterName='matlabVersion';



        RevertToOriginal='revertToOriginal';


        RevertToOriginalPrompt=message('SimulinkFixedPoint:functionApproximation:rfabRevertToOriginalPrompt').getString();


        RevertToOriginalTooltip=message('SimulinkFixedPoint:functionApproximation:rfabRevertToOriginalTooltip').getString();


        RedesignParameterName='redesign';


        RedesignPrompt=message('SimulinkFixedPoint:functionApproximation:rfabRedesignPrompt').getString();


        RedesignTooltip=message('SimulinkFixedPoint:functionApproximation:rfabRedesignTooltip').getString();


        ProblemStructParameterName='problemStruct';


        CompareDataParameterName='compareData';


        CompareParameterName='compare';


        ComparePrompt=message('SimulinkFixedPoint:functionApproximation:rfabComparePrompt').getString();


        CompareTooltip=message('SimulinkFixedPoint:functionApproximation:rfabCompareTooltip').getString();


        DetailsParameter='details';


        DetailsPrompt=message('SimulinkFixedPoint:functionApproximation:rfabDetailsPrompt').getString();


        DetailsTooltip=message('SimulinkFixedPoint:functionApproximation:rfabDetailsTooltip').getString();


        DetailsTextParameter='detailsText';


        DelayBeforeLookupParamterName='delayBeforeLookup';


        DelayBeforeLookupPrompt=message('SimulinkFixedPoint:functionApproximation:rfabDelayBeforeLookupPrompt').getString();


        DelayAfterLookupParamterName='delayAfterLookup';


        DelayAfterLookupPrompt=message('SimulinkFixedPoint:functionApproximation:rfabDelayAfterLookupPrompt').getString();


        InitialConditionDelayAfterLookupParameterName='initialConditionDelayAfterLookup';


        InitialConditionDelayAfterLookupPrompt=message('SimulinkFixedPoint:functionApproximation:rfabDelayAfterLookupInitialConditionPrompt').getString();


        SimulateWithDelayParameterName='simulateWithDelay';


        SimulateWithDelayPrompt=message('SimulinkFixedPoint:functionApproximation:rfabSimulateWithDelayPrompt').getString();


        LatencyParameterName='simulationLatency';
    end

    methods
        function tag=getTagForApproximate(this,approximateNumber)

            suffix='';
            if approximateNumber>1
                suffix=int2str(approximateNumber);
            end
            tag=[this.ApproximatePrefix,suffix];
        end

        function tag=getTagForOriginal(this)

            tag=this.OriginalBlockName;
        end

        function variantControlString=getVariantControlString(this,variantSystemTag,variantTag)



            variantControlString=[this.PackageName,'.isCurrent(''',variantSystemTag,''',''',variantTag,''')'];
        end

        function nextPosition=getNextPosition(~,currentPosition)


            nextPosition=[currentPosition(1),currentPosition(4)+50,currentPosition(3),2*currentPosition(4)-currentPosition(2)+50];
        end

        function name=getNameForApproximate(this,vssPath,approximateNumber)

            name=[vssPath,'/',getTagForApproximate(this,approximateNumber)];
        end

        function name=getNameForOriginal(this,vssPath)

            name=[vssPath,'/',this.OriginalBlockName];
        end

        function tag=getCallbackForShowOriginal(this,variantSystemTag,variantTagOriginal)


            tag=[this.PackageName,'.showFunction(''',variantSystemTag,''',''',variantTagOriginal,''');'];
        end

        function tag=getCallbackForShowCurrent(this,variantSystemTag)


            tag=[this.PackageName,'.showCurrent(','''',variantSystemTag,'''',');'];
        end

        function tag=getCallbackForSelectFunctionVersion(this,variantSystemTag)



            tag=[this.PackageName,'.registerActiveFunction(''',variantSystemTag,''');'];
        end

        function sourcePath=getSourcePath(this,variantPath)

            sourcePath=[variantPath,'/',this.SourceName];
        end

        function sourcePath=getOriginalSource(this,vssPath)


            sourcePath=getSourcePath(this,getNameForOriginal(this,vssPath));
        end

        function sourcePath=getApproximateSource(this,vssPath,approximateNumber)



            sourcePath=getSourcePath(this,getNameForApproximate(this,vssPath,approximateNumber));
        end

        function tag=getCallbackForRevertDialog(this,variantSystemTag)





            tag=[this.PackageName,'.revertToOriginal(','''',variantSystemTag,'''',');'];
        end

        function tag=getCallbackForRevertDialogWithPath(this,variantPath)





            tag=[this.PackageName,'.revertToOriginalWithPath(','''',variantPath,'''',');'];
        end

        function tag=getCallbackForRevertLink(this,variantSystemTag)


            tag=[this.PackageName,'.revertDialog(','''',variantSystemTag,'''',');'];
        end

        function tag=getCallbackForCopyFunction(this,variantSystemTag)

            tag=[this.PackageName,'.updateTag(','''',variantSystemTag,'''',');'];
        end

        function tag=getCallbackForOpenFunction(this,variantSystemTag)

            tag=[this.PackageName,'.openMask(','''',variantSystemTag,'''',');'];
        end

        function tag=getCallbackForRedesign(this,variantSystemTag)

            tag=[this.PackageName,'.redesign(','''',variantSystemTag,'''',');'];
        end

        function tag=getCallbackForCompare(this,variantSystemTag)


            tag=[this.PackageName,'.compareToOriginal(','''',variantSystemTag,'''',');'];
        end

        function callback=getCallbackForMaskInitialization(~)
            callback='FunctionApproximation.internal.approximationblock.callback.initializeMask(gcbh);';
        end

        function dialogControlNames=getDialogControlNames(this)

            dialogControlNames={...
            this.ShowOriginalButtonParameterName,...
            this.ShowCurrentButtonParameterName,...
            this.RevertToOriginal,...
            this.RedesignParameterName,...
            this.CompareParameterName,...
            };
        end

        function allParameterNames=getAllParameterNames(this)

            allParameterNames={...
            this.CreatedByParameterName,...
            this.FunctionVersionParameterName,...
            this.CurrentActiveParameterName,...
            this.NumApproximatesParameterName,...
            this.VariantTagParameterName,...
            this.CreatedOnParameterName,...
            this.MATLABVersionOnParameterName,...
            this.ProblemStructParameterName,...
            this.RedesignParameterName,...
            this.CompareDataParameterName,...
            };
        end

        function allCallbacks=getBlockObjectCallbacks(~)

            allCallbacks={'CopyFcn','OpenFcn'};
        end

        function helpFunction=getHelpFunction(~)

            helpFunction="helpview(fullfile(docroot,'fixedpoint','fixedpoint.map'), 'function_approximation_block')";
        end

        function callback=getCallbackForSimulateWithDelay(this)

            callback=[this.PackageName,'.simulateWithDelay();'];
        end

        function dtcName=getInputDTCName(~,ii)

            dtcName=['DTCIn_',int2str(ii)];
        end

        function saturationName=getOutputSaturationName(~,ii)

            saturationName=['SaturateOut_',int2str(ii)];
        end

        function latencyDelayName=getOutputLatencyDelayName(~,ii)

            latencyDelayName=['DelayOut_',int2str(ii)];
        end
    end
end


