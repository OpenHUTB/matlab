function varargout=dspblkcicfilter(action,blkh,filtFrom,varargin)





    switch action
    case 'icon'
        if filtFrom==1

            blkTypeStr=varargin{1};
            str=['CIC\n',blkTypeStr];
        else

            str=['CIC Filter\nFilter:\n',get_param(blkh,'filtobj')];
        end
        varargout={str};

    case 'initCICInterp'



        framing=varargin{1};
        if framing==3
            framing=1;
        elseif framing==4
            framing=2;
        end
        varargout{1}=framing;

    case 'init'


        fdtbxexists=false;
        if isfdtbxinstalled
            fdtbxexists=true;
        end
        fixptexists=false;
        if isfixptinstalled
            fixptexists=true;
        end


        okToUseCICObjects=fixptexists&&fdtbxexists;

        filterDefined=false;
        InputWL=16;
        InputFL=15;

        filtInternals=get_param(blkh,'filterInternals');
        switch filtInternals
        case 'Full precision'
            args.filterInternals=1;
        case 'Minimum section word lengths'
            args.filterInternals=2;
        case 'Specify word lengths'
            args.filterInternals=3;
        case 'Binary point scaling'
            args.filterInternals=4;
        end

        block=get_param(blkh,'Object');
        if filtFrom==1
            args.filtFrom=1;

            if isfield(block.UserData,'filter')
                block.UserData=rmfield(block.UserData,'filter');
            end
            ftype=getfiltinfo(get_param(blkh,'ftype'));


            for i=1:7
                if(ischar(varargin{i}))
                    error(message('dsp:dspblkcicfilter:paramDTypeError1'));
                end
            end
            R=double(varargin{1});
            M=double(varargin{2});
            N=double(varargin{3});
            section2NWL=double(varargin{4});
            section2NFL=double(varargin{5});
            outWL=double(varargin{6});
            outFL=double(varargin{7});
            filterInternals=double(varargin{8});

            filterDefined=true;

            if(ftype>2)
                block.UserData.filterConstructor='dsp.internal.mfilt.cicinterp';
            else
                block.UserData.filterConstructor='mfilt.cicdecim';
            end

            if isoktocheckparam(R)
                if~isScalarRealDouble(R)
                    error(message('dsp:dspblkcicfilter:paramDTypeError2'));
                else
                    if~isFloatIntegerGE(R,2)
                        error(message('dsp:dspblkcicfilter:paramPositiveIntegerError1'));
                    end
                end
            end

            if isoktocheckparam(M)
                if~isScalarRealDouble(M)
                    error(message('dsp:dspblkcicfilter:paramDTypeError3'));
                else
                    if~isFloatIntegerGE(M,1)
                        error(message('dsp:dspblkcicfilter:paramPositiveIntegerError2'));
                    end
                end
            end

            if isoktocheckparam(N)
                if~isScalarRealDouble(N)
                    error(message('dsp:dspblkcicfilter:paramDTypeError4'));
                else
                    if~isFloatIntegerGE(N,1)
                        error(message('dsp:dspblkcicfilter:paramPositiveIntegerError3'));
                    end
                end
            end

            block.UserData.filterConstructorArgs=...
            {R,M,N,section2NWL,section2NFL,outWL,outFL,filterInternals};
        else

            if isfield(block.UserData,'filterConstructor')
                block.UserData=rmfield(block.UserData,'filterConstructor');
                block.UserData=rmfield(block.UserData,'filterConstructorArgs');
            end
            block.UserData.filter=[];
            if okToUseCICObjects
                blockType=varargin{1};
                filter=varargin{2};

                blockTypeIsDecimation=strcmpi(blockType,'decimation');
                if isoktocheckparam(filter)

                    if blockTypeIsDecimation
                        if~isa(filter,'mfilt.cicdecim')&&~isa(filter,'dsp.CICDecimator')
                            error(message('dsp:dspblkcicfilter:paramEmptyError1',get_param(blkh,'filtobj')));
                        end
                    else
                        if~isa(filter,'dsp.internal.mfilt.cicinterp')&&~isa(filter,'dsp.CICInterpolator')
                            error(message('dsp:dspblkcicfilter:paramEmptyError2',get_param(blkh,'filtobj')));
                        end
                    end
                end

                if~isempty(filter)


                    filterDefined=true;

                    if isa(filter,'mfilt.cicdecim')||isa(filter,'dsp.internal.mfilt.cicinterp')

                        block.UserData.filter=filter;

                        ftype=getfiltinfo(get(filter,'FilterStructure'));
                        args.filtFrom=2;

                        if blockTypeIsDecimation
                            R=get(filter,'DecimationFactor');
                        else
                            R=get(filter,'InterpolationFactor');
                        end

                        M=get(filter,'DifferentialDelay');
                        N=get(filter,'NumberOfSections');
                        section2NWL=get(filter,'SectionWordLengths');
                        section2NFL=get(filter,'SectionFracLengths');
                        outWL=get(filter,'OutputWordLength');
                        outFL=get(filter,'OutputFracLength');
                        InputWL=get(filter,'InputWordLength');
                        InputFL=get(filter,'InputFracLength');

                    else

                        ClonedFilter=clone(filter);
                        release(ClonedFilter);
                        block.UserData.filter=ClonedFilter;

                        args.filtFrom=3;

                        if blockTypeIsDecimation
                            ftype=getfiltinfo('Cascaded Integrator-Comb Decimator');
                        else
                            ftype=getfiltinfo('Cascaded Integrator-Comb Interpolator');
                        end


                        if blockTypeIsDecimation
                            R=get(filter,'DecimationFactor');
                        else
                            R=get(filter,'InterpolationFactor');
                        end

                        M=get(filter,'DifferentialDelay');
                        N=get(filter,'NumSections');


                        InputWL=[];
                        InputFL=[];
                        section2NWL=[];
                        section2NFL=[];
                        outWL=[];
                        outFL=[];

                        switch filter.FixedPointDataType
                        case 'Full precision'
                            args.filterInternals=1;
                        case 'Minimum section word lengths'
                            args.filterInternals=2;
                            outWL=filter.OutputWordLength;
                        case 'Specify word lengths'
                            args.filterInternals=3;
                            outWL=filter.OutputWordLength;
                            section2NWL=filter.SectionWordLengths;
                        case 'Specify word and fraction lengths'
                            args.filterInternals=4;
                            outWL=filter.OutputWordLength;
                            outFL=filter.OutputFractionLength;
                            section2NWL=filter.SectionWordLengths;
                            section2NFL=filter.SectionFractionLengths;
                        end

                    end
                else


                    filterDefined=false;
                end
            end
        end


        if filterDefined

            if dspIsFVToolOpen(gcbh)
                dspLinkFVTool2Mask(gcbh,'update');
            end
            args.ftype=ftype;
            args.section2NWL=section2NWL;
            args.section2NFL=section2NFL;
            args.states=0;
            args.outWL=outWL;
            args.outFL=outFL;
            args.InputWL=InputWL;
            args.InputFL=InputFL;
            args.R=R;
            args.M=M;
            args.N=N;
        else




            args.ftype=1;
            args.section2NWL=[];
            args.section2NFL=[];
            args.states=[];
            args.outWL=[];
            args.outFL=[];
            args.InputWL=[];
            args.InputFL=[];
            args.R=[];
            args.M=[];
            args.N=[];
        end
        varargout={args};

    case 'dynamic'
        handleBlockMaskUI(blkh,get_param(blkh,'Object'));

    end


    function ftype_Sfcn=getfiltinfo(filtstruct)

        switch lower(filtstruct)
        case{'cascaded integrator-comb decimator','decimator'}
            ftype_Sfcn=1;

        case{'zero-latency cascaded integrator-comb decimator','zero-latency decimator'}
            ftype_Sfcn=2;

        case{'cascaded integrator-comb interpolator','interpolator'}
            ftype_Sfcn=3;

        case{'zero-latency cascaded integrator-comb interpolator','zero-latency interpolator'}
            ftype_Sfcn=4;

        otherwise
            errordlg('Internal error: Structure not supported.');
        end


        function flag=isScalarRealDouble(x)

            flag=isreal(x)&&~issparse(x)&&isa(x,'double')&&isscalar(x);


            function flag=isFloatIntegerValued(x)

                flag=~isinf(x)&&~isnan(x)&&(fix(x)==x);


                function flag=isFloatIntegerGE(x,minVal)

                    flag=isFloatIntegerValued(x)&&(x>=minVal);


                    function handleBlockMaskUI(blkh,blockObj)

                        blockMaskObj=Simulink.Mask.get(blkh);


                        R_DecIntFcParam=blockMaskObj.getParameter('R');
                        M_DiffDly_Param=blockMaskObj.getParameter('M');
                        N_NumSctnsParam=blockMaskObj.getParameter('N');
                        DTSpecModeParam=blockMaskObj.getParameter('filterInternals');
                        SectionWLsParam=blockMaskObj.getParameter('BPS');
                        SectionFLsParam=blockMaskObj.getParameter('FLPS');
                        Output_WL_Param=blockMaskObj.getParameter('outputWordLength');
                        Output_FL_Param=blockMaskObj.getParameter('outputFracLength');


                        FilterObj_Param=blockMaskObj.getParameter('filtobj');

                        if strncmp(blockObj.filtFrom,'Dialog',6)



                            R_DecIntFcParam.Visible='on';
                            M_DiffDly_Param.Visible='on';
                            N_NumSctnsParam.Visible='on';
                            DTSpecModeParam.Visible='on';
                            FilterObj_Param.Visible='off';
                            FilterObj_Param.Enabled='off';





                            switch blockObj.filterInternals
                            case 'Full precision'
                                SectionWLsParam.Visible='off';
                                SectionFLsParam.Visible='off';
                                Output_WL_Param.Visible='off';
                                Output_FL_Param.Visible='off';

                            case 'Minimum section word lengths'
                                SectionWLsParam.Visible='off';
                                SectionFLsParam.Visible='off';
                                Output_WL_Param.Visible='on';
                                Output_FL_Param.Visible='off';

                            case 'Specify word lengths'
                                SectionWLsParam.Visible='on';
                                SectionFLsParam.Visible='off';
                                Output_WL_Param.Visible='on';
                                Output_FL_Param.Visible='off';

                            otherwise

                                SectionWLsParam.Visible='on';
                                SectionFLsParam.Visible='on';
                                Output_WL_Param.Visible='on';
                                Output_FL_Param.Visible='on';
                            end
                        else



                            FilterObj_Param.Visible='on';
                            FilterObj_Param.Enabled='on';
                            R_DecIntFcParam.Visible='off';
                            M_DiffDly_Param.Visible='off';
                            N_NumSctnsParam.Visible='off';
                            DTSpecModeParam.Visible='off';
                            SectionWLsParam.Visible='off';
                            SectionFLsParam.Visible='off';
                            Output_WL_Param.Visible='off';
                            Output_FL_Param.Visible='off';
                        end




                        if strcmp(blockMaskObj.Type,'CIC Interpolation')






                            Rate_Opts_Param=blockMaskObj.getParameter('framing');
                            Input_Proc_Param=blockMaskObj.getParameter('InputProcessing');
                            Rate_Opts_Param.Visible='on';











                            if(strcmp(Rate_Opts_Param.Value,'Maintain input frame rate'))
                                Rate_Opts_Param.Value='Enforce single-rate processing';
                            end
                            if(strcmp(Rate_Opts_Param.Value,'Maintain input frame size'))

                                Rate_Opts_Param.Value='Allow multirate processing';
                            end
                            if(strcmp(Rate_Opts_Param.Value,'Allow multirate processing'))

                                Input_Proc_Param.Value='Elements as channels (sample based)';
                            end

                            Rate_Opts_Param.TypeOptions=Rate_Opts_Param.TypeOptions(1:2);
                            if strcmp(blockObj.InputProcessing,'Columns as channels (frame based)')

                                Rate_Opts_Param.Enabled='off';

                                Rate_Opts_Param.Value='Enforce single-rate processing';
                            else

                                Rate_Opts_Param.Enabled='on';
                            end
                        end
