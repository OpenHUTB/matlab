function simrfV2_msfcn_spectral_sparam(block)




    setup(block);



    function setup(block)


        block.NumInputPorts=1;
        block.NumOutputPorts=1;
        block.NumDialogPrms=6;



        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;

        block.InputPort(1).DirectFeedthrough=true;
        block.InputPort(1).SampleTime=[-1,0];
        block.InputPort(1).Complexity='Complex';
        block.OutputPort(1).SampleTime=[-1,0];
        block.OutputPort(1).Complexity='Complex';



        block.SimStateCompliance='DefaultSimState';


        block.RegBlockMethod('SetInputPortSampleTime',@SetInpPortST);
        block.RegBlockMethod('SetOutputPortSampleTime',@SetOutPortST);
        block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);
        block.RegBlockMethod('SetOutputPortDimensions',@SetOutPortDims);
        block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
        block.RegBlockMethod('InitializeConditions',@InitConditions);
        block.RegBlockMethod('Outputs',@Output);
        block.RegBlockMethod('Update',@Update);




        function SetInpPortST(block,~,st)

            if st<=0
                error('This block only supports discrete sample time')
            else
                fft_size=block.DialogPrm(2).Data;
                Intermission=block.DialogPrm(5).Data;
                block.InputPort(1).SampleTime=st;
                block.OutputPort(1).SampleTime=[st(1)*fft_size*(Intermission+1),...
                st(2)];
            end



            function SetOutPortST(block,~,st)
                if st<=0
                    error('This block only supports discrete sample time')
                else
                    fft_size=block.DialogPrm(2).Data;
                    Intermission=block.DialogPrm(5).Data;
                    block.OutputPort(1).SampleTime=st;
                    block.InputPort(1).SampleTime=[st(1)/(fft_size*(Intermission+1)),...
                    st(2)];
                end



                function SetInpPortDims(block,port,di)
                    OS=block.DialogPrm(1).Data;
                    fft_size=block.DialogPrm(2).Data;
                    block.InputPort(port).Dimensions=di;
                    if~isempty(block.InputPort(1).Dimensions)
                        di_p=block.InputPort(1).Dimensions;
                        if(length(di_p)==2&&di_p(1)==1)
                            if di_p(2)>1
                                block.OutputPort(1).Dimensions=[1,(fft_size/OS)*(di_p(2)-1)];
                            else
                                error('Input length must be larger than 1');
                            end
                        else
                            error('Input must be of size [1xN]');
                        end
                    end




                    function SetOutPortDims(block,~,di)
                        OS=block.DialogPrm(1).Data;
                        fft_size=block.DialogPrm(2).Data;
                        if~isempty(block.OutputPort(1).Dimensions)

                            if length(di)==2
                                block.InputPort(1).Dimensions=[1,(di(2)*OS/fft_size)+1];
                                block.OutputPort(1).Dimensions=di;
                            else
                                error('Output size must be [MxN]');
                            end
                        end



                        function DoPostPropSetup(block)


                            fft_size=block.DialogPrm(2).Data;
                            ncol=block.InputPort(1).Dimensions(2);


                            block.NumDworks=ncol+3;
                            block.Dwork(1).Name='index';
                            block.Dwork(1).Dimensions=1;
                            block.Dwork(1).DatatypeID=0;
                            block.Dwork(1).Complexity='Real';
                            block.Dwork(1).UsedAsDiscState=true;

                            block.Dwork(2).Name='KaiserCoeffs';
                            block.Dwork(2).Dimensions=fft_size;
                            block.Dwork(2).DatatypeID=0;
                            block.Dwork(2).Complexity='Real';
                            block.Dwork(2).UsedAsDiscState=false;

                            block.Dwork(3).Name='TestbenchHandle';
                            block.Dwork(3).Dimensions=1;
                            block.Dwork(3).DatatypeID=0;
                            block.Dwork(3).Complexity='Real';
                            block.Dwork(3).UsedAsDiscState=false;


                            for i=(1:ncol)+3
                                block.Dwork(i).Name=['y',num2str(i-2)];
                                block.Dwork(i).Dimensions=fft_size;
                                block.Dwork(i).DatatypeID=0;
                                block.Dwork(i).Complexity='Complex';
                                block.Dwork(i).UsedAsDiscState=true;
                            end


                            function InitConditions(block)



                                fft_size=block.DialogPrm(2).Data;
                                beta=block.DialogPrm(3).Data;
                                block.Dwork(1).Data=0;
                                block.Dwork(2).Data(:)=besseli(0,beta*...
                                sqrt(1-(((0:fft_size-1)-(fft_size-1)/2)/((fft_size-1)/2)).^2))/...
                                besseli(0,beta);
                                block.Dwork(3).Data=get_param(get_param(get_param(get_param(...
                                block.BlockHandle,'Parent'),'Parent'),'Parent'),'Handle');
                                for colIdx=4:block.NumDworks


                                    block.Dwork(colIdx).Data(:)=complex(realmin,realmin);
                                end



                                function Update(block)

                                    if block.InputPort(1).IsSampleHit
                                        bufferIndex=block.Dwork(1).Data+1;
                                        if bufferIndex<block.DialogPrm(2).Data
                                            for j=1:block.InputPort(1).Dimensions(2)
                                                block.Dwork(j+3).Data(bufferIndex)=...
                                                block.InputPort(1).Data(j)*...
                                                block.Dwork(2).Data(bufferIndex);
                                            end
                                        elseif bufferIndex>=block.DialogPrm(2).Data*...
                                            (block.DialogPrm(5).Data+1)
                                            bufferIndex=0;





                                            SParamElem2Val=block.DialogPrm(4).Data;
                                            InputIdx=block.DialogPrm(6).Data;
                                            InputIdxstr=sprintf('%d',int8(mod(InputIdx,...
                                            length(SParamElem2Val))+1));
                                            set_param(block.Dwork(3).Data,'InputIdx',InputIdxstr);
                                        end
                                        block.Dwork(1).Data=bufferIndex;
                                    end


                                    function Output(block)


                                        if block.InputPort(1).IsSampleHit
                                            if block.Dwork(1).Data==0
                                                OS=block.DialogPrm(1).Data;
                                                fft_size=block.DialogPrm(2).Data;
                                                ncol=max(block.InputPort(1).Dimensions);
                                                fft_in=fft(block.Dwork(4).Data,fft_size);
                                                measuredFFT_in=...
                                                [fft_in(fft_size/2+1+fft_size*(1-1/OS)/2:fft_size);...
                                                fft_in(1:fft_size*1/OS/2)];
                                                for jInd=2:ncol
                                                    fft_out=fft(block.Dwork(jInd+3).Data,fft_size);
                                                    measuredFFT_out=...
                                                    [fft_out(fft_size/2+1+fft_size*(1-1/OS)/2:fft_size);...
                                                    fft_out(1:fft_size*1/OS/2)];
                                                    block.OutputPort(1).Data((1:fft_size/OS)+...
                                                    (jInd-2)*fft_size/OS)=measuredFFT_out./...
                                                    (measuredFFT_in+eps(0))+eps(0);
                                                end
                                            end
                                        end


