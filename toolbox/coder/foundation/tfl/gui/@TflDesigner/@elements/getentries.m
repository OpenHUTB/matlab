function entries=getentries(this,tag,~)




    switch tag
    case 'Tfldesigner_SaturationMode'
        entries={'Unspecified Saturation',...
        'Wrap on Overflow',...
        'Saturate on Overflow'};

    case 'Tfldesigner_RoundingMode'
        entries={'Unspecified Rounding','Floor',...
        'Ceil','Zero',...
        'Nearest','MATLAB Nearest',...
        'Simplest','Conv'};
    case 'Tfldesigner_IOType'
        entries={'INPUT','OUTPUT'};

    case 'Tfldesigner_ImplType'
        entries={'FUNCTION','MACRO'};

    case 'Tfldesigner_Returnarg'
        if isempty(this.object.Implementation.Arguments)&&...
            isempty(this.object.Implementation.Return)
            entries={};
        else
            entries={};
            rarg=this.object.Implementation.Return;
            if~isempty(rarg)...
                &&~strcmp(rarg.Name,'unused')
                entries=[entries,rarg.Name];
            end

            for idx=1:length(this.object.Implementation.Arguments)
                arg=this.object.Implementation.Arguments(idx);
                if strcmpi(arg.IOType,'RTW_IO_OUTPUT')...
                    &&~strcmp(arg.Name,'unused')
                    entries=[entries,arg.Name];%#ok
                end
            end

            entries=[entries,'void'];
        end

    case 'Tfldesigner_PassbyType'
        entries={'Auto','Pointer',...
        'void Pointer','base Pointer'};

    case{'Tfldesigner_ImplDatatype','Tfldesigner_ImplStructDatatype'}
        dtaItems=this.getConceptualDatatype;
        builtins=dtaItems.builtinTypes';

        extraEntries={'integer','size_t','long','ulong','long_long','ulong_long','char'};

        switch tag




        case 'Tfldesigner_ImplDatatype'
            entries=[builtins,extraEntries];
            if this.isStructSpecEnabled&&...
                ismember(this.object.Key,getLookupKeyEntries)
                entries=[entries,'struct'];
            else
                implarg=hGetActiveImplArg(this);
                if~isempty(implarg)&&this.isDataTypeStruct(implarg.toString(true))
                    entries=[entries,'struct'];
                end
            end



        case 'Tfldesigner_ImplStructDatatype'
            entries=[builtins(1:end-1),extraEntries(1:end-1)];
        end

    case{'Tfldesigner_ConceptualDatatype','Tfldesigner_ConceptualStructDatatype'}
        dt=this.getConceptualDatatype;
        builtins=dt.builtinTypes';
        extraEntries={'logical','fixdt(1,16)','fixdt(1,16,0)','fixdt(1,16,2^0,0)'};

        switch tag
        case 'Tfldesigner_ConceptualDatatype'
            entries=[builtins,extraEntries];
            if this.isStructSpecEnabled
                if ismember(this.object.Key,getLookupKeyEntries)
                    entries=[entries,'struct'];
                end
            end
        case 'Tfldesigner_ConceptualStructDatatype'
            entries=[builtins(1:end-1),extraEntries];
            if this.isStructSpecEnabled
                entries=[entries,this.cargcustomdtype];
            end
        end

    case 'Tfldesigner_SupportNonFinite'
        entries={'UNSPECIFIED','ENABLE','DISABLE'};

    case 'Tfldesigner_AlgorithmInfo'
        entries={'Unspecified','Cordic','Default','Lookup'};

    case 'Tfldesigner_AddMinusAlgorithm'
        entries={'Cast before operation','Cast after operation'};

    case{'Tfldesigner_RSQRT_AlgorithmInfo',...
        'Tfldesigner_RECIPROCAL_AlgorithmInfo'}
        entries={'Unspecified','Newton Raphson','Default'};

    case 'Tfldesigner_FIR2D_AlgorithmInfo'
        entries={'FIR2D Convolution','FIR2D Correlation','FIR2D Unspecified'};

    case 'Tfldesigner_FIR2D_OutputMode'
        entries={'Same as Input','Full Output','Valid Output',...
        'Unrestricted Output','Num Output','Unspecified Output'};

    case 'Tfldesigner_CONVCORR_AlgorithmInfo'
        entries={'CONVCORR1D Convolution','CONVCORR1D Correlation','CONVCORR1D Unspecified'};

    case 'Tfldesigner_LOOKUP_Search'
        entries={'Even Search','Linear Search','Binary Search','Unspecified Search'};

    case 'Tfldesigner_LOOKUP_Interp'
        entries={'Flat Interpolation','Linear Interpolation','Above Interpolation','Nearest Interpolation',...
        'Cubic Spline Interpolation','Unspecified Interpolation'};

    case 'Tfldesigner_LOOKUP_Extrp'
        entries={'Clip Extrapolation','Linear Extrapolation','Cubic Spline Extrapolation',...
        'Unspecified Extrapolation'};

    case 'Tfldesigner_TIMER_CountDirection'
        entries={'Unspecified','Up','Down'};
    case 'Tfldesigner_InPlaceArg'
        entries={'None'};
        if this.activeimplarg~=0&&~isempty(this.object.Implementation.Arguments)
            activearg=this.object.Implementation.Arguments(this.activeimplarg);
            if strcmpi(activearg.Name(1),'u')
                for i=1:length(this.object.ConceptualArgs)
                    arg=this.object.ConceptualArgs(i);
                    if strcmp(arg.IOType,'RTW_IO_OUTPUT')
                        entries{end+1}=arg.Name;%#ok
                    end
                end
            else
                for i=1:length(this.object.ConceptualArgs)
                    arg=this.object.ConceptualArgs(i);
                    if strcmp(arg.IOType,'RTW_IO_INPUT')
                        entries{end+1}=arg.Name;%#ok
                    end
                end
            end
        end
    case 'Tfldesigner_ArrayLayout'
        entries={'Column-major',...
        'Row-major',...
        'Column-and-Row'};
    otherwise
        entries={};
    end


    function lookupkeys=getLookupKeyEntries

        lookupkeys={...
        'interp1D',...
        'interp2D',...
        'interp3D',...
        'interp4D',...
        'interp5D',...
        'prelookup',...
        };


        function implarg=hGetActiveImplArg(this)


            index=this.activeimplarg;
            implarg=[];

            if index==0&&~isempty(this.object.Implementation.Return)
                implarg=this.object.Implementation.Return;
            else

                if index~=0&&~isempty(this.object.Implementation.Arguments)
                    implarg=this.object.Implementation.Arguments(index);
                end
            end



