function schema





    schema.package('sigdatatypes');


    if isempty(findtype('signalFrequencyUnits'))
        schema.EnumType('signalFrequencyUnits',{'Normalized (0 to 1)','Hz','kHz','MHz','GHz'});
    end

    if isempty(findtype('SignalFdatoolFilterOrderMode'))
        schema.EnumType('SignalFdatoolFilterOrderMode',{'specify','minimum'});
    end

    if isempty(findtype('gremezOrderMode'))
        schema.EnumType('gremezOrderMode',{'specify','minimum','minimum even','minimum odd'});
    end


    if isempty(findtype('siggui_magspecs_FIRUnits'))
        schema.EnumType('siggui_magspecs_FIRUnits',{'dB','Linear'});
    end


    if isempty(findtype('siggui_magspecs_IIRUnits'))
        schema.EnumType('siggui_magspecs_IIRUnits',{'dB','Squared'});
    end

    if isempty(findtype('QToolOverflowMode'))
        schema.EnumType('QToolOverflowMode',{'Wrap','Saturate'});
    end

    if isempty(findtype('signal_arith'))
        schema.EnumType('signal_arith',{'double','single'});
    end

    if isempty(findtype('filterdesign_arith'))
        schema.EnumType('filterdesign_arith',{'double','single','fixed'});
    end

    if isempty(findtype('fxptmodes'))
        schema.EnumType('fxptmodes',{'signed','unsigned'});
    end

    if isempty(findtype('passstoporboth'))
        schema.EnumType('passstoporboth',{'passband','stopband','both'});
    end


    if isempty(findtype('passstop'))
        schema.EnumType('passstop',{'passband','stopband'});
    end

    if isempty(findtype('magrcosDesignType'))
        schema.EnumType('magrcosDesignType',{'Normal','Square root'});
    end

    if isempty(findtype('magnyquistDesignType'))
        schema.EnumType('magnyquistDesignType',{'Normal','Nonnegative','Minphase'});
    end

    if isempty(findtype('freqrcosTransitionMode'))
        schema.EnumType('freqrcosTransitionMode',{'Bandwidth','Rolloff'});
    end


    if isempty(findtype('SignalSpectrumTypeList'))
        schema.EnumType('SignalSpectrumTypeList',{'Onesided','Twosided'});
    end


    if isempty(findtype('SignalFrequencyRangeList'))
        schema.EnumType('SignalFrequencyRangeList',{'Half','Whole'});
    end


    if isempty(findtype('UnitsValues'))
        schema.EnumType('UnitsValues',{'mag','power','db'});
    end


    if isempty(findtype('signalNumeric'))
        schema.UserType('signalNumeric','MATLAB array',@check_numeric);
    end

    if isempty(findtype('strictbool'))
        schema.UserType('strictbool','double',@check_strictbool);
    end

    if isempty(findtype('spt_uint32'))
        schema.UserType('spt_uint32','int32',@check_sign);
    end

    if isempty(findtype('posint_matrix'))
        schema.UserType('posint_matrix','MATLAB array',@check_posint);
    end

    if isempty(findtype('posint_vector'))
        schema.UserType('posint_vector','posint_matrix',@check_vector);
    end

    if isempty(findtype('nonnegint_matrix'))
        schema.UserType('nonnegint_matrix','MATLAB array',@check_nonnegint);
    end

    if isempty(findtype('posint_vector'))
        schema.UserType('posint_vector','posint_matrix',@check_vector);
    end


    if isempty(findtype('posint'))
        schema.UserType('posint','posint_matrix',@check_singular);
    end


    if isempty(findtype('nonnegint'))
        schema.UserType('nonnegint','nonnegint_matrix',@check_singular);
    end
    if isempty(findtype('filterdesignIntDataTypes'))
        schema.UserType('filterdesignIntDataTypes','posint',@check_intvals);
    end

    if isempty(findtype('evenuint32'))
        schema.UserType('evenuint32','posint',@check_even);
    end

    if isempty(findtype('udouble'))
        schema.UserType('udouble','double',@check_sign);
    end


    if isempty(findtype('posdouble'))
        schema.UserType('posdouble','udouble',@check_posdouble);
    end

    if isempty(findtype('double_vector'))
        schema.UserType('double_vector','MATLAB array',@check_double_vector);
    end

    if isempty(findtype('twoelem_nonnegint_vector'))
        schema.UserType('twoelem_nonnegint_vector','double_vector',@check_twoelem_nonnegint);
    end

    if isempty(findtype('double0t1'))
        schema.UserType('double0t1','udouble',@check_0t1);


    end

    if isempty(findtype('twocol_nonneg_matrix'))
        schema.UserType('twocol_nonneg_matrix','MATLAB array',@check_twocol_nonneg);
    end


    function check_posint(value)

        check_integer(value);
        check_greaterthan0(value);


        function check_nonnegint(value)

            check_integer(value);
            check_nonnegative(value);



            function check_numeric(value)

                if~isnumeric(value)
                    error(message('signal:sigdatatypes:schema:NotNumericOrEmpty'));
                end


                function check_posdouble(value)

                    if value<=0
                        error(message('signal:sigdatatypes:schema:NotPositive'));
                    end

                    function check_strictbool(value)

                        if~any(value==[1,0])
                            error(message('signal:sigdatatypes:schema:NotBool'));
                        end


                        function check_greaterthan0(value)

                            c=value<1;
                            if any(c(:))
                                error(message('signal:sigdatatypes:schema:NotGreaterThanZero'));
                            end


                            function check_nonnegative(value)

                                c=value<0;
                                if any(c(:))
                                    error(message('signal:sigdatatypes:schema:NotNonNegative'));
                                end


                                function check_sign(value)

                                    if value<0
                                        error(message('signal:sigdatatypes:schema:Negative'));
                                    end


                                    function check_even(value)

                                        if~isnumeric(value)||rem(value,2)
                                            error(message('signal:sigdatatypes:schema:NotEven'));
                                        end


                                        function check_double_vector(value)

                                            check_vector(value);

                                            if~isa(value,'double')
                                                error(message('signal:sigdatatypes:schema:NotDoubleType'));
                                            end


                                            function check_vector(value)

                                                if~isnumeric(value)
                                                    error(message('signal:sigdatatypes:schema:NotNumeric'));
                                                end

                                                if all(size(value)>1)
                                                    error(message('signal:sigdatatypes:schema:NotVector'));
                                                end


                                                function check_twoelem_nonnegint(value)

                                                    check_integer(value);

                                                    if length(value)~=2
                                                        error(message('signal:sigdatatypes:schema:NotATwoElementVector'));
                                                    end

                                                    if any(value<0)
                                                        error(message('signal:sigdatatypes:schema:NotNonNegative'));
                                                    end


                                                    function check_integer(value)

                                                        if~isnumeric(value)||any(rem(value,1))
                                                            error(message('signal:sigdatatypes:schema:NotInt'));
                                                        end


                                                        function check_0t1(value)

                                                            if value<0||value>1
                                                                error(message('signal:sigdatatypes:schema:OutOfRange'));
                                                            end



                                                            function check_singular(value)

                                                                if any(size(value)~=1)
                                                                    error(message('signal:sigdatatypes:schema:NotScalar'));
                                                                end



                                                                function check_intvals(value)


                                                                    if~any([8,16,32]==value)
                                                                        error(message('signal:sigdatatypes:schema:InvalidValue'));
                                                                    end


                                                                    function check_twocol_nonneg(value)

                                                                        ncols=size(value,2);
                                                                        if(2*fix(ncols/2)~=ncols)
                                                                            error(message('signal:sigdatatypes:schema:InvalidDimensions'));
                                                                        end

                                                                        if~isnumeric(value)
                                                                            error(message('signal:sigdatatypes:schema:MustBeNumeric'));
                                                                        end

                                                                        if any(value<0)
                                                                            error(message('signal:sigdatatypes:schema:MustBePositive'));
                                                                        end


