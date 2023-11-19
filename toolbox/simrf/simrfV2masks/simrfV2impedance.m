function simrfV2impedance(block,action)

    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')...
        &&strcmpi(top_sys,'simrfV2elements')
        return;
    end

    switch(action)
    case 'simrfInit'

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end
        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskWSValues=simrfV2getblockmaskwsvalues(block);
        simrfV2constants=simrfV2_constants();
        Rmin=value(simrfV2constants.Rmin,'Ohm');

        switch MaskVals{idxMaskNames.Impedance_type}
        case 'Frequency independent'

            if regexpi(get_param(top_sys,'SimulationStatus'),...
                '^(updating|initializing)$')
                validateattributes(MaskWSValues.Impedance,...
                {'numeric'},{'nonempty','scalar','finite'},'',...
                'Complex impedance');
                Z=MaskWSValues.Impedance;


                Z0=50;
                if real(Z)<Rmin
                    S(:,:,1)=(Rmin-Z0)/(Rmin+Z0);
                else
                    S(:,:,1)=(real(Z)-Z0)/(real(Z)+Z0);
                end
                S(:,:,2)=(Z-Z0)/(Z+Z0);


                if(S(:,:,2)==-Inf)
                    S(:,:,2)=1e9;
                end
                s_1D=simrfV2_sparams3d_to_1d(S);

                set_param([block,'/F1PORT_RF'],...
                'ZO',simrfV2vector2str(Z0),...
                'freqs','[0, 1]',...
                'S',simrfV2vector2str(s_1D));
            end

        case 'Frequency dependent'

            if regexpi(get_param(top_sys,'SimulationStatus'),...
                '^(updating|initializing)$')
                freq=simrfV2checkfreqs(MaskWSValues.Freq,'gtez');
                freq=simrfV2convert2baseunit(...
                freq,MaskVals{idxMaskNames.Freq_unit});
                Z=MaskWSValues.Impedance;

                validateattributes(Z,{'numeric'},...
                {'nonempty','vector','finite','size',...
                size(freq)},'','Complex impedance');


                Z0=50;
                index_dc=find(freq==0,1);
                s_dc=[];
                if isempty(index_dc)
                    [val,ind]=min(Z);
                    if real(val)<Rmin
                        s_dc=(Rmin-Z0)/(Rmin+Z0);
                    else
                        s_dc=(real(Z(ind))-Z0)/(real(Z(ind))+Z0);
                    end
                    freq=[0,freq];
                else

                    validateattributes(abs(imag(Z(index_dc))),...
                    {'numeric'},{'<=',1e-10},mfilename,...
                    'impedance to be real for zero frequency');
                    Z(index_dc)=real(Z(index_dc));
                end

                svec=(Z-Z0)./(Z+Z0);
                svec=[s_dc,svec];



                index_Zinf=find(svec==-Inf,1);
                if~isempty(index_Zinf)
                    svec(index_Zinf)=1e9;
                end


                [freq,ind]=sort(freq);
                svec=svec(ind);

                validateattributes(length(svec),{'numeric'},{'>',1},...
                '','to provide more than one non-dc data point');

                S=reshape(svec,1,1,length(svec));
                s_1D=simrfV2_sparams3d_to_1d(S);

                set_param([block,'/F1PORT_RF'],...
                'ZO',simrfV2vector2str(Z0),...
                'freqs',simrfV2vector2str(freq),...
                'S',simrfV2vector2str(s_1D));
            end
        end
    end

end