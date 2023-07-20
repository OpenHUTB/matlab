classdef(CaseInsensitiveProperties)ArbMagBand<matlab.mixin.SetGet&matlab.mixin.Copyable


















    properties(AbortSet,SetObservable,GetObservable)

        Frequencies='';

        Amplitudes='';

        Magnitudes='';

        Phases='';

        FreqResp='';

        GroupDelay='';

        Ripple='';

        Constrained='';
    end


    methods
        function this=ArbMagBand(freqValues,amplitudeValues,magValues,...
            phaseValues,freqrespValues,groupdelayValues,rippleValues,constrainedValues)



            if nargin>0
                set(this,'Frequencies',freqValues);
                if nargin>1
                    set(this,'Amplitudes',amplitudeValues);
                    if nargin>2
                        set(this,'Magnitudes',magValues);
                        if nargin>3
                            set(this,'Phases',phaseValues);
                            if nargin>4
                                set(this,'FreqResp',freqrespValues);
                                if nargin>5
                                    set(this,'GroupDelay',groupdelayValues);
                                    if nargin>6
                                        set(this,'Ripple',rippleValues);
                                        if nargin>7
                                            set(this,'Constrained',constrainedValues);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end


        end

    end

    methods
        function set.Frequencies(obj,value)

            validateattributes(value,{'char'},{'row'},'','Frequencies')
            obj.Frequencies=value;
        end

        function set.Amplitudes(obj,value)

            validateattributes(value,{'char'},{'row'},'','Amplitudes')
            obj.Amplitudes=value;
        end

        function set.Magnitudes(obj,value)

            validateattributes(value,{'char'},{'row'},'','Magnitudes')
            obj.Magnitudes=value;
        end

        function set.Phases(obj,value)

            validateattributes(value,{'char'},{'row'},'','Phases')
            obj.Phases=value;
        end

        function set.FreqResp(obj,value)

            validateattributes(value,{'char'},{'row'},'','FreqResp')
            obj.FreqResp=value;
        end

        function set.GroupDelay(obj,value)

            validateattributes(value,{'char'},{'row'},'','GroupDelay')
            obj.GroupDelay=value;
        end

        function set.Ripple(obj,value)

            validateattributes(value,{'char'},{'row'},'','Ripple')
            obj.Ripple=value;
        end

        function set.Constrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','Constrained')
            obj.Constrained=value;
        end

    end

    methods

        function disp(this)




            disp(get(this));


        end


        function tableRowSchema=getTableRowSchema(this,source,index,minOrder,nBands)



            responseType=source.ResponseType;

            frequencies.Type='edit';
            frequencies.ObjectProperty='Frequencies';
            frequencies.Source=this;
            frequencies.Tag=sprintf('Frequencies%d',index);

            tableRowSchema={frequencies};

            switch lower(responseType)
            case 'amplitudes'

                amplitudes.Type='edit';
                amplitudes.ObjectProperty='Amplitudes';
                amplitudes.Source=this;
                amplitudes.Mode=true;
                amplitudes.Tag=sprintf('Amplitudes%d',index);

                tableRowSchema{end+1}=amplitudes;

                if minOrder
                    ripple.Type='edit';
                    ripple.ObjectProperty='Ripple';
                    ripple.Source=this;
                    ripple.Mode=true;
                    ripple.Tag=sprintf('Ripple%d',index);

                    tableRowSchema{end+1}=ripple;
                else
                    if nBands>1&&isDSTMode(source)&&isfir(source)
                        bStr=sprintf('Band%d',index);
                        constrainedPropertyValue=strcmpi(source.(bStr).Constrained,'true');

                        constrained.Type='checkbox';
                        constrained.Tag=sprintf('Constrained%d',index);
                        constrained.DialogRefresh=true;
                        constrained.Mode=true;
                        constrained.Value=constrainedPropertyValue;

                        tableRowSchema{end+1}=constrained;

                        ripple.Type='edit';
                        ripple.Source=this;
                        ripple.Mode=true;

                        if constrainedPropertyValue
                            ripple.Enabled=true;
                            ripple.ObjectProperty='Ripple';
                            ripple.Tag=sprintf('Ripple%d',index);
                        else
                            ripple.Enabled=false;
                            ripple.Value='';
                            ripple.Tag=[sprintf('Ripple%d',index),'_noprop'];
                        end
                        tableRowSchema{end+1}=ripple;
                    end
                end

            case 'magnitudes and phases'
                magnitudes.Type='edit';
                magnitudes.ObjectProperty='Magnitudes';
                magnitudes.Source=this;
                magnitudes.Mode=true;
                magnitudes.Tag=sprintf('Magnitudes%d',index);

                tableRowSchema{end+1}=magnitudes;

                phases.Type='edit';
                phases.ObjectProperty='Phases';
                phases.Source=this;
                phases.Mode=true;
                phases.Tag=sprintf('Phases%d',index);

                tableRowSchema{end+1}=phases;

            case 'frequency response'
                fresp.Type='edit';
                fresp.ObjectProperty='FreqResp';
                fresp.Source=this;
                fresp.Mode=true;
                fresp.Tag=sprintf('FreqResp%d',index);

                tableRowSchema{end+1}=fresp;

            case 'group delay'
                gdelay.Type='edit';
                gdelay.ObjectProperty='GroupDelay';
                gdelay.Source=this;
                gdelay.Mode=true;
                gdelay.Tag=sprintf('GroupDelay%d',index);

                tableRowSchema{end+1}=gdelay;
            end


        end

    end

end

