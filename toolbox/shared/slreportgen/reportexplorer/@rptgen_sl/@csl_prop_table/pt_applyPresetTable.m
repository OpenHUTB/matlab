function pt_applyPresetTable(c,tableName)






    defaultRender='N v';



    title='Title';
    singleVal=logical(0);
    colWid=[1,1,1,1];
    [pnames{1:4,1:4}]=deal('');

    switch lower(c.ObjectType)
    case 'model'
        switch lower(tableName)
        case 'default'
            title='%<Name> Information';
            singleVal=logical(0);
            colWid=[1,1.5];
            pnames={'%<Name>','%<Description>'
            '%<BlockDiagramType>','%<FileName>'};
        case 'version information'
            title='%<Name>  Version Information';
            singleVal=logical(0);
            colWid=[1,1.5];
            pnames={'%<ModelVersion>','%<ConfigurationManager>'
            '%<Created>','%<Creator>'
            '%<LastModifiedDate>','%<LastModifiedBy>'};
        case 'summary (req. simulink coder)'
            title='%<Name> Summary Information';
            singleVal=logical(1);
            colWid=[2,1,2,1];
            pnames={
            '%<NumModelInputs>','%<NumModelOutputs>'
            '%<NumVirtualSubsystems>','%<NumNonvirtSubsystems>'
            '%<NumNonVirtBlocksInModel>','%<NumBlockTypeCounts>'
            '%<NumBlockSignals>','%<NumBlockParams>'
            '%<NumZCEvents>','%<NumNonsampledZCs>'
            };
        case 'simulation parameters'
            title='%<Name> Simulation Parameters';
            singleVal=logical(0);
            colWid=[1,1,1];
            pnames={
            '%<Solver>','%<ZeroCross>','%<StartTime> %<StopTime>'
            '%<RelTol>','%<AbsTol>','%<Refine>'
            '%<InitialStep>','%<FixedStep>','%<MaxStep>'
            };
        case 'simulink coder information'
            title='%<Name> Simulink Coder Information';
            singleVal=logical(1);
            colWid=[2,2,2,1];
            pnames={
            '%<RTWSystemTargetFile>','%<RTWRetainRTWFile>'
            '%<RTWInlineParameters>','%<RTWPlaceOutputsASAP>'
            '%<RTWTemplateMakefile>','%<RTWMakeCommand>'
            '%<RTWGenerateCodeOnly>','%<RTWOptions>'
            };
        end
    case 'system'
        switch lower(tableName)
        case 'default'
            title='%<Name> System Information';
            colWid=[1,3,1,1];
            singleVal=logical(1);
            pnames={'%<Name>','%<Parent>';
            '%<Description>','%<Tag>';
            '%<Blocks>','%<LinkStatus>'};
        case 'system signals'
            title='%<Name> System Signals';
            colWid=[1,2];
            singleVal=logical(1);
            pnames={'%<InputSignalNames>'
'%<OutputSignalNames>'
'%<CompiledPortWidths>'
'%<CompiledPortDataTypes>'
            '%<CompiledPortComplexSignals>'};
        case 'mask properties'
            title='%<Name> Mask Properties';
            singleVal=logical(1);
            colWid=[1,2];
            pnames={'%<MaskType>'
'%<Mask>'
'%<MaskDescription>'
'%<MaskHelp>'
'%<MaskPrompts>'
'%<MaskNames>'
'%<MaskValues>'
            '%<MaskTunableValues>'};
        case 'print properties'
            title='%<Name> Print Properties';
            colWid=[1,1.25];
            singleVal=logical(0);
            pnames={
            'PaperPositionMode: %<PaperPositionMode>',...
            'PaperPosition: %<PaperPosition> %<PaperUnits>';...
            'PaperType: %<PaperType> %<PaperOrientation>',...
'PaperSize: %<PaperSize> %<PaperUnits>'
            };
            defaultRender='v';
        end
    case 'block'
        switch lower(tableName)
        case 'default'
            title='%<Name> Block Information';
            colWid=[1,1.5,1.25,1.5];
            singleVal=logical(1);
            pnames={'%<BlockType>','%<dialogparameters>'
            '%<Parent>','%<InputSignalNames>'
            '%<Description>','%<OutputSignalNames>'};
        case 'block signals'
            title='%<Name> Block Signals';
            colWid=[1,2];
            singleVal=logical(1);
            pnames={'%<InputSignalNames>'
'%<OutputSignalNames>'
'%<CompiledPortWidths>'
'%<CompiledPortDataTypes>'
            '%<CompiledPortComplexSignals>'};
        case 'mask properties'
            title='%<Name> Mask Properties';
            singleVal=logical(1);
            colWid=[1,2];
            pnames={'%<MaskType>'
'%<Mask>'
'%<MaskDescription>'
'%<MaskHelp>'
'%<MaskPrompts>'
'%<MaskNames>'
'%<MaskValues>'
            '%<MaskTunableValues>'};
        end
    case 'signal'
        switch lower(tableName)
        case 'default'
            title='Signal Information';
            colWid=[1,1.5,1.75,2];
            singleVal=logical(1);
            pnames={'%<Name>','%<Description>'
            '%<ParentBlock>','%<CompiledPortDataType>'};
        case 'complete'
            title='Signal Information';
            colWid=[1,2];
            singleVal=logical(1);
            pnames={'%<Name>'
'%<Description>'
'%<ParentBlock>'
'%<ParentSystem>'
'%<DocumentLink>'
'%<CompiledPortDataType>'
'%<CompiledPortWidth>'
'%<CompiledPortComplexSignal>'
            '%<CompiledPortUnit>'};

        case 'compiled information'
            title='Compiled Information';
            colWid=[1,1.5];
            singleVal=logical(1);
            pnames={'%<Name>'
'%<CompiledPortDataType>'
'%<CompiledPortWidth>'
'%<CompiledPortComplexSignal>'
            '%<CompiledPortUnit>'};

        end
    case 'annotation'
        switch lower(tableName)
        case 'default'
            title='';
            colWid=[1,5];
            singleVal=true;
            pnames={'%<Text>'};
        end
    case 'configset'
        switch lower(tableName)
        case 'default'
            title='';
            colWid=[1,5];
            singleVal=true;
            pnames={'%<Name>'};
        end
    end

    c.setTableStrings(pnames,singleVal,title,defaultRender);
    c.ColWidths=colWid;
