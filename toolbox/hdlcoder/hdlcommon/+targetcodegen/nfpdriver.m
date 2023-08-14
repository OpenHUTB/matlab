



classdef nfpdriver<targetcodegen.basedriver
    properties(SetAccess=protected,GetAccess=protected)
        LatencyEncode={'MAX','MIN','ZERO','CUSTOM'};
    end

    methods
        function obj=nfpdriver(varargin)
            obj@targetcodegen.basedriver(varargin{:});
        end


        function flag=isCompCompatible(~,c)
            assert(0);
        end


        function replaceWithTargetFunctions(this,p,hdldriver)
            assert(0);
        end


        function replaceWithInstantiationComp(this,ntk,c)
            assert(0);
        end

        function[latency,isLatencyCustom]=getDefaultLatency(this,targetIPType,targetCompDataType,hC)
            assert(isa(this.config.m_strategy,'fpconfig.NFPLatencyDrivenStrategy'));




            ipSettings=this.config.IPConfig.getIPSettings(targetIPType,targetCompDataType);
            isLatencyCustom=false;
            if(isempty(ipSettings))
                latency=-1;
            else
                latencyStrategy=this.getLocalLatencyStrategy(targetIPType,hC);
                if~strcmpi(latencyStrategy,'Custom')&&(ipSettings.CustomLatency>=0)


                    latency=ipSettings.CustomLatency;
                    isLatencyCustom=true;
                    return;
                end
                if(strcmpi(latencyStrategy,'ZERO'))
                    latency=0;
                else
                    if(strcmpi(latencyStrategy,'MIN'))


                        switch upper(targetIPType)
                        case{'MOD','REM'}




                            maxIterations=hC.getNFPModRemMaxIterations();
                            minLatency=ipSettings.MinLatency+int32(maxIterations)/4-int32(8);
                        case{'SIN','COS','SINCOS','COS + JSIN'}
                            if hC.getNFPArgReduction
                                minLatency=ipSettings.MinLatency;
                            else
                                minLatency=int32(22);
                            end
                        case{'TAN'}
                            if hC.getNFPArgReduction
                                minLatency=ipSettings.MinLatency;
                            else
                                minLatency=int32(19);
                            end
                        case{'DIV'}
                            radix=hC.getNFPRadix;
                            if(strcmpi(targetCompDataType,'half'))
                                if(radix==4)
                                    minLatency=int32(8);
                                else
                                    minLatency=ipSettings.MinLatency;
                                end
                            elseif(strcmpi(targetCompDataType,'double'))
                                if(radix==4)
                                    minLatency=int32(21);
                                else
                                    minLatency=ipSettings.MinLatency;
                                end
                            else
                                minLatency=ipSettings.MinLatency-12+6*(4/radix);
                            end
                        case{'RECIP'}
                            radix=hC.getNFPRadix;
                            if(strcmpi(targetCompDataType,'half'))
                                if(radix==4)
                                    minLatency=int32(8);
                                else
                                    minLatency=ipSettings.MinLatency;
                                end
                            elseif(strcmpi(targetCompDataType,'double'))
                                if(radix==4)
                                    minLatency=int32(21);
                                else
                                    minLatency=ipSettings.MinLatency;
                                end
                            else
                                minLatency=ipSettings.MinLatency-12+6*(4/radix);
                            end
                        case{'GAINPOW2'}
                            if(hC.getNFPDenormals==1)
                                minLatency=int32(3);
                            else
                                minLatency=ipSettings.MinLatency;
                            end
                        otherwise
                            minLatency=ipSettings.MinLatency;
                        end
                    end


                    switch upper(targetIPType)
                    case{'MOD','REM'}




                        maxIterations=hC.getNFPModRemMaxIterations();
                        maxLatency=ipSettings.MaxLatency+int32(maxIterations)/2-int32(16);
                    case{'SIN','COS','SINCOS'}
                        if hC.getNFPArgReduction
                            maxLatency=ipSettings.MaxLatency;
                        else
                            maxLatency=int32(22);
                        end
                    case{'TAN'}
                        if hC.getNFPArgReduction
                            maxLatency=ipSettings.MaxLatency;
                        else
                            maxLatency=int32(19);
                        end
                    case{'DIV'}
                        radix=hC.getNFPRadix;
                        if(strcmpi(targetCompDataType,'half'))
                            if(radix==4)
                                maxLatency=int32(14);
                            else
                                maxLatency=ipSettings.MaxLatency;
                            end
                        elseif(strcmpi(targetCompDataType,'double'))
                            if(radix==4)
                                maxLatency=int32(35);
                            else
                                maxLatency=ipSettings.MaxLatency;
                            end
                        else
                            maxLatency=ipSettings.MaxLatency-24+12*(4/radix);
                        end
                    case{'RECIP'}
                        radix=hC.getNFPRadix;
                        if(strcmpi(targetCompDataType,'half'))
                            if(radix==4)
                                maxLatency=int32(14);
                            else
                                maxLatency=ipSettings.MaxLatency;
                            end
                        elseif(strcmpi(targetCompDataType,'double'))
                            if(radix==4)
                                maxLatency=int32(34);
                            else
                                maxLatency=ipSettings.MaxLatency;
                            end
                        else
                            maxLatency=ipSettings.MaxLatency-24+12*(4/radix);
                        end

                    case{'GAINPOW2'}
                        if(hC.getNFPDenormals==1)
                            if strcmpi(targetCompDataType,'half')
                                maxLatency=int32(4);
                            else
                                maxLatency=int32(5);
                            end
                        else
                            maxLatency=ipSettings.MaxLatency;
                        end
                    case{'MUL'}
                        if strcmpi(targetCompDataType,'half')
                            if(hC.getNFPDenormals==1)
                                maxLatency=int32(7);
                            else
                                maxLatency=ipSettings.MaxLatency;
                            end
                        else
                            maxLatency=ipSettings.MaxLatency;
                        end
                    case{'LOG'}
                        if strcmpi(hdlfeature('NFPLogApprxImpl'),'on')
                            maxLatency=int32(20);
                        else
                            maxLatency=ipSettings.MaxLatency;
                        end
                    otherwise
                        maxLatency=ipSettings.MaxLatency;
                    end

                    if(strcmpi(latencyStrategy,'MAX'))
                        latency=maxLatency;
                    elseif(strcmpi(latencyStrategy,'CUSTOM'))
                        latency=hC.getNFPCustomLatency();
                        if latency>ipSettings.MaxLatency
                            hC.setNFPCustomLatency(ipSettings.MaxLatency);
                            latency=hC.getNFPCustomLatency();
                        end
                    elseif(maxLatency==minLatency)



                        idx=1:length(this.LatencyEncode);
                        maxIdx=idx(strcmp(this.LatencyEncode,'MAX'));
                        try
                            hC.setNFPLatency(maxIdx);
                        catch


                            assert(isa(hC,'hdlcoder.abs_comp')||...
                            isa(hC,'hdlcoder.signum_comp')||...
                            isa(hC,'hdlcoder.uminus_comp'));
                        end

                        latency=maxLatency;
                    else

                        latency=minLatency;
                    end

                end


                if strcmpi(targetIPType,'HDLRECIP')&&latency~=0
                    numIters=hC.getIterNum();
                    if strcmpi(latencyStrategy,'MIN')
                        latency=3*numIters+5;
                    else
                        latency=5*numIters+6;
                    end
                end
            end

        end


        function latencyStrategy=getLocalLatencyStrategy(this,targetIPType,hC)
            latencyStrategy=this.config.LibrarySettings.LatencyStrategy;
            if isempty(hC)
                return;
            end
            switch upper(targetIPType)
            case{'ADDSUB','MUL','DIV','CONVERT','RELOP','SQRT','RSQRT'...
                ,'RECIP','REM','ROUNDING','FIX','EXP','LOG','LOG2','LOG10','ATAN'...
                ,'ATAN2','ASIN','ACOS','SIN','COS','SINH','COSH','TANH','ASINH'...
                ,'ACOSH','ATANH','MOD','SINCOS','MINMAX','GAINPOW2','POW2','POW10','POW'...
                ,'HDLRECIP','MULTADD','HYPOT'}
                nfpLat=hC.getNFPLatency();
                if nfpLat~=0
                    latencyStrategy=this.LatencyEncode{nfpLat};
                end
            end
        end
    end

    methods(Static)

        function name=getMaskName(compClass)
            name=targetcodegen.basedriver.getMaskNamePrivate(compClass,'NFP\n');
        end


        function name=getFunctionName(varargin)
            name=targetcodegen.basedriver.getFunctionNamePrivate('nfp_',varargin{:});
        end

    end
end



