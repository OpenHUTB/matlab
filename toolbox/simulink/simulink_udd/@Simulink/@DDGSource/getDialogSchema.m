function dlgStruct=getDialogSchema(this,str)%#ok
































    this.paramsMap=this.getDialogParams;


    h=this.getBlock;


    try
        unknownBlockType=false;

        if(slfeature('CUSTOM_BUSES')==1)&&strcmp(h.BlockType,'PMIOPort')
            dlgStruct=PMIOPort_ddg(this,h);
        else
            switch h.BlockType
            case 'ArithShift'
                dlgStruct=ArithShift_ddg(this,h);
            case{'Inport','Outport'}
                dlgStruct=BusElementPort_ddg(this,h);
            case 'Goto'
                dlgStruct=gotoddg(this,h);
            case 'From'
                dlgStruct=fromddg(this,h);
            case 'BusCreator'
                dlgStruct=busCreatorddg(this,h);
            case{'DataStoreRead','DataStoreWrite'}
                dlgStruct=dataStoreRWddg(this,h);
            case 'DataStoreMemory'
                dlgStruct=dataStoreMemddg(this,h);
            case 'Delay'
                dlgStruct=delay_ddg(this,h);
            case 'DiscreteStateSpace'
                dlgStruct=dss_ddg(this,h);
            case 'DiscreteZeroPole'
                dlgStruct=dzp_ddg(this,h);
            case 'UnitDelay'
                dlgStruct=UnitDelay_ddg(this,h);
            case 'ComputationalDelay'
                dlgStruct=CompDelay_ddg(this,h);
            case 'Memory'
                dlgStruct=memory_ddg(this,h);
            case 'S-Function'
                dlgStruct=sfunddg(this,h);
            case 'M-S-Function'
                dlgStruct=msfunlvl2ddg(this,h);
            case 'Lookup'
                dlgStruct=lookup1dddg(this,h);
            case 'Lookup2D'
                dlgStruct=lookup2dddg(this,h);
            case 'Lookup_n-D'
                dlgStruct=lookup_nd_ddg(this,h);
            case 'LookupNDDirect'
                dlgStruct=direct_lookupnd_ddg(this,h);
            case 'Interpolation_n-D'
                dlgStruct=interpndddg(this,h);
            case 'FromSpreadsheet'
                dlg=iofile.DDGSource(this,h);
                dlgStruct=getDialogSchema(dlg,this,h);
            case 'PreLookup'
                dlgStruct=prelookupddg(this,h);
            case{'DiscreteFir','AllpoleFilter'}
                dlgStruct=fir_ddg(this,h);
            case{'DiscreteFilter','DiscreteTransferFcn'}
                dlgStruct=dtf_ddg(this,h);
            case 'DiscreteIntegrator'
                dlgStruct=DiscreteIntegrator_ddg(this,h);
            case 'ModelReference'
                dlgStruct=mdlrefddg(this,h);
            case 'ObserverReference'
                dlgStruct=cosimrefddg(this,h);
            case 'InjectorReference'
                dlgStruct=cosimrefddg(this,h);
            case 'ObserverPort'
                dlgStruct=cosimportddg(this,h);
            case 'InjectorInport'
                dlgStruct=cosimportddg(this,h);
            case 'InjectorOutport'
                dlgStruct=cosimportddg(this,h);
            case 'Sqrt'
                dlgStruct=sqrt_ddg(this,h);
            case{'StateReader','StateWriter'}
                dlgStruct=StateAccessor_ddg(this,h);
            case{'ParameterReader','ParameterWriter'}
                dlgStruct=ParamAccessor_ddg(this,h);
            case 'SubSystem'

                if(strcmp(h.Mask,'on')&&...
                    strcmp(h.MaskType,'Enumerated Constant'))
                    dlgStruct=enumconstddg(this,h);
                elseif strcmp(h.Variant,'on')

                    dlgStruct=subsysVariantsddg(this,h);
                elseif strcmp(h.TemplateBlock,'self')
                    dlgStruct=configblkddg(this,h);
                else
                    unknownBlockType=true;
                end

            case 'Reference'
                dlgStruct=referenceblock_ddg(this,h);




            case{'VariantSource','VariantSink'}


                dlgStruct=variantSourceSinkddg(this,h);

            case 'VariantPMConnector'
                dlgStruct=variantPMConnectorddg(this,h);

            case{'FunctionCaller'}
                dlgStruct=CallerBlock_ddg(this,h);

            case 'CoSimServiceBlock'

                dlgStruct=cosimBlockddg(this,h);

            otherwise
                unknownBlockType=true;
            end
        end

        if(unknownBlockType)
            dlgStruct=errorDlg(h,['Unknown block type: ',h.BlockType]);
            warning('DDG:SLDialogSource','Unknown block type in DDGSource %s',mfilename);
        end

        if~isfield(dlgStruct,'ExplicitShow')
            dlgStruct.ExplicitShow=true;
        end

    catch e
        dlgStruct=errorDlg(h,e.message);
    end





    function dlgStruct=errorDlg(h,errMsg)
        txt.Name=['<p>',DAStudio.message('Simulink:masks:CreateDialogError'),'</p>',errMsg];
        txt.Type='text';
        txt.WordWrap=true;

        blockType=h.BlockType;
        if strcmp(h.Mask,'on')
            maskType=h.MaskType;
            if~isempty(maskType)
                blockType=maskType;
            end
            blockType=[blockType,' (mask)'];
        end

        dlgStruct.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',blockType);
        dlgStruct.Items={txt};
        dlgStruct.CloseMethod='closeCallback';
        dlgStruct.CloseMethodArgs={'%dialog'};
        dlgStruct.CloseMethodArgsDT={'handle'};


